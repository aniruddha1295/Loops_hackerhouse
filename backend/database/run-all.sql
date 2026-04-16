-- ============================================
-- Combined: Migration + Seed
-- Paste this entire file into Supabase SQL Editor
-- https://supabase.com/dashboard/project/peyqgljejyrgymokylcl/sql/new
-- ============================================

-- ============================================
-- MIGRATION: Create Tables
-- ============================================

-- 1. Customers
CREATE TABLE IF NOT EXISTS customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name TEXT NOT NULL,
  email TEXT,
  phone TEXT NOT NULL,
  date_of_birth DATE,
  address TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Policies
CREATE TABLE IF NOT EXISTS policies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_number TEXT UNIQUE NOT NULL,
  customer_id UUID NOT NULL REFERENCES customers(id),
  policy_type TEXT NOT NULL,
  provider TEXT NOT NULL,
  coverage_amount NUMERIC NOT NULL,
  deductible NUMERIC NOT NULL,
  premium_monthly NUMERIC NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled', 'pending')),
  coverage_details JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Claims
CREATE TABLE IF NOT EXISTS claims (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  claim_number TEXT UNIQUE NOT NULL,
  policy_id UUID NOT NULL REFERENCES policies(id),
  customer_id UUID NOT NULL REFERENCES customers(id),
  claim_type TEXT NOT NULL,
  status TEXT DEFAULT 'submitted' CHECK (status IN (
    'submitted', 'under_review', 'documents_needed',
    'approved', 'denied', 'paid', 'closed'
  )),
  incident_date DATE NOT NULL,
  incident_description TEXT NOT NULL,
  claimed_amount NUMERIC,
  approved_amount NUMERIC,
  assigned_adjuster TEXT,
  documents_required TEXT[],
  documents_received TEXT[],
  notes TEXT,
  filed_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Call Logs
CREATE TABLE IF NOT EXISTS call_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  elevenlabs_conversation_id TEXT,
  customer_id UUID REFERENCES customers(id),
  direction TEXT NOT NULL CHECK (direction IN ('inbound', 'outbound', 'webrtc')),
  phone_number TEXT,
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'failed')),
  duration_seconds INT,
  transcript JSONB,
  summary TEXT,
  outcome TEXT,
  tools_used TEXT[],
  recording_url TEXT,
  started_at TIMESTAMPTZ DEFAULT now(),
  ended_at TIMESTAMPTZ
);

-- 5. Call Tool Executions
CREATE TABLE IF NOT EXISTS call_tool_executions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  call_log_id UUID NOT NULL REFERENCES call_logs(id) ON DELETE CASCADE,
  tool_name TEXT NOT NULL,
  tool_args JSONB,
  tool_result JSONB,
  success BOOLEAN DEFAULT true,
  latency_ms INT,
  executed_at TIMESTAMPTZ DEFAULT now()
);

-- 6. Escalations
CREATE TABLE IF NOT EXISTS escalations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  call_log_id UUID NOT NULL REFERENCES call_logs(id),
  claim_id UUID REFERENCES claims(id),
  customer_id UUID REFERENCES customers(id),
  reason TEXT NOT NULL,
  priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'assigned', 'resolved')),
  assigned_to TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  resolved_at TIMESTAMPTZ
);

-- 7. Scheduled Callbacks
CREATE TABLE IF NOT EXISTS scheduled_callbacks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  call_log_id UUID REFERENCES call_logs(id),
  customer_id UUID REFERENCES customers(id),
  phone_number TEXT NOT NULL,
  scheduled_time TIMESTAMPTZ NOT NULL,
  reason TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_claims_customer ON claims(customer_id);
CREATE INDEX IF NOT EXISTS idx_claims_policy ON claims(policy_id);
CREATE INDEX IF NOT EXISTS idx_claims_number ON claims(claim_number);
CREATE INDEX IF NOT EXISTS idx_policies_number ON policies(policy_number);
CREATE INDEX IF NOT EXISTS idx_policies_customer ON policies(customer_id);
CREATE INDEX IF NOT EXISTS idx_call_logs_customer ON call_logs(customer_id);
CREATE INDEX IF NOT EXISTS idx_call_logs_conversation ON call_logs(elevenlabs_conversation_id);
CREATE INDEX IF NOT EXISTS idx_escalations_status ON escalations(status);
CREATE INDEX IF NOT EXISTS idx_callbacks_status ON scheduled_callbacks(status, scheduled_time);

-- ============================================
-- SEED DATA
-- ============================================

-- CUSTOMERS (8)
INSERT INTO customers (id, full_name, email, phone, date_of_birth, address) VALUES
  ('11111111-1111-1111-1111-111111111111', 'James Wilson', 'james.wilson@email.com', '+14155550101', '1985-03-15', '742 Evergreen Terrace, San Francisco, CA 94110'),
  ('22222222-2222-2222-2222-222222222222', 'Maria Garcia', 'maria.garcia@email.com', '+14155550102', '1990-07-22', '1847 Oak Avenue, San Jose, CA 95126'),
  ('33333333-3333-3333-3333-333333333333', 'Robert Chen', 'robert.chen@email.com', '+14155550103', '1978-11-08', '523 Pine Street, Oakland, CA 94612'),
  ('44444444-4444-4444-4444-444444444444', 'Emily Davis', 'emily.davis@email.com', '+14155550104', '1992-01-30', '2100 Market Street, San Francisco, CA 94114'),
  ('55555555-5555-5555-5555-555555555555', 'Michael Thompson', 'michael.t@email.com', '+14155550105', '1983-09-12', '890 Broadway, Redwood City, CA 94063'),
  ('66666666-6666-6666-6666-666666666666', 'Sarah Kim', 'sarah.kim@email.com', '+14155550106', '1995-05-18', '1234 Mission Blvd, Fremont, CA 94539'),
  ('77777777-7777-7777-7777-777777777777', 'David Martinez', 'david.martinez@email.com', '+14155550107', '1988-12-03', '456 El Camino Real, Palo Alto, CA 94301'),
  ('88888888-8888-8888-8888-888888888888', 'Jennifer Lee', 'jennifer.lee@email.com', '+14155550108', '1975-06-25', '789 University Ave, Berkeley, CA 94710')
ON CONFLICT (id) DO NOTHING;

-- POLICIES (10)
INSERT INTO policies (id, policy_number, customer_id, policy_type, provider, coverage_amount, deductible, premium_monthly, start_date, end_date, status, coverage_details) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'POL-2024-001234', '11111111-1111-1111-1111-111111111111', 'auto', 'SafeGuard Insurance', 50000, 1000, 185.50, '2024-01-15', '2027-01-15', 'active',
   '{"vehicle": "2022 Toyota Camry", "vin": "4T1BF1FK5CU123456", "liability": "100/300/100", "collision": true, "comprehensive": true, "uninsured_motorist": true, "roadside_assistance": true}'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'POL-2024-005678', '11111111-1111-1111-1111-111111111111', 'home', 'SafeGuard Insurance', 450000, 2500, 210.00, '2024-03-01', '2027-03-01', 'active',
   '{"property_type": "single_family", "square_feet": 1850, "year_built": 1998, "dwelling_coverage": 450000, "personal_property": 225000, "liability": 300000, "flood": false, "earthquake": true}'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'POL-2024-002345', '22222222-2222-2222-2222-222222222222', 'auto', 'Pacific Shield', 35000, 500, 145.00, '2024-06-01', '2026-06-01', 'active',
   '{"vehicle": "2021 Honda Civic", "vin": "2HGFC2F69MH543210", "liability": "50/100/50", "collision": true, "comprehensive": true, "uninsured_motorist": false, "roadside_assistance": false}'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'POL-2023-003456', '33333333-3333-3333-3333-333333333333', 'auto', 'SafeGuard Insurance', 75000, 1500, 220.00, '2023-09-01', '2025-09-01', 'active',
   '{"vehicle": "2023 BMW X5", "vin": "5UXCR6C05N9K78901", "liability": "250/500/250", "collision": true, "comprehensive": true, "uninsured_motorist": true, "roadside_assistance": true}'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'POL-2024-006789', '44444444-4444-4444-4444-444444444444', 'home', 'Pacific Shield', 320000, 2000, 175.00, '2024-02-15', '2027-02-15', 'active',
   '{"property_type": "condo", "square_feet": 1200, "year_built": 2010, "dwelling_coverage": 320000, "personal_property": 160000, "liability": 200000, "flood": false, "earthquake": false}'),
  ('ffffffff-ffff-ffff-ffff-ffffffffffff', 'POL-2024-007890', '55555555-5555-5555-5555-555555555555', 'health', 'WellCare Plus', 500000, 3000, 450.00, '2024-01-01', '2026-12-31', 'active',
   '{"plan_type": "PPO", "network": "nationwide", "copay_primary": 25, "copay_specialist": 50, "prescription_coverage": true, "dental": false, "vision": true, "mental_health": true, "max_out_of_pocket": 8000}'),
  ('a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', 'POL-2025-004567', '66666666-6666-6666-6666-666666666666', 'auto', 'Pacific Shield', 40000, 750, 155.00, '2025-01-10', '2027-01-10', 'active',
   '{"vehicle": "2024 Tesla Model 3", "vin": "5YJ3E1EA1RF234567", "liability": "100/300/100", "collision": true, "comprehensive": true, "uninsured_motorist": true, "roadside_assistance": true}'),
  ('b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1', 'POL-2024-008901', '77777777-7777-7777-7777-777777777777', 'home', 'SafeGuard Insurance', 780000, 5000, 340.00, '2024-05-01', '2027-05-01', 'active',
   '{"property_type": "single_family", "square_feet": 2800, "year_built": 2015, "dwelling_coverage": 780000, "personal_property": 390000, "liability": 500000, "flood": false, "earthquake": true}'),
  ('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'POL-2024-009012', '88888888-8888-8888-8888-888888888888', 'health', 'WellCare Plus', 750000, 2000, 520.00, '2024-01-01', '2026-12-31', 'active',
   '{"plan_type": "HMO", "network": "california", "copay_primary": 15, "copay_specialist": 35, "prescription_coverage": true, "dental": true, "vision": true, "mental_health": true, "max_out_of_pocket": 6000}'),
  ('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'POL-2024-010123', '88888888-8888-8888-8888-888888888888', 'life', 'SafeGuard Insurance', 1000000, 0, 85.00, '2024-04-01', '2054-04-01', 'active',
   '{"term_years": 30, "beneficiary": "David Lee (spouse)", "type": "term_life", "accidental_death": true, "waiver_of_premium": true}')
ON CONFLICT (id) DO NOTHING;

-- CLAIMS (12)
INSERT INTO claims (id, claim_number, policy_id, customer_id, claim_type, status, incident_date, incident_description, claimed_amount, approved_amount, assigned_adjuster, documents_required, documents_received, notes, filed_at, updated_at) VALUES
  ('c0000001-0000-0000-0000-000000000001', 'CLM-2026-000456', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111',
   'collision', 'under_review', '2026-04-02',
   'Rear-ended at intersection of Market St and 5th Ave while stopped at red light. Other driver ran the light. Moderate damage to rear bumper, trunk lid, and tail lights. No injuries. Police report filed (#SF-2026-04-8834).',
   8500.00, NULL, 'Sarah Chen',
   ARRAY['police_report', 'repair_estimate', 'photos', 'other_driver_info'],
   ARRAY['police_report', 'other_driver_info'],
   'Awaiting repair estimate from customer preferred body shop. Photos of damage still needed. Other driver''s insurance (Progressive, policy #PG-445566) has been contacted.',
   '2026-04-03 10:30:00-07', '2026-04-10 14:15:00-07'),

  ('c0000002-0000-0000-0000-000000000002', 'CLM-2026-000457', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111',
   'water_damage', 'documents_needed', '2026-03-20',
   'Pipe burst in upstairs bathroom causing water damage to ceiling and hardwood floors on first floor. Emergency plumber called to stop leak.',
   12000.00, NULL, 'Mike Rodriguez',
   ARRAY['plumber_invoice', 'damage_photos', 'contractor_estimate', 'inventory_list'],
   ARRAY['plumber_invoice', 'damage_photos'],
   'Customer has submitted plumber invoice ($850) and initial damage photos. Still needs contractor repair estimate and inventory of damaged personal property.',
   '2026-03-21 08:15:00-07', '2026-04-05 11:30:00-07'),

  ('c0000003-0000-0000-0000-000000000003', 'CLM-2026-000321', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '22222222-2222-2222-2222-222222222222',
   'windshield', 'approved', '2026-03-10',
   'Rock hit windshield on Highway 101 causing a large crack across the driver side. Windshield needs full replacement.',
   950.00, 950.00, 'Sarah Chen',
   ARRAY['photos', 'repair_estimate'],
   ARRAY['photos', 'repair_estimate'],
   'Claim approved for full windshield replacement. Safelite authorized for repair. Zero deductible applies for glass claims under this policy.',
   '2026-03-11 09:00:00-07', '2026-03-18 16:45:00-07'),

  ('c0000004-0000-0000-0000-000000000004', 'CLM-2026-000789', 'dddddddd-dddd-dddd-dddd-dddddddddddd', '33333333-3333-3333-3333-333333333333',
   'collision', 'denied', '2026-02-14',
   'Vehicle hit a pothole causing damage to front right wheel and suspension. Customer claims city is responsible.',
   4200.00, 0, 'Tom Bradley',
   ARRAY['photos', 'repair_estimate', 'police_report'],
   ARRAY['photos', 'repair_estimate'],
   'Claim denied. Pothole damage is excluded under the policy terms (Section 4.2 - Road Hazard Exclusion). Customer advised to file claim with city of Oakland. Appeal window closes 2026-05-14.',
   '2026-02-15 14:20:00-08', '2026-03-01 10:00:00-08'),

  ('c0000005-0000-0000-0000-000000000005', 'CLM-2026-000112', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '44444444-4444-4444-4444-444444444444',
   'theft', 'submitted', '2026-04-12',
   'Package containing laptop (MacBook Pro 16") stolen from front porch. Ring doorbell footage shows theft at 2:47 PM. Police report filed.',
   2800.00, NULL, NULL,
   ARRAY['police_report', 'proof_of_purchase', 'doorbell_footage'],
   ARRAY[]::TEXT[],
   'New claim submitted via phone. Awaiting initial document collection.',
   '2026-04-13 11:00:00-07', '2026-04-13 11:00:00-07'),

  ('c0000006-0000-0000-0000-000000000006', 'CLM-2026-000890', 'ffffffff-ffff-ffff-ffff-ffffffffffff', '55555555-5555-5555-5555-555555555555',
   'medical', 'submitted', '2026-04-10',
   'Emergency room visit for severe allergic reaction. Administered epinephrine and observed for 6 hours. Follow-up with allergist scheduled.',
   4500.00, NULL, NULL,
   ARRAY['er_records', 'itemized_bill', 'referral_letter'],
   ARRAY[]::TEXT[],
   'Claim submitted online. Waiting for hospital to send itemized bill.',
   '2026-04-11 19:30:00-07', '2026-04-11 19:30:00-07'),

  ('c0000007-0000-0000-0000-000000000007', 'CLM-2026-000234', 'a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', '66666666-6666-6666-6666-666666666666',
   'collision', 'under_review', '2026-03-28',
   'Sideswipe collision in parking garage at Westfield Mall. Other vehicle left the scene. Security camera footage obtained from mall.',
   3200.00, NULL, 'Sarah Chen',
   ARRAY['photos', 'repair_estimate', 'security_footage', 'police_report'],
   ARRAY['photos', 'repair_estimate', 'security_footage', 'police_report'],
   'All documents received. Adjuster reviewing security footage to identify other vehicle. Hit-and-run supplement filed.',
   '2026-03-29 08:45:00-07', '2026-04-08 13:20:00-07'),

  ('c0000008-0000-0000-0000-000000000008', 'CLM-2026-000345', 'b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1', '77777777-7777-7777-7777-777777777777',
   'fire_damage', 'documents_needed', '2026-03-05',
   'Kitchen fire caused by faulty electrical outlet. Fire department responded. Damage to kitchen cabinets, countertops, and appliances. Smoke damage throughout first floor.',
   45000.00, NULL, 'Mike Rodriguez',
   ARRAY['fire_dept_report', 'contractor_estimates', 'inventory_damaged_items', 'photos', 'temporary_housing_receipts'],
   ARRAY['fire_dept_report', 'photos'],
   'Major claim. Customer currently staying at hotel. Need contractor estimates and full inventory of damaged items. Fire marshal confirmed electrical cause.',
   '2026-03-06 07:00:00-08', '2026-04-01 09:15:00-07'),

  ('c0000009-0000-0000-0000-000000000009', 'CLM-2026-000567', 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', '88888888-8888-8888-8888-888888888888',
   'medical', 'approved', '2026-02-20',
   'Outpatient knee surgery (arthroscopic meniscus repair). Pre-authorized by PCP referral.',
   8500.00, 6800.00, 'Claims Auto-Process',
   ARRAY['surgical_records', 'itemized_bill', 'pcp_referral'],
   ARRAY['surgical_records', 'itemized_bill', 'pcp_referral'],
   'Approved after standard review. Patient responsibility: $1,700 (copay + coinsurance). Payment processing to provider.',
   '2026-02-25 10:00:00-08', '2026-03-10 14:30:00-07'),

  ('c0000010-0000-0000-0000-000000000010', 'CLM-2025-000999', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '22222222-2222-2222-2222-222222222222',
   'collision', 'paid', '2025-11-15',
   'Minor fender bender in parking lot. Scratches and small dent on rear passenger door.',
   1200.00, 700.00, 'Tom Bradley',
   ARRAY['photos', 'repair_estimate'],
   ARRAY['photos', 'repair_estimate'],
   'Claim paid. $700 approved after $500 deductible applied. Payment sent via direct deposit on 2025-12-20.',
   '2025-11-16 13:00:00-08', '2025-12-20 09:00:00-08'),

  ('c0000011-0000-0000-0000-000000000011', 'CLM-2026-000678', 'ffffffff-ffff-ffff-ffff-ffffffffffff', '55555555-5555-5555-5555-555555555555',
   'medical', 'documents_needed', '2026-01-15',
   'Physical therapy sessions (12 visits) for lower back pain. Referred by primary care physician.',
   3600.00, NULL, 'Claims Auto-Process',
   ARRAY['pt_records', 'itemized_bills', 'pcp_referral', 'treatment_plan'],
   ARRAY['pcp_referral'],
   'Need itemized bills for each PT session and the treatment plan from the physical therapist.',
   '2026-02-01 11:00:00-08', '2026-03-15 16:00:00-07'),

  ('c0000012-0000-0000-0000-000000000012', 'CLM-2025-000444', 'dddddddd-dddd-dddd-dddd-dddddddddddd', '33333333-3333-3333-3333-333333333333',
   'comprehensive', 'closed', '2025-08-20',
   'Hail damage to vehicle roof and hood during summer storm. Multiple dents and cracked windshield.',
   6800.00, 5300.00, 'Sarah Chen',
   ARRAY['photos', 'repair_estimate', 'weather_report'],
   ARRAY['photos', 'repair_estimate', 'weather_report'],
   'Claim closed. Repairs completed at certified body shop. $5,300 paid after $1,500 deductible. Customer satisfied with outcome.',
   '2025-08-21 10:00:00-07', '2025-09-30 15:00:00-07')
ON CONFLICT (id) DO NOTHING;

-- CALL LOGS (15)
INSERT INTO call_logs (id, elevenlabs_conversation_id, customer_id, direction, phone_number, status, duration_seconds, transcript, summary, outcome, tools_used, recording_url, started_at, ended_at) VALUES
  ('ca000001-0000-0000-0000-000000000001', 'conv_abc123def456', '11111111-1111-1111-1111-111111111111', 'inbound', '+14155550101', 'completed', 245,
   '[{"role":"agent","message":"Thank you for calling SafeGuard Insurance. My name is Alex. How can I help you today?"},{"role":"customer","message":"Hi, this is James Wilson. I want to check on my auto claim, the one from the car accident."},{"role":"agent","message":"Of course, Mr. Wilson. Let me pull up your account. I can see your claim CLM-2026-000456 for the collision incident. It is currently under review."},{"role":"customer","message":"Do you know what they still need from me?"},{"role":"agent","message":"Looking at your claim details, we still need a repair estimate from your body shop and photos of the damage. Once we receive those, the adjuster Sarah Chen can move forward with the evaluation."},{"role":"customer","message":"OK, I will get the estimate this week. Can I email the photos?"},{"role":"agent","message":"Absolutely. You can email them to claims@safeguard.com with your claim number CLM-2026-000456 in the subject line. Is there anything else I can help with?"},{"role":"customer","message":"No, that is all. Thanks."},{"role":"agent","message":"You are welcome, Mr. Wilson. Have a great day."}]',
   'James Wilson called to check status of auto collision claim CLM-2026-000456. Informed that claim is under review and still needs repair estimate and damage photos. Customer will provide this week.',
   'information_provided',
   ARRAY['lookup_customer', 'get_claim_status'],
   NULL,
   '2026-04-10 14:30:00-07', '2026-04-10 14:34:05-07'),

  ('ca000002-0000-0000-0000-000000000002', 'conv_ghi789jkl012', '22222222-2222-2222-2222-222222222222', 'outbound', '+14155550102', 'completed', 180,
   '[{"role":"agent","message":"Hello, may I speak with Maria Garcia? This is Alex from Pacific Shield Insurance."},{"role":"customer","message":"Yes, this is Maria."},{"role":"agent","message":"I am calling with good news about your windshield claim CLM-2026-000321. It has been approved for the full amount of $950."},{"role":"customer","message":"Oh great! When can I get it fixed?"},{"role":"agent","message":"We have authorized Safelite for the repair. They should contact you within 24 hours to schedule. Since this is a glass claim, there is no deductible."},{"role":"customer","message":"Perfect, thank you so much."},{"role":"agent","message":"You are welcome. Is there anything else I can help with today?"},{"role":"customer","message":"No, that is everything. Thanks for the call."}]',
   'Outbound call to Maria Garcia to notify her that windshield claim CLM-2026-000321 has been approved for $950. Safelite will contact her to schedule repair.',
   'claim_update_delivered',
   ARRAY['lookup_customer', 'get_claim_status'],
   NULL,
   '2026-03-19 10:00:00-07', '2026-03-19 10:03:00-07'),

  ('ca000003-0000-0000-0000-000000000003', 'conv_mno345pqr678', '33333333-3333-3333-3333-333333333333', 'inbound', '+14155550103', 'completed', 420,
   '[{"role":"agent","message":"Thank you for calling SafeGuard Insurance. How can I assist you today?"},{"role":"customer","message":"Yeah, I got a letter saying my claim was denied. Claim number CLM-2026-000789. That is ridiculous."},{"role":"agent","message":"I understand your frustration, Mr. Chen. Let me look into this for you. I can see the claim for pothole damage to your BMW X5."},{"role":"customer","message":"Right. How is pothole damage not covered? I pay over $200 a month for this policy."},{"role":"agent","message":"I completely understand your concern. The denial was based on Section 4.2 of your policy, which is the Road Hazard Exclusion. Pothole damage falls under road conditions that are excluded from collision coverage."},{"role":"customer","message":"That does not make any sense. Can I appeal this?"},{"role":"agent","message":"Yes, you absolutely can. You have until May 14th, 2026 to file an appeal. I would also recommend filing a claim with the City of Oakland since they may be liable for road maintenance. Would you like me to escalate this to a supervisor for further review?"},{"role":"customer","message":"Yes, please do that."},{"role":"agent","message":"I have created an escalation for you. A supervisor will contact you within 2 business days. Is there anything else?"},{"role":"customer","message":"No. Just make sure someone calls me back."},{"role":"agent","message":"Absolutely, Mr. Chen. You will hear from us soon. Thank you for your patience."}]',
   'Robert Chen called upset about denial of pothole damage claim CLM-2026-000789. Explained Section 4.2 Road Hazard Exclusion. Informed of appeal deadline (May 14). Customer requested supervisor review -- escalation created.',
   'escalation_created',
   ARRAY['lookup_customer', 'get_claim_status', 'get_policy_details', 'create_escalation'],
   NULL,
   '2026-03-05 16:15:00-08', '2026-03-05 16:22:00-08'),

  ('ca000004-0000-0000-0000-000000000004', 'conv_stu901vwx234', '44444444-4444-4444-4444-444444444444', 'inbound', '+14155550104', 'completed', 360,
   '[{"role":"agent","message":"Thank you for calling Pacific Shield Insurance. How may I help you?"},{"role":"customer","message":"Hi, I need to file a claim. A package was stolen from my porch."},{"role":"agent","message":"I am sorry to hear that. Let me get your information. Can I have your name and policy number?"},{"role":"customer","message":"Emily Davis. My policy is POL-2024-006789."},{"role":"agent","message":"Thank you, Emily. I have your home policy here. Can you describe what happened?"},{"role":"customer","message":"My laptop was delivered yesterday and someone stole it off my porch. I have Ring doorbell footage showing the guy taking it at 2:47 PM."},{"role":"agent","message":"That is very helpful that you have footage. What was the value of the laptop?"},{"role":"customer","message":"It was a MacBook Pro 16 inch. Cost about $2,800."},{"role":"agent","message":"I have filed your claim as CLM-2026-000112. We will need three things from you: a police report, proof of purchase for the laptop, and the doorbell camera footage. Can you provide those?"},{"role":"customer","message":"Yes, I already filed a police report. I will gather everything and send it over."},{"role":"agent","message":"Great. You can email everything to claims@pacificshield.com with claim number CLM-2026-000112 in the subject. A claims adjuster will be assigned within 48 hours."},{"role":"customer","message":"OK, thank you for your help."}]',
   'Emily Davis called to file a theft claim for stolen MacBook Pro ($2,800). Claim CLM-2026-000112 created. Customer has Ring footage and police report. Advised to submit documents via email.',
   'new_claim_filed',
   ARRAY['lookup_customer', 'get_policy_details', 'file_claim'],
   NULL,
   '2026-04-13 11:00:00-07', '2026-04-13 11:06:00-07'),

  ('ca000005-0000-0000-0000-000000000005', 'conv_yza567bcd890', '11111111-1111-1111-1111-111111111111', 'webrtc', NULL, 'completed', 195,
   '[{"role":"agent","message":"Hello, welcome to SafeGuard Insurance virtual assistant. How can I help you today?"},{"role":"customer","message":"Hi, I want to check what my auto policy covers. Specifically if I have rental car coverage."},{"role":"agent","message":"Let me pull up your policy. I can see your auto policy POL-2024-001234 for your 2022 Toyota Camry. Let me check the coverage details."},{"role":"customer","message":"Yes, that is the one."},{"role":"agent","message":"Your policy includes collision, comprehensive, uninsured motorist, and roadside assistance. However, I do not see rental car reimbursement as part of your current coverage."},{"role":"customer","message":"Can I add that?"},{"role":"agent","message":"Absolutely. Adding rental car coverage would be approximately $15 to $20 per month. Would you like me to schedule a callback with an agent to add this to your policy?"},{"role":"customer","message":"Yes, please. Tomorrow afternoon would work."},{"role":"agent","message":"I have scheduled a callback for tomorrow at 2 PM. An agent will call you at your number on file. Anything else?"},{"role":"customer","message":"No, that is it. Thanks."}]',
   'James Wilson inquired about rental car coverage on auto policy POL-2024-001234. Coverage not currently included. Scheduled callback for tomorrow to discuss adding rental coverage (~$15-20/mo).',
   'callback_scheduled',
   ARRAY['lookup_customer', 'get_policy_details', 'schedule_callback'],
   NULL,
   '2026-04-08 16:00:00-07', '2026-04-08 16:03:15-07'),

  ('ca000006-0000-0000-0000-000000000006', 'conv_efg123hij456', '55555555-5555-5555-5555-555555555555', 'inbound', '+14155550105', 'completed', 290,
   '[{"role":"agent","message":"Thank you for calling WellCare Plus. How can I assist you?"},{"role":"customer","message":"I recently went to the ER and I need to understand what my plan covers."},{"role":"agent","message":"I am happy to help. Can I have your name and policy number?"},{"role":"customer","message":"Michael Thompson, policy POL-2024-007890."},{"role":"agent","message":"Thank you, Michael. You have a PPO plan with a $3,000 deductible and $8,000 max out-of-pocket. For ER visits, you have a $250 copay plus 20 percent coinsurance after the deductible."},{"role":"customer","message":"I already submitted the claim. Is there an update?"},{"role":"agent","message":"I see claim CLM-2026-000890 was submitted on April 11th. It is in the initial review stage. We are waiting for the itemized bill from the hospital. Once received, processing typically takes 5 to 7 business days."},{"role":"customer","message":"OK, thanks for explaining that."},{"role":"agent","message":"Of course. Is there anything else I can help with?"},{"role":"customer","message":"No, I am good. Thank you."}]',
   'Michael Thompson called about ER visit coverage and claim CLM-2026-000890 status. Explained PPO benefits and that claim is pending itemized hospital bill.',
   'information_provided',
   ARRAY['lookup_customer', 'get_policy_details', 'get_claim_status'],
   NULL,
   '2026-04-14 09:20:00-07', '2026-04-14 09:24:50-07'),

  ('ca000007-0000-0000-0000-000000000007', 'conv_klm789nop012', '66666666-6666-6666-6666-666666666666', 'inbound', '+14155550106', 'completed', 310,
   '[{"role":"agent","message":"Pacific Shield Insurance, how can I help you today?"},{"role":"customer","message":"I need to report a car accident. Someone sideswiped me in a parking garage."},{"role":"agent","message":"I am sorry that happened. Are you OK? Was anyone injured?"},{"role":"customer","message":"No, no injuries. Just damage to my car. The other driver left without stopping."},{"role":"agent","message":"That is a hit-and-run situation. Let me file the claim for you. Can I get your name and policy details?"},{"role":"customer","message":"Sarah Kim, policy POL-2025-004567."},{"role":"agent","message":"I have your Tesla Model 3 policy. I have filed claim CLM-2026-000234. Since this is a hit-and-run, please make sure to file a police report and get any security camera footage from the mall."},{"role":"customer","message":"I already have the footage from mall security. I will file the police report today."},{"role":"agent","message":"Excellent. Please send all documents to our claims portal. Your adjuster will be Sarah Chen."}]',
   'Sarah Kim reported hit-and-run sideswipe in parking garage. Claim CLM-2026-000234 filed. Customer has security footage. Advised to file police report. Assigned to Sarah Chen.',
   'new_claim_filed',
   ARRAY['lookup_customer', 'get_policy_details', 'file_claim'],
   NULL,
   '2026-03-29 08:45:00-07', '2026-03-29 08:50:10-07'),

  ('ca000008-0000-0000-0000-000000000008', 'conv_qrs345tuv678', '77777777-7777-7777-7777-777777777777', 'inbound', '+14155550107', 'completed', 480,
   '[{"role":"agent","message":"SafeGuard Insurance, how may I assist you?"},{"role":"customer","message":"This is David Martinez. I am calling about my fire damage claim. It has been almost a month and I am still in a hotel."},{"role":"agent","message":"Mr. Martinez, I completely understand how stressful this situation is. Let me check on your claim CLM-2026-000345 right away."},{"role":"customer","message":"I have been waiting for the contractor estimate process. This is taking too long."},{"role":"agent","message":"I see your claim is in documents needed status. We have your fire department report and photos, but we still need contractor estimates, an inventory of damaged items, and your temporary housing receipts."},{"role":"customer","message":"I have a contractor coming tomorrow. But I need to know if SafeGuard will keep covering my hotel. It is costing $200 a night."},{"role":"agent","message":"Your policy does include additional living expenses coverage. Let me check the limit. Yes, you have up to $50,000 in ALE coverage. Please submit your hotel receipts and we can start reimbursing those immediately while the main claim is processed."},{"role":"customer","message":"OK, that is a relief. I will send the hotel receipts today."},{"role":"agent","message":"I would also recommend getting at least two contractor estimates to speed up the process. Would you like me to have your adjuster Mike Rodriguez call you to discuss the timeline?"},{"role":"customer","message":"Yes, please. This afternoon if possible."},{"role":"agent","message":"I will send him a message right now. Anything else I can help with?"},{"role":"customer","message":"No, just please get Mike to call me. Thank you."}]',
   'David Martinez called about fire damage claim CLM-2026-000345. Concerned about hotel costs and timeline. Confirmed ALE coverage up to $50K. Advised to submit hotel receipts for immediate reimbursement. Requested adjuster callback.',
   'callback_scheduled',
   ARRAY['lookup_customer', 'get_claim_status', 'get_policy_details', 'schedule_callback'],
   NULL,
   '2026-04-02 13:30:00-07', '2026-04-02 13:38:00-07'),

  ('ca000009-0000-0000-0000-000000000009', 'conv_wxy901zab234', '88888888-8888-8888-8888-888888888888', 'webrtc', NULL, 'completed', 210,
   '[{"role":"agent","message":"Welcome to WellCare Plus. How can I help you today?"},{"role":"customer","message":"Hi, I had knee surgery and my claim was approved. I wanted to confirm what I owe."},{"role":"agent","message":"Let me pull up your information. What is your name?"},{"role":"customer","message":"Jennifer Lee."},{"role":"agent","message":"I see your claim CLM-2026-000567 for arthroscopic knee surgery. It was approved for $6,800 of the $8,500 total. Your responsibility is $1,700, which includes your copay and coinsurance."},{"role":"customer","message":"Can I set up a payment plan for that?"},{"role":"agent","message":"Payment plans are handled directly by the provider. I would recommend contacting the surgical center billing department. They typically offer interest-free plans."},{"role":"customer","message":"OK, makes sense. Thank you."}]',
   'Jennifer Lee inquired about approved knee surgery claim CLM-2026-000567. Confirmed $1,700 patient responsibility. Advised to contact provider for payment plan options.',
   'information_provided',
   ARRAY['lookup_customer', 'get_claim_status'],
   NULL,
   '2026-03-12 11:15:00-07', '2026-03-12 11:18:30-07'),

  ('ca000010-0000-0000-0000-000000000010', 'conv_cde567fgh890', '11111111-1111-1111-1111-111111111111', 'inbound', '+14155550101', 'completed', 340,
   '[{"role":"agent","message":"SafeGuard Insurance, how can I help you?"},{"role":"customer","message":"Hi, this is James Wilson. I have a burst pipe at my house and there is water everywhere."},{"role":"agent","message":"Oh no, Mr. Wilson. First, have you been able to stop the water flow?"},{"role":"customer","message":"Yes, an emergency plumber just left. But my ceiling and hardwood floors are damaged."},{"role":"agent","message":"I am glad the immediate issue is handled. Let me file a claim on your home policy POL-2024-005678. Can you describe the extent of the damage?"},{"role":"customer","message":"The pipe burst in the upstairs bathroom. Water came through the ceiling into the living room. The hardwood floors are warped and the ceiling has a big water stain and is sagging."},{"role":"agent","message":"I have created claim CLM-2026-000457. Your adjuster will be Mike Rodriguez. We will need the plumber invoice, photos of all damage, a contractor repair estimate, and a list of any damaged personal property."},{"role":"customer","message":"OK, I have photos already and the plumber invoice. I will get a contractor out here."},{"role":"agent","message":"Your deductible on this policy is $2,500. Please submit what you have and we will get the process started. Mike will be in touch within 48 hours."},{"role":"customer","message":"Thanks for the quick help."}]',
   'James Wilson reported burst pipe and water damage. Claim CLM-2026-000457 filed on home policy. Plumber has resolved leak. Needs contractor estimate and inventory. Assigned to Mike Rodriguez.',
   'new_claim_filed',
   ARRAY['lookup_customer', 'get_policy_details', 'file_claim'],
   NULL,
   '2026-03-21 08:15:00-07', '2026-03-21 08:20:55-07'),

  ('ca000011-0000-0000-0000-000000000011', 'conv_ijk123lmn456', '22222222-2222-2222-2222-222222222222', 'outbound', '+14155550102', 'completed', 150,
   '[{"role":"agent","message":"Hello, is this Maria Garcia? This is Alex from Pacific Shield Insurance."},{"role":"customer","message":"Yes, hi."},{"role":"agent","message":"I am calling to confirm that the payment for your claim CLM-2025-000999 has been deposited into your account. The amount was $700."},{"role":"customer","message":"Yes, I saw it come through yesterday. Thank you."},{"role":"agent","message":"Great. Is there anything else you need regarding this claim?"},{"role":"customer","message":"No, everything is good. Thank you for following up."}]',
   'Outbound follow-up to confirm Maria Garcia received $700 payment for claim CLM-2025-000999. Payment confirmed received.',
   'claim_update_delivered',
   ARRAY['lookup_customer', 'get_claim_status'],
   NULL,
   '2025-12-21 10:00:00-08', '2025-12-21 10:02:30-08'),

  ('ca000012-0000-0000-0000-000000000012', 'conv_opq789rst012', '55555555-5555-5555-5555-555555555555', 'inbound', '+14155550105', 'completed', 230,
   '[{"role":"agent","message":"WellCare Plus, how may I help you?"},{"role":"customer","message":"Hi, Michael Thompson here. I got a letter about needing more documents for my physical therapy claim."},{"role":"agent","message":"Let me check that for you. I see claim CLM-2026-000678 for physical therapy sessions. We need the itemized bills for each session and the treatment plan from your therapist."},{"role":"customer","message":"I only have the referral from my doctor. My PT office said they would send the records directly."},{"role":"agent","message":"That is fine. Your PT office can fax records to 415-555-9999 or upload through our provider portal. We have the PCP referral on file already."},{"role":"customer","message":"How long will this take once you have everything?"},{"role":"agent","message":"Once all documents are received, processing takes about 5 to 7 business days. Your PPO plan covers physical therapy at 80 percent after deductible."},{"role":"customer","message":"OK, I will have my PT office send everything this week. Thanks."}]',
   'Michael Thompson called about PT claim CLM-2026-000678 document requirements. Needs itemized bills and treatment plan. PT office will submit directly. Explained 80% coverage after deductible.',
   'information_provided',
   ARRAY['lookup_customer', 'get_claim_status', 'get_policy_details'],
   NULL,
   '2026-03-18 14:00:00-07', '2026-03-18 14:03:50-07'),

  ('ca000013-0000-0000-0000-000000000013', 'conv_uvw345xyz678', '33333333-3333-3333-3333-333333333333', 'outbound', '+14155550103', 'completed', 160,
   '[{"role":"agent","message":"Hello Mr. Chen, this is Alex from SafeGuard Insurance. I am calling about your hail damage claim CLM-2025-000444."},{"role":"customer","message":"Oh right, is everything finalized?"},{"role":"agent","message":"Yes. The repairs are complete and the body shop has confirmed everything is done. We paid $5,300 after your $1,500 deductible. I am closing the claim today."},{"role":"customer","message":"The car looks great. They did a good job."},{"role":"agent","message":"Glad to hear that. If you notice any issues with the repairs within 90 days, you can contact us and we will reopen the claim. Is there anything else?"},{"role":"customer","message":"No, all good. Thanks for the follow-up."}]',
   'Outbound call to Robert Chen to close hail damage claim CLM-2025-000444. Repairs completed satisfactorily. Claim closed with $5,300 paid.',
   'claim_closed',
   ARRAY['lookup_customer', 'get_claim_status', 'update_claim_status'],
   NULL,
   '2025-09-30 15:00:00-07', '2025-09-30 15:02:40-07'),

  ('ca000014-0000-0000-0000-000000000014', 'conv_abc901def234', '11111111-1111-1111-1111-111111111111', 'webrtc', NULL, 'completed', 175,
   '[{"role":"agent","message":"Welcome to SafeGuard Insurance. How can I help?"},{"role":"customer","message":"I want to know when my home policy renews and what the premium will be."},{"role":"agent","message":"Let me look that up. Your home policy POL-2024-005678 renews on March 1st, 2027. Your current monthly premium is $210."},{"role":"customer","message":"Has the rate gone up recently?"},{"role":"agent","message":"Your rate has been stable since the policy started in March 2024. Any rate changes for the renewal period would be communicated 60 days before renewal."},{"role":"customer","message":"Good to know. And my earthquake coverage is still included?"},{"role":"agent","message":"Yes, earthquake coverage is active on your policy. Your dwelling coverage is $450,000 with a $2,500 deductible."},{"role":"customer","message":"Perfect, thanks."}]',
   'James Wilson inquired about home policy POL-2024-005678 renewal date and premium. Confirmed renewal March 2027, $210/mo, earthquake coverage active.',
   'information_provided',
   ARRAY['lookup_customer', 'get_policy_details'],
   NULL,
   '2026-04-05 09:30:00-07', '2026-04-05 09:32:55-07'),

  ('ca000015-0000-0000-0000-000000000015', 'conv_ghi567jkl890', '66666666-6666-6666-6666-666666666666', 'inbound', '+14155550106', 'completed', 200,
   '[{"role":"agent","message":"Pacific Shield Insurance, how can I help?"},{"role":"customer","message":"Hi, Sarah Kim. I am checking on my claim for the parking garage incident."},{"role":"agent","message":"Let me pull that up. Claim CLM-2026-000234 is currently under review. All of your documents have been received, including the security footage."},{"role":"customer","message":"Any idea when I will hear something?"},{"role":"agent","message":"Your adjuster Sarah Chen is reviewing the security footage to try to identify the other vehicle. These hit-and-run cases can take 10 to 14 business days. You should hear back by April 18th."},{"role":"customer","message":"OK. Will my rates go up because of this?"},{"role":"agent","message":"Since this was a hit-and-run where you were not at fault, this should not affect your rates. If the other driver is identified, we will pursue subrogation to recover costs."},{"role":"customer","message":"That is good to hear. Thanks."}]',
   'Sarah Kim called to check status of hit-and-run claim CLM-2026-000234. All documents received, under adjuster review. Expected resolution by April 18. Confirmed no rate impact for not-at-fault claim.',
   'information_provided',
   ARRAY['lookup_customer', 'get_claim_status'],
   NULL,
   '2026-04-09 15:45:00-07', '2026-04-09 15:48:25-07')
ON CONFLICT (id) DO NOTHING;

-- ESCALATIONS (3)
INSERT INTO escalations (id, call_log_id, claim_id, customer_id, reason, priority, status, assigned_to, notes, created_at) VALUES
  ('e0000001-0000-0000-0000-000000000001', 'ca000003-0000-0000-0000-000000000003', 'c0000004-0000-0000-0000-000000000004', '33333333-3333-3333-3333-333333333333',
   'Customer disputing denied pothole damage claim. Requesting supervisor review of policy exclusion interpretation.',
   'high', 'pending', NULL,
   'Customer was upset during call. Has appeal window until May 14, 2026. Review Section 4.2 Road Hazard Exclusion applicability.',
   '2026-03-05 16:22:00-08'),
  ('e0000002-0000-0000-0000-000000000002', 'ca000008-0000-0000-0000-000000000008', 'c0000008-0000-0000-0000-000000000008', '77777777-7777-7777-7777-777777777777',
   'Major fire damage claim -- customer displaced and staying in hotel. Needs expedited processing for ALE reimbursement.',
   'urgent', 'pending', NULL,
   'Customer incurring $200/night hotel costs. ALE coverage confirmed up to $50K. Hotel receipts need immediate processing while main claim is evaluated.',
   '2026-04-02 13:38:00-07'),
  ('e0000003-0000-0000-0000-000000000003', 'ca000001-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111',
   'Auto claim CLM-2026-000456 stalled -- repair estimate and photos outstanding for over a week. Need proactive follow-up.',
   'normal', 'pending', NULL,
   'Customer said during April 10 call he would provide documents this week. Follow up if not received by April 17.',
   '2026-04-12 09:00:00-07')
ON CONFLICT (id) DO NOTHING;

-- SCHEDULED CALLBACKS (2)
INSERT INTO scheduled_callbacks (id, call_log_id, customer_id, phone_number, scheduled_time, reason, status, created_at) VALUES
  ('ac000001-0000-0000-0000-000000000001', 'ca000005-0000-0000-0000-000000000005', '11111111-1111-1111-1111-111111111111', '+14155550101',
   '2026-04-17 14:00:00-07',
   'Customer interested in adding rental car coverage to auto policy POL-2024-001234. Quoted approximately $15-20/month.',
   'pending',
   '2026-04-08 16:03:00-07'),
  ('ac000002-0000-0000-0000-000000000002', 'ca000008-0000-0000-0000-000000000008', '77777777-7777-7777-7777-777777777777', '+14155550107',
   '2026-04-17 10:00:00-07',
   'Adjuster Mike Rodriguez to call customer about fire claim CLM-2026-000345 timeline and ALE reimbursement process.',
   'pending',
   '2026-04-02 13:38:00-07')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- DONE! Verify with:
-- SELECT 'customers' as tbl, count(*) FROM customers
-- UNION ALL SELECT 'policies', count(*) FROM policies
-- UNION ALL SELECT 'claims', count(*) FROM claims
-- UNION ALL SELECT 'call_logs', count(*) FROM call_logs
-- UNION ALL SELECT 'call_tool_executions', count(*) FROM call_tool_executions
-- UNION ALL SELECT 'escalations', count(*) FROM escalations
-- UNION ALL SELECT 'scheduled_callbacks', count(*) FROM scheduled_callbacks;
-- ============================================
