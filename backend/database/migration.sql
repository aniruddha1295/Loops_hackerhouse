-- ============================================
-- Insurance AI Call Agent — Database Migration
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
