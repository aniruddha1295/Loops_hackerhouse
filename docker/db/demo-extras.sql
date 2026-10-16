-- ============================================
-- Demo extras — runs after seed.sql on a fresh Docker database
--   1. Tool-execution history for every seeded call (call detail pages)
--   2. Filecoin / on-chain data for a few claims (Blockchain page)
--   3. ERC-8004 agent registration row (Agent identity card)
--   4. Shift all demo dates so the newest call is from today
-- ============================================

-- 1. Tool executions, derived from each call's tools_used
INSERT INTO call_tool_executions (call_log_id, tool_name, tool_args, tool_result, success, latency_ms, executed_at)
SELECT
  cl.id,
  t.tool,
  CASE t.tool
    WHEN 'lookup_claim'      THEN jsonb_build_object('claim_number', c.claim_number)
    WHEN 'check_documents'   THEN jsonb_build_object('claim_number', c.claim_number)
    WHEN 'check_policy'      THEN jsonb_build_object('policy_number', p.policy_number)
    WHEN 'file_claim'        THEN jsonb_build_object('policy_number', p.policy_number, 'claim_type', c.claim_type,
                                                     'incident_date', c.incident_date, 'description', left(c.incident_description, 120))
    WHEN 'schedule_callback' THEN jsonb_build_object('phone_number', cl.phone_number, 'preferred_time', 'tomorrow at 10am',
                                                     'reason', 'Follow up on claim status')
    WHEN 'escalate_to_human' THEN jsonb_build_object('reason', 'Customer requested to speak with an adjuster',
                                                     'priority', 'high', 'claim_number', c.claim_number)
    ELSE '{}'::jsonb
  END,
  CASE t.tool
    WHEN 'lookup_claim'      THEN jsonb_build_object('found', c.id IS NOT NULL, 'claim_number', c.claim_number, 'status', c.status,
                                                     'assigned_adjuster', c.assigned_adjuster, 'claimed_amount', c.claimed_amount)
    WHEN 'check_documents'   THEN jsonb_build_object('claim_number', c.claim_number,
                                                     'documents_received', to_jsonb(coalesce(c.documents_received, '{}')),
                                                     'documents_missing', to_jsonb(ARRAY(
                                                        SELECT unnest(coalesce(c.documents_required, '{}'))
                                                        EXCEPT
                                                        SELECT unnest(coalesce(c.documents_received, '{}')))))
    WHEN 'check_policy'      THEN jsonb_build_object('found', p.id IS NOT NULL, 'policy_number', p.policy_number, 'policy_type', p.policy_type,
                                                     'status', p.status, 'coverage_amount', p.coverage_amount, 'deductible', p.deductible)
    WHEN 'file_claim'        THEN jsonb_build_object('success', true, 'claim_number', c.claim_number, 'status', 'submitted')
    WHEN 'schedule_callback' THEN jsonb_build_object('success', true, 'scheduled', true)
    WHEN 'escalate_to_human' THEN jsonb_build_object('success', true, 'escalated', true, 'assigned_to', 'Neha Agarwal')
    ELSE '{}'::jsonb
  END,
  true,
  180 + abs(hashtext(cl.id::text || t.tool)) % 650,
  cl.started_at + make_interval(secs => t.ord * 35)
FROM call_logs cl
CROSS JOIN LATERAL unnest(cl.tools_used) WITH ORDINALITY AS t(tool, ord)
LEFT JOIN LATERAL (
  SELECT * FROM claims WHERE customer_id = cl.customer_id ORDER BY updated_at DESC LIMIT 1
) c ON true
LEFT JOIN LATERAL (
  SELECT * FROM policies WHERE customer_id = cl.customer_id ORDER BY start_date DESC LIMIT 1
) p ON true;

-- 2. Filecoin evidence + Base Sepolia attestation
--    CID / piece CID / tx hash are real values from the hackathon runs, so explorer links resolve.
INSERT INTO evidence_bundles (claim_id, bundle_json, bundle_hash)
SELECT
  c.id,
  b.bundle,
  '0x' || encode(sha256(convert_to(b.bundle::text, 'UTF8')), 'hex')
FROM claims c
CROSS JOIN LATERAL (
  SELECT jsonb_build_object(
    'claim_number', c.claim_number,
    'claim_type', c.claim_type,
    'incident_date', c.incident_date,
    'incident_description', c.incident_description,
    'claimed_amount', c.claimed_amount,
    'documents_received', c.documents_received,
    'filed_at', c.filed_at
  ) AS bundle
) b
WHERE c.id IN ('c0000003-0000-0000-0000-000000000003',
               'c0000008-0000-0000-0000-000000000008',
               'c0000009-0000-0000-0000-000000000009');

UPDATE claims c SET
  filecoin_cid     = 'bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi',
  piece_cid        = 'baga6ea4seaqao7s73y24kcutaosvacpdjgfe74obumnasvbden3ebud42tfn2a',
  dataset_id       = '1042',
  evidence_hash    = eb.bundle_hash,
  pdp_proof_status = 'verified',
  agent_id         = 1
FROM evidence_bundles eb
WHERE eb.claim_id = c.id;

UPDATE claims SET
  attestation_tx_hash = '0x6d5eea20f75bc400cbc155eb7cba659e5815ffb5badb8e6ad84ef6b01d1e9f56',
  attested_at         = updated_at
WHERE id = 'c0000003-0000-0000-0000-000000000003';

INSERT INTO filecoin_uploads (claim_id, piece_cid, dataset_id, root_cid, upload_status, pdp_status, attempted_at, completed_at)
SELECT id, piece_cid, dataset_id, filecoin_cid, 'completed', 'verified', updated_at, updated_at + interval '40 seconds'
FROM claims
WHERE filecoin_cid IS NOT NULL;

-- 3. ERC-8004 agent identity (Base Sepolia IdentityRegistry)
INSERT INTO agent_registrations (agent_id, identity_registry_address, network)
VALUES (1, '0x8004A818BFB912233c491871b3d84c89A494BD9e', 'base-sepolia');

-- 4. Move every demo date forward by whole days so the newest call lands today
DO $$
DECLARE
  latest  timestamptz;
  days    int;
  col     record;
BEGIN
  SELECT max(started_at) INTO latest FROM call_logs;
  IF latest IS NULL THEN RETURN; END IF;

  days := current_date - latest::date;
  IF latest + make_interval(days => days) > now() THEN
    days := days - 1;
  END IF;
  IF days <= 0 THEN RETURN; END IF;

  FOR col IN
    SELECT table_name, column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND data_type IN ('date', 'timestamp with time zone')
      AND column_name <> 'date_of_birth'
  LOOP
    IF col.data_type = 'date' THEN
      EXECUTE format('UPDATE %I SET %I = %I + %s', col.table_name, col.column_name, col.column_name, days);
    ELSE
      EXECUTE format('UPDATE %I SET %I = %I + make_interval(days => %s)', col.table_name, col.column_name, col.column_name, days);
    END IF;
  END LOOP;

  RAISE NOTICE 'Demo data shifted forward by % days', days;
END $$;
