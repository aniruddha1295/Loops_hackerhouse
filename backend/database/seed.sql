-- ============================================
-- Insurance AI Call Agent — Seed Data (Demo v2)
-- ============================================
-- Indian-diaspora customers in the SF Bay Area
-- Story hero: Arjun Mehta (CLM-2026-000456)
-- Recurring adjuster: Neha Agarwal

-- Wipe existing data in FK-safe order
TRUNCATE TABLE
  call_tool_executions,
  scheduled_callbacks,
  escalations,
  call_logs,
  claims,
  policies,
  customers
RESTART IDENTITY CASCADE;

-- ============================================
-- CUSTOMERS (8)
-- ============================================
INSERT INTO customers (id, full_name, email, phone, date_of_birth, address) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Arjun Mehta',      'arjun.mehta@email.com',     '+14155550101', '1988-03-15', '742 Evergreen Terrace, San Francisco, CA 94110'),
  ('22222222-2222-2222-2222-222222222222', 'Priya Sharma',     'priya.sharma@email.com',    '+14155550102', '1991-07-22', '1847 Oak Avenue, San Jose, CA 95126'),
  ('33333333-3333-3333-3333-333333333333', 'Rohit Kapoor',     'rohit.kapoor@email.com',    '+14155550103', '1982-11-08', '523 Pine Street, Oakland, CA 94612'),
  ('44444444-4444-4444-4444-444444444444', 'Ananya Iyer',      'ananya.iyer@email.com',     '+14155550104', '1993-01-30', '2100 Market Street, San Francisco, CA 94114'),
  ('55555555-5555-5555-5555-555555555555', 'Vikram Singh',     'vikram.singh@email.com',    '+14155550105', '1985-09-12', '890 Broadway, Redwood City, CA 94063'),
  ('66666666-6666-6666-6666-666666666666', 'Kavya Reddy',      'kavya.reddy@email.com',     '+14155550106', '1995-05-18', '1234 Mission Blvd, Fremont, CA 94539'),
  ('77777777-7777-7777-7777-777777777777', 'Rahul Nair',       'rahul.nair@email.com',      '+14155550107', '1987-12-03', '456 El Camino Real, Palo Alto, CA 94301'),
  ('88888888-8888-8888-8888-888888888888', 'Divya Patel',      'divya.patel@email.com',     '+14155550108', '1978-06-25', '789 University Ave, Berkeley, CA 94710');

-- ============================================
-- POLICIES (10: 4 auto, 3 home, 2 health, 1 life)
-- ============================================
INSERT INTO policies (id, policy_number, customer_id, policy_type, provider, coverage_amount, deductible, premium_monthly, start_date, end_date, status, coverage_details) VALUES
  -- Arjun Mehta — Auto (DEMO HERO)
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'POL-2024-001234', '11111111-1111-1111-1111-111111111111', 'auto', 'SafeGuard Insurance', 50000, 1000, 185.50, '2024-01-15', '2027-01-15', 'active',
   '{"vehicle": "2023 Honda Accord", "vin": "1HGCV1F30PA123456", "liability": "100/300/100", "collision": true, "comprehensive": true, "uninsured_motorist": true, "roadside_assistance": true}'),

  -- Arjun Mehta — Home (used in live file_claim demo)
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'POL-2024-005678', '11111111-1111-1111-1111-111111111111', 'home', 'SafeGuard Insurance', 450000, 2500, 210.00, '2024-03-01', '2027-03-01', 'active',
   '{"property_type": "single_family", "square_feet": 1850, "year_built": 1998, "dwelling_coverage": 450000, "personal_property": 225000, "liability": 300000, "water_damage": true, "flood": false, "earthquake": true}'),

  -- Priya Sharma — Auto
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'POL-2024-002345', '22222222-2222-2222-2222-222222222222', 'auto', 'SafeGuard Insurance', 35000, 500, 145.00, '2024-06-01', '2026-06-01', 'active',
   '{"vehicle": "2022 Toyota Corolla", "vin": "5YFBURHE7NP543210", "liability": "50/100/50", "collision": true, "comprehensive": true, "uninsured_motorist": false, "roadside_assistance": false}'),

  -- Rohit Kapoor — Auto
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'POL-2023-003456', '33333333-3333-3333-3333-333333333333', 'auto', 'SafeGuard Insurance', 75000, 1500, 220.00, '2023-09-01', '2025-09-01', 'active',
   '{"vehicle": "2023 Tesla Model Y", "vin": "7SAYGDEE5NF278901", "liability": "250/500/250", "collision": true, "comprehensive": true, "uninsured_motorist": true, "roadside_assistance": true}'),

  -- Ananya Iyer — Home
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'POL-2024-006789', '44444444-4444-4444-4444-444444444444', 'home', 'SafeGuard Insurance', 320000, 2000, 175.00, '2024-02-15', '2027-02-15', 'active',
   '{"property_type": "condo", "square_feet": 1200, "year_built": 2010, "dwelling_coverage": 320000, "personal_property": 160000, "liability": 200000, "theft": true, "flood": false}'),

  -- Vikram Singh — Health
  ('ffffffff-ffff-ffff-ffff-ffffffffffff', 'POL-2024-007890', '55555555-5555-5555-5555-555555555555', 'health', 'SafeGuard Health', 500000, 3000, 450.00, '2024-01-01', '2026-12-31', 'active',
   '{"plan_type": "PPO", "network": "nationwide", "copay_primary": 25, "copay_specialist": 50, "prescription_coverage": true, "emergency_room_copay": 250, "dental": false, "vision": true, "max_out_of_pocket": 8000}'),

  -- Kavya Reddy — Auto
  ('a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', 'POL-2025-004567', '66666666-6666-6666-6666-666666666666', 'auto', 'SafeGuard Insurance', 40000, 750, 155.00, '2025-01-10', '2027-01-10', 'active',
   '{"vehicle": "2024 Hyundai Elantra", "vin": "KMHLN4AG4RU234567", "liability": "100/300/100", "collision": true, "comprehensive": true, "uninsured_motorist": true, "roadside_assistance": true}'),

  -- Rahul Nair — Home
  ('b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1', 'POL-2024-008901', '77777777-7777-7777-7777-777777777777', 'home', 'SafeGuard Insurance', 780000, 5000, 340.00, '2024-05-01', '2027-05-01', 'active',
   '{"property_type": "single_family", "square_feet": 2800, "year_built": 2015, "dwelling_coverage": 780000, "personal_property": 390000, "liability": 500000, "fire": true, "flood": false, "earthquake": true, "additional_living_expenses": 50000}'),

  -- Divya Patel — Health
  ('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'POL-2024-009012', '88888888-8888-8888-8888-888888888888', 'health', 'SafeGuard Health', 750000, 2000, 520.00, '2024-01-01', '2026-12-31', 'active',
   '{"plan_type": "HMO", "network": "california", "copay_primary": 15, "copay_specialist": 35, "prescription_coverage": true, "dental": true, "vision": true, "max_out_of_pocket": 6000}'),

  -- Divya Patel — Life
  ('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'POL-2024-010123', '88888888-8888-8888-8888-888888888888', 'life', 'SafeGuard Insurance', 1000000, 0, 85.00, '2024-04-01', '2054-04-01', 'active',
   '{"term_years": 30, "beneficiary": "Rohan Patel (spouse)", "type": "term_life", "accidental_death": true, "waiver_of_premium": true}');

-- ============================================
-- CLAIMS (11)
-- NOTE: Arjun's home claim intentionally DOES NOT exist.
-- During live demo, file_claim will create it.
-- ============================================
INSERT INTO claims (id, claim_number, policy_id, customer_id, claim_type, status, incident_date, incident_description, claimed_amount, approved_amount, assigned_adjuster, documents_required, documents_received, notes, filed_at, updated_at) VALUES
  -- Arjun Mehta — DEMO HERO: auto collision, under review, missing documents
  ('c0000001-0000-0000-0000-000000000001', 'CLM-2026-000456', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111',
   'collision', 'under_review', '2026-04-10',
   'Rear-ended at intersection of Market St and 5th Ave while stopped at a red light. Other driver ran the light. Moderate damage to rear bumper, trunk lid, and tail lights. No injuries reported. Police report filed (#SF-2026-04-8834).',
   8275.00, NULL, 'Neha Agarwal',
   ARRAY['police_report', 'repair_estimate', 'photos', 'other_driver_info'],
   ARRAY['police_report', 'other_driver_info'],
   'Awaiting repair estimate from customer-preferred body shop. Damage photos still pending. Other driver''s insurance (Progressive, policy #PG-445566) has been contacted.',
   '2026-04-11 10:30:00-07', '2026-04-17 14:15:00-07'),

  -- Priya Sharma — approved windshield (smooth happy-path example)
  ('c0000003-0000-0000-0000-000000000003', 'CLM-2026-000321', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '22222222-2222-2222-2222-222222222222',
   'windshield', 'approved', '2026-04-05',
   'Rock struck windshield on Highway 101 causing a large crack across the driver side. Full replacement required.',
   925.00, 925.00, 'Neha Agarwal',
   ARRAY['photos', 'repair_estimate'],
   ARRAY['photos', 'repair_estimate'],
   'Claim approved for full windshield replacement. Safelite authorized for repair. Zero deductible for glass claims under this policy.',
   '2026-04-06 09:00:00-07', '2026-04-12 16:45:00-07'),

  -- Rohit Kapoor — DENIED claim (used in escalation scenarios)
  ('c0000004-0000-0000-0000-000000000004', 'CLM-2026-000789', 'dddddddd-dddd-dddd-dddd-dddddddddddd', '33333333-3333-3333-3333-333333333333',
   'collision', 'denied', '2026-02-14',
   'Vehicle struck a pothole causing damage to front right wheel and suspension. Customer contends the City of Oakland is responsible.',
   4180.00, 0, 'Deepak Gupta',
   ARRAY['photos', 'repair_estimate', 'police_report'],
   ARRAY['photos', 'repair_estimate'],
   'Claim denied. Pothole damage is excluded under Section 4.2 (Road Hazard Exclusion). Customer advised to file with City of Oakland. Appeal window closes 2026-05-14.',
   '2026-02-15 14:20:00-08', '2026-03-01 10:00:00-08'),

  -- Ananya Iyer — recent theft, fresh submission
  ('c0000005-0000-0000-0000-000000000005', 'CLM-2026-000112', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '44444444-4444-4444-4444-444444444444',
   'theft', 'submitted', '2026-04-18',
   'Package containing a MacBook Pro 16" stolen from front porch. Ring doorbell footage captures theft at 2:47 PM. Police report filed the same day.',
   2785.00, NULL, NULL,
   ARRAY['police_report', 'proof_of_purchase', 'doorbell_footage'],
   ARRAY[]::text[],
   'New claim submitted via phone. Awaiting initial document collection.',
   '2026-04-19 11:00:00-07', '2026-04-19 11:00:00-07'),

  -- Vikram Singh — fresh ER claim
  ('c0000006-0000-0000-0000-000000000006', 'CLM-2026-000890', 'ffffffff-ffff-ffff-ffff-ffffffffffff', '55555555-5555-5555-5555-555555555555',
   'medical', 'submitted', '2026-04-16',
   'Emergency room visit for severe allergic reaction. Administered epinephrine and observed for 6 hours. Follow-up with allergist scheduled.',
   4485.00, NULL, NULL,
   ARRAY['er_records', 'itemized_bill', 'referral_letter'],
   ARRAY[]::text[],
   'Claim submitted online. Waiting on hospital to send itemized bill.',
   '2026-04-17 19:30:00-07', '2026-04-17 19:30:00-07'),

  -- Kavya Reddy — hit-and-run under review
  ('c0000007-0000-0000-0000-000000000007', 'CLM-2026-000234', 'a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', '66666666-6666-6666-6666-666666666666',
   'collision', 'under_review', '2026-04-02',
   'Sideswipe collision in parking garage at Westfield Mall. Other vehicle left the scene. Security camera footage obtained from mall.',
   3220.00, NULL, 'Neha Agarwal',
   ARRAY['photos', 'repair_estimate', 'security_footage', 'police_report'],
   ARRAY['photos', 'repair_estimate', 'security_footage', 'police_report'],
   'All documents received. Adjuster reviewing security footage to identify other vehicle. Hit-and-run supplement filed.',
   '2026-04-03 08:45:00-07', '2026-04-15 13:20:00-07'),

  -- Rahul Nair — fire damage, documents_needed (high-drama open claim)
  ('c0000008-0000-0000-0000-000000000008', 'CLM-2026-000345', 'b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1', '77777777-7777-7777-7777-777777777777',
   'fire_damage', 'documents_needed', '2026-03-28',
   'Kitchen fire caused by faulty electrical outlet. Fire department responded. Damage to cabinets, countertops, appliances. Smoke damage across the first floor.',
   44800.00, NULL, 'Rajiv Khanna',
   ARRAY['fire_dept_report', 'contractor_estimates', 'inventory_damaged_items', 'photos', 'temporary_housing_receipts'],
   ARRAY['fire_dept_report', 'photos'],
   'Major claim. Customer currently in temporary housing. Need contractor estimates and full inventory. Fire marshal confirmed electrical cause.',
   '2026-03-29 07:00:00-07', '2026-04-15 09:15:00-07'),

  -- Divya Patel — approved knee surgery (health happy-path)
  ('c0000009-0000-0000-0000-000000000009', 'CLM-2026-000567', 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', '88888888-8888-8888-8888-888888888888',
   'medical', 'approved', '2026-03-15',
   'Outpatient knee surgery (arthroscopic meniscus repair). Pre-authorized by PCP referral.',
   8500.00, 6800.00, 'Claims Auto-Process',
   ARRAY['surgical_records', 'itemized_bill', 'pcp_referral'],
   ARRAY['surgical_records', 'itemized_bill', 'pcp_referral'],
   'Approved after standard review. Patient responsibility: $1,700 (copay + coinsurance). Payment processing to provider.',
   '2026-03-18 10:00:00-07', '2026-03-28 14:30:00-07'),

  -- Priya Sharma — paid previous claim (historical)
  ('c0000010-0000-0000-0000-000000000010', 'CLM-2025-000999', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '22222222-2222-2222-2222-222222222222',
   'collision', 'paid', '2025-11-15',
   'Minor fender bender in parking lot. Scratches and small dent on rear passenger door.',
   1180.00, 680.00, 'Deepak Gupta',
   ARRAY['photos', 'repair_estimate'],
   ARRAY['photos', 'repair_estimate'],
   'Claim paid. $680 approved after $500 deductible. Direct deposit sent 2025-12-20.',
   '2025-11-16 13:00:00-08', '2025-12-20 09:00:00-08'),

  -- Vikram Singh — PT claim, documents needed
  ('c0000011-0000-0000-0000-000000000011', 'CLM-2026-000678', 'ffffffff-ffff-ffff-ffff-ffffffffffff', '55555555-5555-5555-5555-555555555555',
   'medical', 'documents_needed', '2026-01-15',
   'Physical therapy sessions (12 visits) for lower back pain. Referred by primary care physician.',
   3575.00, NULL, 'Claims Auto-Process',
   ARRAY['pt_records', 'itemized_bills', 'pcp_referral', 'treatment_plan'],
   ARRAY['pcp_referral'],
   'Need itemized bills for each session and the treatment plan from the physical therapist.',
   '2026-02-01 11:00:00-08', '2026-03-15 16:00:00-07'),

  -- Rohit Kapoor — closed hail damage (historical)
  ('c0000012-0000-0000-0000-000000000012', 'CLM-2025-000444', 'dddddddd-dddd-dddd-dddd-dddddddddddd', '33333333-3333-3333-3333-333333333333',
   'comprehensive', 'closed', '2025-08-20',
   'Hail damage to vehicle roof and hood during summer storm. Multiple dents and cracked windshield.',
   6775.00, 5275.00, 'Neha Agarwal',
   ARRAY['photos', 'repair_estimate', 'weather_report'],
   ARRAY['photos', 'repair_estimate', 'weather_report'],
   'Repairs completed at certified body shop. $5,275 paid after $1,500 deductible. Customer satisfied.',
   '2025-08-21 10:00:00-07', '2025-09-30 15:00:00-07');

-- ============================================
-- CALL LOGS (10, mostly recent, mix of directions)
-- ============================================
INSERT INTO call_logs (id, elevenlabs_conversation_id, customer_id, direction, phone_number, status, duration_seconds, transcript, summary, outcome, tools_used, recording_url, started_at, ended_at) VALUES
  -- Arjun Mehta — prior status inquiry
  ('ca000001-0000-0000-0000-000000000001', 'conv_arjun_status_001', '11111111-1111-1111-1111-111111111111', 'inbound', '+14155550101', 'completed', 245,
   '[{"role":"agent","message":"Hi, this is Ansh from SafeGuard Insurance claims. How can I help you today?"},{"role":"customer","message":"Hi Ansh, this is Arjun Mehta. I want to check on my auto claim from the accident last week."},{"role":"agent","message":"Of course, Mr. Mehta. Could you give me the claim number?"},{"role":"customer","message":"CLM-2026-000456."},{"role":"agent","message":"Got it. Your collision claim is currently under review with Neha Agarwal. It looks like we are still waiting on a few documents from you. Would you like me to tell you what is missing?"},{"role":"customer","message":"Yes please."},{"role":"agent","message":"We still need your repair estimate and photos of the damage. Once those come in, Neha can move forward with the evaluation."},{"role":"customer","message":"Alright, I will have those by this week."},{"role":"agent","message":"Thank you. Is there anything else I can help you with today?"},{"role":"customer","message":"No, that is all for now."},{"role":"agent","message":"Thanks for calling SafeGuard. Have a great day."}]',
   'Arjun Mehta called to check auto collision claim CLM-2026-000456. Informed claim is under review, missing repair estimate and photos. Will provide this week.',
   'information_provided',
   ARRAY['lookup_claim', 'check_documents'],
   NULL,
   '2026-04-17 14:30:00-07', '2026-04-17 14:34:05-07'),

  -- Priya Sharma — approved notification
  ('ca000002-0000-0000-0000-000000000002', 'conv_priya_approval_001', '22222222-2222-2222-2222-222222222222', 'outbound', '+14155550102', 'completed', 180,
   '[{"role":"agent","message":"Hello, may I speak with Priya Sharma? This is Ansh from SafeGuard Insurance."},{"role":"customer","message":"Yes, this is Priya."},{"role":"agent","message":"Great news — your windshield claim CLM-2026-000321 has been approved for the full amount of $925."},{"role":"customer","message":"Oh wonderful. When can I get it fixed?"},{"role":"agent","message":"We have authorized Safelite for the repair. They will contact you within 24 hours. Since this is a glass claim, there is no deductible."},{"role":"customer","message":"Perfect, thank you."},{"role":"agent","message":"You are welcome. Is there anything else I can help with today?"},{"role":"customer","message":"No, that is everything."}]',
   'Outbound call to Priya Sharma notifying windshield claim CLM-2026-000321 approved for $925. Safelite will schedule repair.',
   'claim_update_delivered',
   ARRAY['lookup_claim'],
   NULL,
   '2026-04-13 10:00:00-07', '2026-04-13 10:03:00-07'),

  -- Rohit Kapoor — denied claim dispute (escalation)
  ('ca000003-0000-0000-0000-000000000003', 'conv_rohit_dispute_001', '33333333-3333-3333-3333-333333333333', 'inbound', '+14155550103', 'completed', 420,
   '[{"role":"agent","message":"Hi, this is Ansh from SafeGuard Insurance claims. How can I help you today?"},{"role":"customer","message":"My claim was denied. CLM-2026-000789. This is unacceptable."},{"role":"agent","message":"I am really sorry to hear that, Mr. Kapoor. Let me look into this for you right away."},{"role":"customer","message":"Fine. It is for the pothole damage to my Tesla."},{"role":"agent","message":"I see the denial was based on Section 4.2, the Road Hazard Exclusion. Pothole damage falls outside collision coverage."},{"role":"customer","message":"That makes no sense. I pay $220 a month for this policy. Can I appeal this?"},{"role":"agent","message":"Absolutely. You have until May 14th to file an appeal. Would you like me to escalate this to a supervisor for further review?"},{"role":"customer","message":"Yes, please do that."},{"role":"agent","message":"I have escalated your case with high priority. A senior specialist will contact you within 2 business hours. Is there anything else?"},{"role":"customer","message":"No, just make sure someone calls me."}]',
   'Rohit Kapoor disputed denied pothole claim CLM-2026-000789. Agent explained Section 4.2 exclusion, offered appeal path, escalated to supervisor with high priority.',
   'escalation_created',
   ARRAY['lookup_claim', 'escalate_to_human'],
   NULL,
   '2026-03-05 16:15:00-08', '2026-03-05 16:22:00-08'),

  -- Ananya Iyer — new theft claim
  ('ca000004-0000-0000-0000-000000000004', 'conv_ananya_theft_001', '44444444-4444-4444-4444-444444444444', 'inbound', '+14155550104', 'completed', 360,
   '[{"role":"agent","message":"Hi, this is Ansh from SafeGuard Insurance claims. How can I help you today?"},{"role":"customer","message":"My laptop was stolen from my porch. I need to file a claim."},{"role":"agent","message":"I am sorry to hear that. Can you give me your policy number?"},{"role":"customer","message":"POL-2024-006789."},{"role":"agent","message":"Thank you, Ananya. What was the value of the laptop?"},{"role":"customer","message":"A MacBook Pro 16 inch, around $2,785."},{"role":"agent","message":"I have filed your claim. Your claim number is CLM-2026-000112. We will need a police report, proof of purchase, and the Ring doorbell footage."},{"role":"customer","message":"I already have all of that."},{"role":"agent","message":"Great. Email those to claims@safeguard.com with your claim number in the subject. Your adjuster will be assigned within 48 hours."}]',
   'Ananya Iyer filed theft claim CLM-2026-000112 for stolen MacBook Pro. Has police report and doorbell footage.',
   'new_claim_filed',
   ARRAY['check_policy', 'file_claim'],
   NULL,
   '2026-04-19 11:00:00-07', '2026-04-19 11:06:00-07'),

  -- Arjun Mehta — earlier policy check via browser
  ('ca000005-0000-0000-0000-000000000005', 'conv_arjun_policy_001', '11111111-1111-1111-1111-111111111111', 'webrtc', NULL, 'completed', 195,
   '[{"role":"agent","message":"Hi, this is Ansh from SafeGuard Insurance claims. How can I help you today?"},{"role":"customer","message":"I want to check what my auto policy covers. Does it include rental car coverage?"},{"role":"agent","message":"Let me pull up your policy. What is your policy number?"},{"role":"customer","message":"POL-2024-001234."},{"role":"agent","message":"You have collision, comprehensive, uninsured motorist, and roadside assistance. Rental car coverage is not currently included."},{"role":"customer","message":"Can I add it?"},{"role":"agent","message":"Absolutely. That would be around $15 to $20 per month. Would you like me to schedule a callback with an agent to add it?"},{"role":"customer","message":"Yes, tomorrow afternoon please."},{"role":"agent","message":"I have scheduled a callback for tomorrow at 2 PM. Anything else?"},{"role":"customer","message":"No thanks."}]',
   'Arjun Mehta inquired about rental coverage on auto policy. Not currently included. Callback scheduled for next-day discussion.',
   'callback_scheduled',
   ARRAY['check_policy', 'schedule_callback'],
   NULL,
   '2026-04-14 16:00:00-07', '2026-04-14 16:03:15-07'),

  -- Vikram Singh — ER coverage question
  ('ca000006-0000-0000-0000-000000000006', 'conv_vikram_er_001', '55555555-5555-5555-5555-555555555555', 'inbound', '+14155550105', 'completed', 290,
   '[{"role":"agent","message":"Hi, this is Ansh from SafeGuard Health. How can I help you today?"},{"role":"customer","message":"I went to the ER last night and I want to understand my coverage."},{"role":"agent","message":"Happy to help. Policy number?"},{"role":"customer","message":"POL-2024-007890."},{"role":"agent","message":"You have a PPO plan with a $3,000 deductible and $8,000 max out-of-pocket. ER visits have a $250 copay plus 20 percent coinsurance after the deductible."},{"role":"customer","message":"OK. Any update on my submitted claim?"},{"role":"agent","message":"Claim CLM-2026-000890 is in initial review. We are waiting for the itemized hospital bill. Processing takes 5 to 7 business days after that."},{"role":"customer","message":"Thanks for explaining."}]',
   'Vikram Singh asked about ER coverage and status of claim CLM-2026-000890. Claim pending itemized bill.',
   'information_provided',
   ARRAY['check_policy', 'lookup_claim'],
   NULL,
   '2026-04-17 09:20:00-07', '2026-04-17 09:24:50-07'),

  -- Kavya Reddy — hit-and-run file_claim
  ('ca000007-0000-0000-0000-000000000007', 'conv_kavya_hitrun_001', '66666666-6666-6666-6666-666666666666', 'inbound', '+14155550106', 'completed', 310,
   '[{"role":"agent","message":"Hi, this is Ansh from SafeGuard Insurance claims. How can I help you today?"},{"role":"customer","message":"I need to report an accident. Someone sideswiped me in a parking garage and left."},{"role":"agent","message":"I am really sorry. Are you or anyone else injured?"},{"role":"customer","message":"No, just damage to my car."},{"role":"agent","message":"That is a hit and run situation. Policy number please?"},{"role":"customer","message":"POL-2025-004567."},{"role":"agent","message":"I have filed claim CLM-2026-000234. Since this is a hit-and-run, please file a police report and secure any security camera footage."},{"role":"customer","message":"I already have the mall security footage."},{"role":"agent","message":"Excellent. Your adjuster will be Neha Agarwal."}]',
   'Kavya Reddy reported hit-and-run sideswipe, filed claim CLM-2026-000234. Has security footage. Assigned to Neha Agarwal.',
   'new_claim_filed',
   ARRAY['check_policy', 'file_claim'],
   NULL,
   '2026-04-03 08:45:00-07', '2026-04-03 08:50:10-07'),

  -- Rahul Nair — fire damage urgency
  ('ca000008-0000-0000-0000-000000000008', 'conv_rahul_fire_001', '77777777-7777-7777-7777-777777777777', 'inbound', '+14155550107', 'completed', 480,
   '[{"role":"agent","message":"Hi, this is Ansh from SafeGuard Insurance claims. How can I help you today?"},{"role":"customer","message":"This is Rahul Nair. I am calling about my fire damage claim. It has been weeks and I am still in a hotel."},{"role":"agent","message":"Mr. Nair, I completely understand how stressful this is. Let me check on your claim right away."},{"role":"customer","message":"It is CLM-2026-000345."},{"role":"agent","message":"I see the claim is in documents needed status. We have your fire department report and photos, but we still need contractor estimates, an inventory of damaged items, and temporary housing receipts."},{"role":"customer","message":"The hotel is costing $200 a night. Will SafeGuard keep covering it?"},{"role":"agent","message":"Yes. You have up to $50,000 in Additional Living Expenses coverage. Submit your receipts and we can start reimbursing those while the main claim is evaluated. Would you like me to escalate this with urgent priority?"},{"role":"customer","message":"Yes please."},{"role":"agent","message":"I have escalated this with urgent priority. Rajiv Khanna will contact you within 2 hours."}]',
   'Rahul Nair called about fire damage claim CLM-2026-000345. Concerned about hotel costs. Confirmed ALE coverage. Escalated with urgent priority.',
   'escalation_created',
   ARRAY['lookup_claim', 'check_policy', 'escalate_to_human'],
   NULL,
   '2026-04-15 13:30:00-07', '2026-04-15 13:38:00-07'),

  -- Divya Patel — knee surgery confirmation
  ('ca000009-0000-0000-0000-000000000009', 'conv_divya_surgery_001', '88888888-8888-8888-8888-888888888888', 'webrtc', NULL, 'completed', 210,
   '[{"role":"agent","message":"Hi, this is Ansh from SafeGuard Health. How can I help you today?"},{"role":"customer","message":"My knee surgery claim was approved. I wanted to confirm what I owe."},{"role":"agent","message":"Sure. Claim number?"},{"role":"customer","message":"CLM-2026-000567."},{"role":"agent","message":"Approved for $6,800 of the $8,500 total. Your responsibility is $1,700."},{"role":"customer","message":"Thank you."}]',
   'Divya Patel confirmed approved knee surgery claim. Patient owes $1,700.',
   'information_provided',
   ARRAY['lookup_claim'],
   NULL,
   '2026-03-29 11:15:00-07', '2026-03-29 11:18:30-07'),

  -- Kavya Reddy — status check-in
  ('ca000015-0000-0000-0000-000000000015', 'conv_kavya_status_001', '66666666-6666-6666-6666-666666666666', 'inbound', '+14155550106', 'completed', 200,
   '[{"role":"agent","message":"Hi, this is Ansh from SafeGuard Insurance claims. How can I help you today?"},{"role":"customer","message":"Checking in on my claim for the parking garage incident."},{"role":"agent","message":"Claim number please?"},{"role":"customer","message":"CLM-2026-000234."},{"role":"agent","message":"All documents received. Neha Agarwal is reviewing the security footage to identify the other vehicle. Expect an update by April 22nd."},{"role":"customer","message":"Will my rates go up?"},{"role":"agent","message":"Since this is a hit-and-run where you are not at fault, your rates should not be affected."},{"role":"customer","message":"Thanks."}]',
   'Kavya Reddy checked status of claim CLM-2026-000234. All docs received. Expected update April 22.',
   'information_provided',
   ARRAY['lookup_claim'],
   NULL,
   '2026-04-18 15:45:00-07', '2026-04-18 15:48:25-07');

-- ============================================
-- ESCALATIONS (3 pending)
-- ============================================
INSERT INTO escalations (id, call_log_id, claim_id, customer_id, reason, priority, status, assigned_to, notes, created_at) VALUES
  ('e0000001-0000-0000-0000-000000000001', 'ca000003-0000-0000-0000-000000000003', 'c0000004-0000-0000-0000-000000000004', '33333333-3333-3333-3333-333333333333',
   'Customer disputing denied pothole damage claim. Requesting supervisor review of policy exclusion interpretation.',
   'high', 'pending', NULL,
   'Customer was upset during call. Appeal window until May 14, 2026. Review Section 4.2 Road Hazard Exclusion applicability.',
   '2026-03-05 16:22:00-08'),

  ('e0000002-0000-0000-0000-000000000002', 'ca000008-0000-0000-0000-000000000008', 'c0000008-0000-0000-0000-000000000008', '77777777-7777-7777-7777-777777777777',
   'Major fire damage claim — customer displaced in hotel. Needs expedited processing for ALE reimbursement.',
   'urgent', 'pending', NULL,
   'Customer incurring $200/night hotel costs. ALE coverage confirmed up to $50K. Hotel receipts need immediate processing.',
   '2026-04-15 13:38:00-07'),

  ('e0000003-0000-0000-0000-000000000003', 'ca000001-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111',
   'Auto claim CLM-2026-000456 stalled — repair estimate and photos outstanding. Proactive follow-up needed.',
   'normal', 'pending', NULL,
   'Customer said during April 17 call he would provide documents this week. Follow up if not received by April 21.',
   '2026-04-18 09:00:00-07');

-- ============================================
-- SCHEDULED CALLBACKS (2 pending, recent)
-- ============================================
INSERT INTO scheduled_callbacks (id, call_log_id, customer_id, phone_number, scheduled_time, reason, status, created_at) VALUES
  ('ac000001-0000-0000-0000-000000000001', 'ca000005-0000-0000-0000-000000000005', '11111111-1111-1111-1111-111111111111', '+14155550101',
   '2026-04-22 14:00:00-07',
   'Customer interested in adding rental car coverage to auto policy POL-2024-001234. Quote approx $15-20/month.',
   'pending',
   '2026-04-14 16:03:00-07'),

  ('ac000002-0000-0000-0000-000000000002', 'ca000008-0000-0000-0000-000000000008', '77777777-7777-7777-7777-777777777777', '+14155550107',
   '2026-04-22 10:00:00-07',
   'Rajiv Khanna to call Rahul Nair re: fire claim CLM-2026-000345 timeline and ALE reimbursement process.',
   'pending',
   '2026-04-15 13:38:00-07');
