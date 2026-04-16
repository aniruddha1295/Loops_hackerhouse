# ClaimsAgent — AI Insurance Claims Call Agent

> Loops Hacker House Shanghai | April 2026
> AI-powered voice agent that handles insurance claims calls end-to-end.

---

## What We're Building

An AI call agent that sits between insurance companies and policyholders:

- **B2C:** Consumer calls → AI checks claim status, files new claims, identifies missing documents, schedules callbacks
- **B2B:** Insurer deploys our AI on their phone line → handles 80% of routine claims calls → escalates complex ones to humans
- **Demo:** Live phone call on stage + real-time dashboard showing everything happening

---

## Tech Stack

| Layer | Technology | Owned By |
|-------|-----------|----------|
| Frontend | React + Tailwind + Vite → **Vercel** | Ansh |
| Backend (Tool Endpoints) | Fastify + TypeScript → **Railway** | Tanmay |
| Backend (DB + Dashboard APIs) | Fastify + TypeScript → **Railway** | Anish |
| Database | **Supabase** (Postgres) | Aniruddha (setup) |
| Voice AI | **ElevenLabs** Conversational AI (hackathon sponsor) | Aniruddha (config) |
| Phone Calls | **Twilio** (native ElevenLabs integration) | Aniruddha (setup) |
| Deployment | Railway + Vercel | Aniruddha (Day 4) |

---

## Architecture

```
Phone Call → Twilio → ElevenLabs Conversational AI (STT + LLM + TTS)
                           │
                           ├── Knowledge Base (insurance PDFs uploaded to ElevenLabs)
                           │
                           ├── Tool webhooks ──→ Fastify Backend (Railway)
                           │                         │
                           │                    Supabase (Postgres)
                           │
                           └── Human handoff / agent transfer

Browser → ElevenLabs React SDK (WebRTC) → Same AI Agent → Same Backend → Same DB

Dashboard (Vercel) → Supabase (real-time subscriptions) + Backend APIs
```

---

## Repo Structure

```
Loops_hackerhouse/
├── backend/
│   ├── src/
│   │   ├── server.ts                    [Anish] Fastify entry point
│   │   ├── config/
│   │   │   └── environment.ts           [Anish] Env var validation
│   │   ├── plugins/
│   │   │   ├── supabase.ts              [Anish] Supabase client plugin
│   │   │   └── cors.ts                  [Anish] CORS config
│   │   ├── routes/
│   │   │   ├── webhook-tools.ts         [Tanmay] 6 tool endpoints (ElevenLabs calls these)
│   │   │   ├── calls.ts                 [Anish] GET /api/calls endpoints
│   │   │   ├── claims.ts               [Anish] GET /api/claims endpoints
│   │   │   ├── analytics.ts            [Anish] GET /api/analytics
│   │   │   └── webhooks.ts             [Anish] ElevenLabs post-call webhook
│   │   ├── services/
│   │   │   ├── claims-service.ts        [Tanmay] Claim lookup, filing logic
│   │   │   ├── policy-service.ts        [Tanmay] Policy lookup logic
│   │   │   ├── escalation-service.ts    [Tanmay] Escalation creation
│   │   │   ├── callback-service.ts      [Tanmay] Callback scheduling
│   │   │   └── call-log-service.ts      [Anish] Call logging
│   │   └── types/
│   │       └── index.ts                 [Anish] Shared TypeScript interfaces
│   ├── database/
│   │   ├── migration.sql                [Anish] All 7 tables + indexes
│   │   └── seed.sql                     [Anish] Demo data
│   ├── package.json
│   ├── tsconfig.json
│   └── Dockerfile
│
├── frontend/
│   ├── src/
│   │   ├── App.tsx                      [Ansh] Router setup
│   │   ├── main.tsx                     [Ansh] Entry point
│   │   ├── lib/
│   │   │   ├── supabase.ts             [Ansh] Supabase client
│   │   │   └── api.ts                  [Ansh] Axios client for backend
│   │   ├── pages/
│   │   │   ├── ClaimsList.tsx           [Ansh] Claims table + filters
│   │   │   ├── ClaimDetail.tsx          [Ansh] Single claim view
│   │   │   ├── LiveCallView.tsx         [Ansh] Real-time transcript + tool cards
│   │   │   ├── CallHistory.tsx          [Ansh] Past calls list
│   │   │   ├── Analytics.tsx            [Ansh] Stats + charts
│   │   │   └── AgentConfig.tsx          [Ansh] Agent settings display
│   │   ├── components/
│   │   │   ├── Layout.tsx               [Ansh] Sidebar + header shell
│   │   │   ├── Sidebar.tsx              [Ansh] Navigation links
│   │   │   ├── CallWidget.tsx           [Ansh] ElevenLabs WebRTC widget
│   │   │   ├── ClaimStatusBadge.tsx     [Ansh] Color-coded status pill
│   │   │   ├── TranscriptViewer.tsx     [Ansh] Scrolling chat bubbles
│   │   │   ├── ToolExecutionCard.tsx    [Ansh] Tool name + args + result + latency
│   │   │   ├── StatsCard.tsx            [Ansh] Single metric card
│   │   │   └── CallChart.tsx            [Ansh] Recharts bar/line chart
│   │   ├── hooks/
│   │   │   ├── useRealtimeCalls.ts      [Ansh] Supabase subscription on call_logs
│   │   │   └── useRealtimeClaims.ts     [Ansh] Supabase subscription on claims
│   │   └── types/
│   │       └── index.ts                 [Ansh] Frontend types
│   ├── tailwind.config.ts
│   ├── vite.config.ts
│   └── package.json
│
├── .env.example                         Template for env vars
├── .gitignore
├── HACKATHON_PRD.md                     Full PRD — read this first
├── BUILD_PLAN.md                        Day-by-day plan with names
└── README.md                            This file
```

---

## Getting Started

### Prerequisites

- Node.js 20+ (`node -v` to check)
- npm 9+ (`npm -v` to check)
- Git
- A code editor (VS Code recommended)

### Step 0: Clone and Read

```bash
git clone https://github.com/aniruddha1295/Loops_hackerhouse.git
cd Loops_hackerhouse

# Read the plan for your role
cat HACKATHON_PRD.md    # Full product spec
cat BUILD_PLAN.md       # Day-by-day tasks with your name
```

### Quick Start (For Any Developer)

Follow these steps in order to get the project running locally:

#### 1. Clone and Setup
```bash
git clone https://github.com/aniruddha1295/Loops_hackerhouse.git
cd Loops_hackerhouse
```

#### 2. Backend Setup
```bash
cd backend
npm install
```

#### 3. Environment File
Get the shared `.env` file from the team (ask Tanmay or Aniruddha). Place it at `backend/.env`.

Required variables: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `PORT`, `NODE_ENV`, `FRONTEND_URL`

#### 4. Database
Migrations and seed data are already applied to the shared Supabase instance. No local database setup needed — the backend connects to Supabase cloud.

If you need to reset the database, run `backend/database/run-all.sql` in the Supabase SQL Editor.

#### 5. Start the Backend
```bash
npm run dev
# Server runs at http://localhost:3005
```

Verify with:
```bash
curl http://localhost:3005/health
```

#### 6. Test the Tool Endpoints
```bash
# Lookup a claim
curl -X POST http://localhost:3005/api/tools/lookup-claim \
  -H "Content-Type: application/json" \
  -d '{"claim_id": "CLM-2026-000456"}'

# Check a policy
curl -X POST http://localhost:3005/api/tools/check-policy \
  -H "Content-Type: application/json" \
  -d '{"policy_number": "POL-2024-001234"}'

# Check missing documents
curl -X POST http://localhost:3005/api/tools/check-documents \
  -H "Content-Type: application/json" \
  -d '{"claim_id": "CLM-2026-000456"}'

# File a new claim
curl -X POST http://localhost:3005/api/tools/file-claim \
  -H "Content-Type: application/json" \
  -d '{"policy_number": "POL-2024-001234", "claim_type": "collision", "incident_date": "2026-04-16", "incident_description": "Tree fell on car"}'

# Escalate to human
curl -X POST http://localhost:3005/api/tools/escalate-to-human \
  -H "Content-Type: application/json" \
  -d '{"reason": "Customer wants supervisor", "priority": "high"}'

# Schedule callback
curl -X POST http://localhost:3005/api/tools/schedule-callback \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+14155550101", "preferred_time": "tomorrow at 2pm", "reason": "Follow up"}'
```

#### 7. ElevenLabs Testing (Optional)
The ClaimsBot agent is already configured in ElevenLabs. To test live:
1. Start ngrok: `ngrok http 3005`
2. Copy the `https://xxxx.ngrok-free.app` URL
3. Update the 6 tool webhook URLs in ElevenLabs dashboard with your ngrok URL
4. Use the ElevenLabs Preview to talk to the agent

Ask Tanmay for ElevenLabs access and the Agent ID.

#### Architecture
```
Caller → ElevenLabs AI Agent → Tool Webhooks → Fastify Backend (port 3005) → Supabase (cloud DB)
                                                         ↑
                                               ngrok tunnel (local dev)
                                               Railway URL (production)
```

---

### Anish — Backend Setup (Do This First)

You set up the backend scaffold that Tanmay also works in.

```bash
# 1. Create backend project
mkdir -p backend/src/{config,plugins,routes,services,types}
mkdir -p backend/database
cd backend

# 2. Initialize Node project
npm init -y

# 3. Install dependencies
npm install fastify fastify-plugin @fastify/cors @supabase/supabase-js dotenv pino pino-pretty
npm install -D typescript @types/node tsx

# 4. Create tsconfig.json
cat > tsconfig.json << 'TSCONFIG'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "esModuleInterop": true,
    "strict": true,
    "outDir": "dist",
    "rootDir": "src",
    "resolveJsonModule": true,
    "declaration": true,
    "sourceMap": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
TSCONFIG

# 5. Add scripts to package.json — manually add these to the "scripts" section:
#    "dev": "tsx watch src/server.ts",
#    "build": "tsc",
#    "start": "node dist/server.js"

# 6. Create .env file
# Copy from the team's shared env file — ask Tanmay or check the team's shared credentials.
# See .env.example for the required variable names.

# 7. Start coding server.ts, plugins, migration.sql
# See HACKATHON_PRD.md sections 4-5 for exact schemas and API specs

# 8. Run the server
npm run dev
```

**Your Day 1 priority files:**
1. `src/server.ts` — Fastify server with plugin registration
2. `src/plugins/supabase.ts` — Supabase client plugin
3. `src/plugins/cors.ts` — CORS plugin
4. `src/types/index.ts` — Shared TypeScript interfaces
5. `database/migration.sql` — All 7 tables (copy from HACKATHON_PRD.md section 4)
6. `database/seed.sql` — Demo data
7. `src/routes/claims.ts` — GET /api/claims
8. `src/routes/calls.ts` — GET /api/calls

**After writing migration.sql:** Send it to Aniruddha to run in Supabase SQL Editor.

---

### Tanmay — Backend Tool Endpoints

You work in the same `/backend` folder as Anish but on **different files**.

```bash
cd backend

# Wait for Anish to set up the project, then:
npm install   # in case Anish added new deps
npm run dev   # start the server
```

**Your files (ONLY touch these):**
1. `src/routes/webhook-tools.ts` — All 6 POST endpoints
2. `src/services/claims-service.ts` — Claim lookup, filing, document checking
3. `src/services/policy-service.ts` — Policy lookup
4. `src/services/escalation-service.ts` — Create escalation records
5. `src/services/callback-service.ts` — Schedule callbacks

**Your 6 endpoints** (full specs in HACKATHON_PRD.md section 5):

| Endpoint | What It Does |
|----------|-------------|
| `POST /api/tools/lookup-claim` | Query claims table by claim_number, return status + details |
| `POST /api/tools/check-policy` | Query policies table by policy_number, return coverage |
| `POST /api/tools/check-documents` | Compare required vs received documents for a claim |
| `POST /api/tools/file-claim` | Create new claim record, generate claim number, return it |
| `POST /api/tools/escalate-to-human` | Create escalation record with reason + priority |
| `POST /api/tools/schedule-callback` | Create callback record with time + reason |

**How to test:**
```bash
# After seed data is loaded, test with:
curl -X POST http://localhost:3005/api/tools/lookup-claim \
  -H "Content-Type: application/json" \
  -d '{"claim_id": "CLM-2026-000456"}'

# Should return James Wilson's collision claim details
```

**Important:** Your endpoints are called by ElevenLabs during a live phone call. They MUST:
- Respond fast (under 500ms)
- Never return 500 errors (always return a helpful message)
- Return natural language in the `message` field (the AI reads this to the caller)

### Tanmay — Completed Work

**Status: All 6 tool endpoints implemented, tested, and production-ready. ElevenLabs ClaimsBot agent configured and E2E verified.**

#### Services Implemented
| Service | Functions | Purpose |
|---------|-----------|---------|
| `claims-service.ts` | `lookupClaim()`, `checkDocuments()`, `fileClaim()` | Claim lookup by number, document gap analysis, new claim filing with policy validation |
| `policy-service.ts` | `lookupPolicy()` | Policy details with JSONB coverage info and customer join |
| `escalation-service.ts` | `createEscalation()` | Priority-based escalation with SLA mapping (urgent/high/normal/low) |
| `callback-service.ts` | `scheduleCallback()` | Natural language time parsing via chrono-node with fallback logic |

#### Endpoint Response Examples

**lookup-claim** — `POST /api/tools/lookup-claim`
```json
{ "found": true, "claim": { "claim_number": "CLM-2026-000456", "status": "under_review", "customer_name": "James Wilson", "assigned_adjuster": "Sarah Chen" } }
```

**check-documents** — `POST /api/tools/check-documents`
```json
{ "found": true, "documents_missing": ["repair_estimate", "photos"], "message": "You still need to submit the following: repair estimate and photos." }
```

**file-claim** — `POST /api/tools/file-claim`
```json
{ "success": true, "claim_number": "CLM-2026-519457", "status": "submitted", "message": "Your claim has been filed successfully.", "next_steps": ["Upload photos", "Get estimate", "Keep receipts"] }
```

**escalate-to-human** — `POST /api/tools/escalate-to-human`
```json
{ "success": true, "reference_number": "ESC-2026-1194", "message": "I've escalated this to a supervisor. You can expect a response within 2 business hours." }
```

**schedule-callback** — `POST /api/tools/schedule-callback`
```json
{ "success": true, "scheduled_time": "2026-04-17T15:00:00.000Z", "message": "I've scheduled a callback for Friday, April 17 at 3:00 PM." }
```

#### Quality & Hardening
- All endpoints return HTTP 200 (ElevenLabs requirement) — errors via `found: false` / `success: false`
- Input validation: null guards, empty string handling, whitespace trimming
- Structured Pino logging on every tool invocation and completion
- Edge cases: missing claims, inactive policies, invalid priorities, unparseable times
- Dockerfile updated to Node 22 with multi-stage production build

#### ElevenLabs Agent Setup (ClaimsBot)
Originally assigned to Aniruddha — completed by Tanmay to unblock the team.

| Configuration | Value |
|--------------|-------|
| Agent Name | ClaimsBot |
| AI Assistant Name | Alex |
| Voice | Rachel - Clear and Engaging (V3 Conversational) |
| Audio Tags | Patient, Concerned, Serious, Empathetically, Warmly |
| LLM | Qwen3-30B |
| System Prompt | Insurance claims assistant with 6 tools and verification rules |
| First Message | "Hello, thank you for calling SafeGuard Insurance claims..." |

**6 Tool Webhooks Configured:**
| Tool | Webhook URL |
|------|-------------|
| lookup_claim | `{NGROK_OR_RAILWAY_URL}/api/tools/lookup-claim` |
| check_policy | `{NGROK_OR_RAILWAY_URL}/api/tools/check-policy` |
| check_documents | `{NGROK_OR_RAILWAY_URL}/api/tools/check-documents` |
| file_claim | `{NGROK_OR_RAILWAY_URL}/api/tools/file-claim` |
| escalate_to_human | `{NGROK_OR_RAILWAY_URL}/api/tools/escalate-to-human` |
| schedule_callback | `{NGROK_OR_RAILWAY_URL}/api/tools/schedule-callback` |

**E2E Tested:** All 6 tools verified working through ElevenLabs → ngrok → backend → Supabase pipeline.

#### ngrok Tunnel Setup
- ngrok installed and authenticated on Tanmay's machine
- Tunnel active at `https://dyslexic-coeditor-marital.ngrok-free.dev` → `localhost:3005`
- After Railway deployment, swap ngrok URLs to Railway URLs in ElevenLabs tool settings

### Team Setup — Getting Started with Tanmay's Backend

#### 1. Pull the Branch
```bash
git fetch origin
git checkout feat/tool-endpoints
```

#### 2. Install Dependencies
```bash
cd backend
npm install
```

#### 3. Add `.env` File
Create `backend/.env` using the shared env file from the team. Ask Tanmay or check the team's shared credentials.

#### 4. Start the Server
```bash
npm run dev
# Server runs on http://localhost:3005
```

#### 5. Test the Tool Endpoints
```bash
# Lookup a claim
curl -X POST http://localhost:3005/api/tools/lookup-claim \
  -H "Content-Type: application/json" \
  -d '{"claim_id": "CLM-2026-000456"}'

# Check a policy
curl -X POST http://localhost:3005/api/tools/check-policy \
  -H "Content-Type: application/json" \
  -d '{"policy_number": "POL-2024-001234"}'

# Check missing documents
curl -X POST http://localhost:3005/api/tools/check-documents \
  -H "Content-Type: application/json" \
  -d '{"claim_id": "CLM-2026-000456"}'

# File a new claim
curl -X POST http://localhost:3005/api/tools/file-claim \
  -H "Content-Type: application/json" \
  -d '{"policy_number": "POL-2024-001234", "claim_type": "collision", "incident_date": "2026-04-16", "incident_description": "Tree fell on car"}'

# Escalate to human
curl -X POST http://localhost:3005/api/tools/escalate-to-human \
  -H "Content-Type: application/json" \
  -d '{"reason": "Customer wants supervisor", "priority": "high"}'

# Schedule callback
curl -X POST http://localhost:3005/api/tools/schedule-callback \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+14155550101", "preferred_time": "tomorrow at 2pm", "reason": "Follow up"}'
```

#### ElevenLabs Integration
The **ClaimsBot** agent is configured in Tanmay's ElevenLabs account with all 6 tools. To use it:
- Ask Tanmay for ElevenLabs team invite or login credentials
- The Agent ID is needed for the frontend WebRTC widget (`VITE_ELEVENLABS_AGENT_ID`)
- Tool webhook URLs currently point at ngrok — swap to Railway URL after deployment

#### Running ngrok for Live Testing
```bash
# Install ngrok and authenticate (one-time)
ngrok config add-authtoken YOUR_TOKEN

# Start tunnel
ngrok http 3005
# Copy the https://xxxx.ngrok-free.app URL
# Update ElevenLabs tool webhook URLs with this URL
```

---

### Ansh — Frontend Setup

You work in the `/frontend` folder. Completely independent from backend.

```bash
# 1. Create React project
cd Loops_hackerhouse
npm create vite@latest frontend -- --template react-ts
cd frontend

# 2. Install dependencies
npm install react-router-dom @supabase/supabase-js axios recharts lucide-react date-fns clsx tailwind-merge
npm install -D tailwindcss @tailwindcss/vite

# 3. Create .env file
# Copy from the team's shared env file — ask Tanmay or check the team's shared credentials.
# See .env.example for the required variable names (VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY, VITE_API_URL).

# 4. Configure Tailwind in vite.config.ts:
#    import tailwindcss from '@tailwindcss/vite'
#    plugins: [react(), tailwindcss()]

# 5. Add Tailwind to your main CSS file:
#    @import "tailwindcss";

# 6. Start dev server
npm run dev
```

**Your Day 1 priority files:**
1. `src/App.tsx` — Router with all 6 routes
2. `src/components/Layout.tsx` — Sidebar + header shell
3. `src/components/Sidebar.tsx` — Navigation (Claims, Calls, Analytics, Agent Config)
4. `src/pages/ClaimsList.tsx` — Table with mock data first
5. `src/pages/CallHistory.tsx` — Table with mock data first
6. `src/components/ClaimStatusBadge.tsx` — Status pill component
7. `src/components/StatsCard.tsx` — Metric card component
8. `src/lib/supabase.ts` — Supabase client init

**Start with mock data!** Don't wait for the backend:
```typescript
// Use this until backend is ready
const mockClaims = [
  {
    id: '1',
    claim_number: 'CLM-2026-000456',
    status: 'under_review',
    claim_type: 'collision',
    claimed_amount: 8500,
    incident_date: '2026-03-15',
    customer: { full_name: 'James Wilson' }
  },
  // ... add more from HACKATHON_PRD.md section 8
];
```

**Day 2-3:** Replace mock data with real Supabase queries + real-time subscriptions.

**Day 3:** Install `@11labs/react` and build CallWidget.tsx (get agent ID from Aniruddha).

```bash
# Day 3 — WebRTC widget
npm install @11labs/react
```

---

### Aniruddha — Supabase + ElevenLabs + Deployment

You don't write much code. You configure services and keep everyone unblocked.

**Day 1 Tasks:**

```
1. Supabase (DONE — project created, keys shared)

2. Run migration:
   - Go to https://supabase.com/dashboard → your project → SQL Editor
   - Paste Anish's migration.sql → click Run
   - Verify: go to Table Editor, you should see 7 tables

3. Run seed data:
   - Same process — paste Anish's seed.sql → click Run
   - Verify: click on 'customers' table, should see 8 rows

4. ElevenLabs:
   - Go to elevenlabs.io → sign up
   - Navigate to Conversational AI → Create Agent
   - Name: "ClaimsBot"
   - System prompt: copy from HACKATHON_PRD.md section 6
   - Voice: test "Rachel", "Drew", "Josh" — pick the most professional
   - Add 6 tools (name, description, parameters from the PRD)
   - Write + upload knowledge base PDFs
   - Test in playground

5. ngrok (for connecting ElevenLabs to local backend):
   - npm install -g ngrok
   - ngrok http 3005
   - Copy the https URL
   - Set all 6 ElevenLabs tool webhook URLs to: https://<ngrok-url>/api/tools/<tool-name>
```

**Day 4: Deploy Everything**
```
1. Railway (backend):
   - Go to railway.app → New Project → Deploy from GitHub
   - Select the repo → set root directory to /backend
   - Add env vars (same as backend/.env but NODE_ENV=production)
   - Deploy

2. Vercel (frontend):
   - Go to vercel.com → Import Project → Select repo
   - Set root directory to /frontend
   - Add env vars (VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY, VITE_API_URL=<railway-url>)
   - Deploy

3. Swap ElevenLabs webhook URLs from ngrok → Railway production URL

4. Test everything on production
```

---

## Database Schema Quick Reference

7 tables — full SQL in HACKATHON_PRD.md section 4:

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `customers` | Policyholders | full_name, phone, email |
| `policies` | Insurance policies | policy_number, policy_type, coverage_amount, deductible |
| `claims` | Insurance claims | claim_number, status, claim_type, documents_required/received |
| `call_logs` | Every AI call | direction, transcript, outcome, tools_used |
| `call_tool_executions` | Tool calls during a call | tool_name, tool_args, tool_result, latency_ms |
| `escalations` | Human handoff requests | reason, priority, status |
| `scheduled_callbacks` | Follow-up calls | phone_number, scheduled_time, reason |

---

## API Quick Reference

### Tool Endpoints (ElevenLabs calls these — Tanmay builds)

| Method | Path | Input | Returns |
|--------|------|-------|---------|
| POST | `/api/tools/lookup-claim` | `{ claim_id }` | Claim status + details |
| POST | `/api/tools/check-policy` | `{ policy_number }` | Policy coverage |
| POST | `/api/tools/check-documents` | `{ claim_id }` | Missing documents list |
| POST | `/api/tools/file-claim` | `{ policy_number, claim_type, incident_date, incident_description }` | New claim number |
| POST | `/api/tools/escalate-to-human` | `{ reason, priority }` | Escalation reference |
| POST | `/api/tools/schedule-callback` | `{ phone_number, preferred_time, reason }` | Scheduled time |

### Dashboard Endpoints (Frontend reads these — Anish builds)

| Method | Path | Returns |
|--------|------|---------|
| GET | `/api/calls` | List of call logs |
| GET | `/api/calls/:id` | Single call + tool executions |
| GET | `/api/claims` | List of claims (filterable by status) |
| GET | `/api/claims/:id` | Single claim detail |
| GET | `/api/escalations` | List of escalations |
| GET | `/api/analytics` | Aggregated stats (total calls, avg duration, resolution rate) |
| POST | `/api/webhooks/elevenlabs/conversation-ended` | Logs completed call |

---

## Git Workflow

### Branch Strategy (Keep It Simple)

Everyone pushes to `main`. No feature branches for a 5-day hackathon.

**But follow this rule to avoid conflicts:**
- Tanmay ONLY edits: `routes/webhook-tools.ts`, `services/claims-service.ts`, `services/policy-service.ts`, `services/escalation-service.ts`, `services/callback-service.ts`
- Anish ONLY edits: `server.ts`, `plugins/*`, `routes/calls.ts`, `routes/claims.ts`, `routes/analytics.ts`, `routes/webhooks.ts`, `services/call-log-service.ts`, `database/*`, `types/*`
- Ansh ONLY edits: everything in `/frontend`
- Aniruddha: rarely pushes code — mostly works in dashboards (Supabase, ElevenLabs, Twilio)

```bash
# Before you start working
git pull origin main

# After finishing a task
git add <your-files-only>
git commit -m "short description of what you did"
git push origin main

# If push fails (someone pushed before you)
git pull --rebase origin main
git push origin main
```

---

## Testing Cheatsheet

### Test backend endpoints locally
```bash
# Lookup a claim
curl -X POST http://localhost:3005/api/tools/lookup-claim \
  -H "Content-Type: application/json" \
  -d '{"claim_id": "CLM-2026-000456"}'

# Check a policy
curl -X POST http://localhost:3005/api/tools/check-policy \
  -H "Content-Type: application/json" \
  -d '{"policy_number": "POL-2024-001234"}'

# File a new claim
curl -X POST http://localhost:3005/api/tools/file-claim \
  -H "Content-Type: application/json" \
  -d '{"policy_number": "POL-2024-001234", "claim_type": "collision", "incident_date": "2026-04-10", "incident_description": "Tree fell on car during storm"}'

# Get all claims
curl http://localhost:3005/api/claims

# Get analytics
curl http://localhost:3005/api/analytics
```

### Test ElevenLabs agent
1. Go to ElevenLabs dashboard → your agent → Playground
2. Type or speak: "I want to check my claim CLM-2026-000456"
3. Agent should call `lookup_claim` tool → you see the webhook fire
4. Agent responds with claim details

### Test phone call
1. Aniruddha imports Twilio number into ElevenLabs
2. Call the Twilio number from your phone
3. AI picks up → have a conversation → check Supabase for new records

---

## Key Claim Numbers for Testing

These are seeded in the database (once Anish writes seed.sql):

| Claim Number | Customer | Status | Good For Testing |
|-------------|----------|--------|-----------------|
| CLM-2026-000456 | James Wilson | under_review | **PRIMARY DEMO** — missing documents |
| CLM-2026-000321 | Maria Garcia | approved | Checking approved claim |
| CLM-2026-000789 | Robert Chen | denied | Escalation demo |
| CLM-2026-000112 | Emily Davis | submitted | New claim, just filed |

| Policy Number | Customer | Type | Status |
|-------------|----------|------|--------|
| POL-2024-001234 | James Wilson | auto | active |
| POL-2024-005678 | James Wilson | home | active |
| POL-2024-002345 | Maria Garcia | home | active |

---

## Timeline

| Day | Date | Goal |
|-----|------|------|
| 1 | April 16 | DB + 3 tool endpoints + frontend shell + ElevenLabs agent |
| 2 | April 17 | All 6 endpoints + dashboard APIs + **first phone call works** |
| 3 | April 18 | WebRTC widget + all pages polished + 10+ scenarios tested |
| 4 | April 19 | **Deploy to production** + demo rehearsals |
| 5 | April 20 | Final check + rest |
| — | April 21-23 | **JUDGING** |

---

## Need Help?

| Question | Ask |
|----------|-----|
| Supabase keys / project issues | Aniruddha |
| Database schema / migration | Anish |
| Tool endpoint API format | Tanmay |
| Frontend component / page | Ansh |
| ElevenLabs agent ID / config | Aniruddha |
| "Does this work end-to-end?" | Aniruddha tests it |
| ngrok URL | Aniruddha |
