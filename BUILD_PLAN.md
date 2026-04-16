# Build Plan — Team of 4, 5 Days

> Start: April 16, 2026 | Judging: April 21-23, 2026

---

## Team Roles

| Person | Role | Owns |
|--------|------|------|
| **Person A** | Backend Engineer | Fastify server, webhook tool endpoints, services, migration, Railway deploy |
| **Person B** | Frontend Engineer | React dashboard, all pages + components, Vercel deploy |
| **Person C** | Voice/AI Engineer | ElevenLabs agent config, prompts, tools, knowledge base, Twilio phone, WebRTC widget |
| **Person D** | Integration + Demo Lead | Supabase setup, seed data, env vars, end-to-end testing, demo script, backup plans |

---

## Dependency Chain (What Blocks What)

```
FULLY PARALLEL (no dependencies — start Day 1):
  ┌─ [Person B] Frontend layout, pages, components (use hardcoded data)
  ├─ [Person C] ElevenLabs agent config, knowledge base, voice selection
  └─ [Person D] Supabase project setup, write seed data SQL

SEQUENTIAL CHAIN 1 — Backend → Data:
  [Person A] Write migration.sql
    → [Person D] Run migration in Supabase
      → [Person A] Build tool endpoints
        → [Person D] Run seed.sql
          → [Person B] Connect frontend to real data

SEQUENTIAL CHAIN 2 — Voice → Phone:
  [Person A] Deploy backend to Railway
    → [Person C] Point ElevenLabs tool webhooks to Railway URL
      → [Person C] Test conversation end-to-end
        → [Person C] Set up Twilio + connect to ElevenLabs

SEQUENTIAL CHAIN 3 — WebRTC:
  [Person C] ElevenLabs agent fully working with tools
    → [Person B] Integrate @11labs/react SDK into CallWidget
      → [Person D] Test WebRTC calling from dashboard

SEQUENTIAL CHAIN 4 — Live Call View:
  [Person A] POST /api/webhooks/elevenlabs/conversation-ended
    → [Person D] Verify call data flows to Supabase
      → [Person B] Build LiveCallView with real-time subscriptions
```

### Critical Path (Blocks Everything If Late)
1. Supabase project + migration — Day 1, first 2 hours
2. At least 2 working tool endpoints on Railway — Day 1, end of day
3. ElevenLabs agent configured with correct webhook URLs — Day 2, morning
4. First successful phone call through the full stack — Day 2, by noon

---

## Day 1 (April 16) — Foundation

### All 4 People — First 30 Minutes
- Create GitHub repo (monorepo: `/backend`, `/frontend`)
- Person D: Create Supabase project, get URL + keys, share `.env` with team
- Person A: Scaffold backend (`npm init`, Fastify + TypeScript)
- Person B: Scaffold frontend (`npm create vite` — React + Tailwind)

### Person A (Backend)
| # | Task | Depends On | Output |
|---|------|-----------|--------|
| 1 | Set up Fastify server with CORS, Supabase plugin | — | `server.ts`, `plugins/` |
| 2 | Write `migration.sql` (all 7 tables + indexes) | — | `database/migration.sql` |
| 3 | **HAND OFF** migration.sql to Person D to run | — | — |
| 4 | Implement `POST /api/tools/lookup-claim` | Tables exist | Working endpoint |
| 5 | Implement `POST /api/tools/check-policy` | Tables exist | Working endpoint |
| 6 | Implement `POST /api/tools/check-documents` | Tables exist | Working endpoint |
| 7 | Test all 3 endpoints with curl/Postman | Seed data | Verified working |

### Person B (Frontend)
| # | Task | Depends On | Output |
|---|------|-----------|--------|
| 1 | Set up Tailwind, react-router, Layout + Sidebar | — | App shell |
| 2 | Build `ClaimsList.tsx` (hardcoded data first) | — | Claims table page |
| 3 | Build `ClaimStatusBadge.tsx` | — | Reusable component |
| 4 | Build `StatsCard.tsx` | — | Reusable component |
| 5 | Build `CallHistory.tsx` (table layout) | — | Calls table page |
| 6 | Set up Supabase client in `lib/supabase.ts` | Supabase keys from D | Client ready |

### Person C (Voice/AI)
| # | Task | Depends On | Output |
|---|------|-----------|--------|
| 1 | Create ElevenLabs account, explore dashboard | — | Account ready |
| 2 | Create agent with system prompt from PRD | — | Agent created |
| 3 | Select voice (test 3-4, pick best professional voice) | — | Voice chosen |
| 4 | Define all 6 tools in ElevenLabs with parameter schemas | — | Tools configured |
| 5 | Point webhooks to temp URL (ngrok) for testing | Person A has local server | Testable |
| 6 | Write 3 knowledge base PDFs | — | PDFs ready |
| 7 | Upload PDFs to ElevenLabs agent | Agent created | KB active |
| 8 | Test agent in ElevenLabs playground | All above | Working conversation |

### Person D (Integration)
| # | Task | Depends On | Output |
|---|------|-----------|--------|
| 1 | Create Supabase project, configure, share keys | — | Project live |
| 2 | Run `migration.sql` in Supabase SQL editor | Person A delivers SQL | Tables created |
| 3 | Write `seed.sql` (8 customers, 10 policies, 12 claims, etc.) | Tables exist | Seed file ready |
| 4 | Run `seed.sql` in Supabase | Migration done | Data populated |
| 5 | Set up Railway project, connect GitHub, configure env vars | — | Pipeline ready |
| 6 | Set up Vercel project, connect GitHub | — | Pipeline ready |
| 7 | Test backend deploys to Railway | Person A pushes code | Deploy verified |
| 8 | Help Person C test webhooks via ngrok | Person A local server | E2E testable |

### Day 1 Checkpoint ✓
- [ ] Database exists with seed data
- [ ] Backend has 3 working tool endpoints
- [ ] Frontend has layout + claims list rendering
- [ ] ElevenLabs agent configured with prompt, voice, tools, KB
- [ ] Railway and Vercel deploy pipelines working

---

## Day 2 (April 17) — Core Features Complete

### Person A (Backend)
| # | Task | Depends On | Output |
|---|------|-----------|--------|
| 1 | Implement `POST /api/tools/file-claim` | — | Creates claims in DB |
| 2 | Implement `POST /api/tools/escalate-to-human` | — | Creates escalation |
| 3 | Implement `POST /api/tools/schedule-callback` | — | Creates callback |
| 4 | Implement `POST /api/webhooks/elevenlabs/conversation-ended` | — | Logs calls |
| 5 | Implement `GET /api/calls` and `GET /api/calls/:id` | — | Dashboard reads |
| 6 | Implement `GET /api/analytics` | — | Aggregated stats |
| 7 | Deploy to Railway, test all with production URLs | All above | All endpoints live |

### Person B (Frontend)
| # | Task | Depends On | Output |
|---|------|-----------|--------|
| 1 | Build `Analytics.tsx` (StatsCards + CallChart) | — | Analytics page |
| 2 | Build `LiveCallView.tsx` (transcript + tool cards) | — | Live call page |
| 3 | Build `TranscriptViewer.tsx` | — | Component |
| 4 | Build `ToolExecutionCard.tsx` | — | Component |
| 5 | Hook `ClaimsList.tsx` to Supabase real-time | Supabase client | Live updates |
| 6 | Build `ClaimDetail.tsx` | — | Claim detail page |
| 7 | Connect all pages to real API/Supabase data | Backend deployed | Real data |

### Person C (Voice/AI)
| # | Task | Depends On | Output |
|---|------|-----------|--------|
| 1 | Update all 6 tool webhook URLs to Railway production | Backend on Railway | URLs correct |
| 2 | Test full conversation: tools fire, data returns | Endpoints + seed data | Verified |
| 3 | Tune system prompt (fix issues found during testing) | Testing done | Prompt polished |
| 4 | Set up Twilio account, buy US number | — | Number ready |
| 5 | Connect Twilio number to ElevenLabs agent | Agent working | Phone linked |
| 6 | **TEST: First real phone call end-to-end** | All above | Call works! |
| 7 | Create B2B agent variant (formal tone) | — | Second agent |

### Person D (Integration)
| # | Task | Depends On | Output |
|---|------|-----------|--------|
| 1 | E2E test: phone → ElevenLabs → webhook → DB → dashboard | All systems up | Verified |
| 2 | Verify seed data displays correctly in frontend | Frontend connected | Verified |
| 3 | Fix data format mismatches between backend and frontend | Testing | Fixes applied |
| 4 | Test Supabase real-time (new claim appears live) | Frontend subs | Verified |
| 5 | Start writing demo script | — | Draft script |
| 6 | Create additional seed data if needed | — | Updated seed |

### Day 2 Checkpoint ✓
- [ ] All 6 tool endpoints working on Railway
- [ ] Phone calls work end-to-end
- [ ] Dashboard shows real data from Supabase
- [ ] Analytics page renders charts
- [ ] Live call view shows transcript updates

---

## Day 3 (April 18) — WebRTC + Polish

### Person A (Backend)
| # | Task | Depends On | Output |
|---|------|-----------|--------|
| 1 | Parse ElevenLabs webhook (transcript, duration, tools) | — | Full call logging |
| 2 | Harden error handling (graceful errors, not 500s) | — | Robust API |
| 3 | Add request logging (Pino) | — | Debugging ready |
| 4 | Verify all endpoints with production seed data | — | Verified |

### Person B (Frontend)
| # | Task | Depends On | Output |
|---|------|-----------|--------|
| 1 | Build `CallWidget.tsx` (@11labs/react SDK) | Person C agent working | WebRTC widget |
| 2 | Build `AgentConfig.tsx` (display config, voice, tools) | — | Config page |
| 3 | Polish: loading states, empty states, error states | — | Polished UI |
| 4 | Responsive check (demo on laptop/projector) | — | Demo-ready |
| 5 | Add transitions/animations | — | Smooth UX |

### Person C (Voice/AI)
| # | Task | Depends On | Output |
|---|------|-----------|--------|
| 1 | Test WebRTC via React SDK in dashboard | Person B CallWidget | Browser calling works |
| 2 | Test 10+ conversation scenarios, adjust prompt | — | Edge cases handled |
| 3 | Test agent-to-agent transfer (escalation) | — | Transfer works |
| 4 | Record a backup test call video | — | Safety net |
| 5 | Prepare KB answers for judge questions | — | Judge-ready |

### Person D (Integration)
| # | Task | Depends On | Output |
|---|------|-----------|--------|
| 1 | Full E2E test: phone call, WebRTC, claim filing, escalation | All systems | All paths verified |
| 2 | Verify LiveCallView works during active call | — | Real-time verified |
| 3 | Finalize demo script with exact claim numbers | Seed data final | Script locked |
| 4 | Test demo script 2-3 times end to end | Script ready | Rehearsed |
| 5 | Create backup: pre-recorded video of successful call | — | Video saved |

### Day 3 Checkpoint ✓
- [ ] WebRTC calling works from dashboard
- [ ] All pages polished with proper states
- [ ] Agent handles 10+ conversation scenarios
- [ ] Demo script tested successfully
- [ ] Backup video recorded

---

## Day 4 (April 19) — Demo Prep + Hardening

### Person A (Backend)
| # | Task | Output |
|---|------|--------|
| 1 | Performance check: tool responses under 500ms | Verified |
| 2 | Reseed database with clean demo data | Fresh state |
| 3 | Write quick reseed script (run before each demo) | `reseed.sh` |
| 4 | Support B/C with any API issues | — |

### Person B (Frontend)
| # | Task | Output |
|---|------|--------|
| 1 | Final visual polish: spacing, colors, fonts | Pixel-perfect |
| 2 | Add "SafeGuard Insurance" branding (logo, header) | Branded |
| 3 | Build landing/hero page if time allows | Optional |
| 4 | Ensure dashboard looks great on projector | Big-screen ready |
| 5 | Test on Chrome and Safari | Cross-browser |

### Person C (Voice/AI)
| # | Task | Output |
|---|------|--------|
| 1 | Run demo script 3 times with real phone call | Rehearsed |
| 2 | Test unexpected inputs (what if caller says something weird?) | Edge cases |
| 3 | Tune filler phrases ("let me look that up...") | Natural feel |
| 4 | Test at demo volume (speakerphone) | Audio quality |

### Person D (Integration)
| # | Task | Output |
|---|------|--------|
| 1 | Full dress rehearsal (timed, 5-7 minutes) | Timed |
| 2 | Prepare judging Q&A answers | Prep sheet |
| 3 | Create 1-page architecture diagram | Visual aid |
| 4 | Test on tethered wifi / backup network | Network verified |
| 5 | Upload backup video to YouTube (unlisted) | Safety net |

### Day 4 Checkpoint ✓
- [ ] Demo rehearsed 3+ times
- [ ] Database can reset in 30 seconds
- [ ] All team members can explain architecture
- [ ] Backup video recorded and uploaded

---

## Day 5 (April 20) — Final Prep

### Everyone
| Time | Task |
|------|------|
| Morning | One final full rehearsal |
| Midday | Reset seed data to pristine state |
| Afternoon | Verify ALL services running (Railway + Vercel + Supabase + ElevenLabs + Twilio) |
| Evening | Charge all devices, prepare demo hardware |
| | Finalize pitch: 2 min story + 3 min live demo + 2 min Q&A |
| | **REST. Be sharp for judging April 21.** |

---

## Demo Script (5-7 Minutes on Stage)

### Setup
- Dashboard open on laptop (ClaimsList page)
- Phone with speaker ready
- Second browser tab: LiveCallView
- Database freshly seeded

### Act 1: The Problem (30 sec — Person D narrates)
> "Insurance claims are the worst customer experience in the world. You call, wait on hold for 45 minutes, explain your situation to three different people, and still don't know when you'll get paid. In China alone, insurance complaints grew 368% last year. We built an AI agent that fixes this."

### Act 2: Live Phone Call (3 min)

**Dial the Twilio number on speaker.**

**Demo conversation:**
1. AI greets caller (Alex from SafeGuard Insurance)
2. Caller asks about claim CLM-2026-000456
3. → Dashboard: `lookup_claim` tool fires, shows in LiveCallView
4. AI reports status, mentions missing documents
5. Caller asks what documents are missing
6. → Dashboard: `check_documents` tool fires
7. AI lists missing docs
8. Caller says they had another incident, wants to file new claim
9. → Dashboard: `check_policy` then `file_claim` tools fire
10. New claim appears in ClaimsList in REAL-TIME
11. Caller asks for callback tomorrow
12. → Dashboard: `schedule_callback` tool fires
13. Call ends

### Act 3: The Dashboard (1 min)
- Show new claim in ClaimsList (appeared live)
- Show Analytics (calls handled, resolution rate)
- Show AgentConfig (how insurers customize)
- Click WebRTC widget ("customers can also call from the website — zero phone cost")

### Act 4: Why It Matters (30 sec)
> "Insurance companies spend billions on claims call centers. Our AI handles 80% of routine calls at 1/10th the cost. Built on ElevenLabs Conversational AI. The consumer gets instant service. The insurer gets structured data. Everyone wins."

---

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| ElevenLabs webhook format unexpected | Person C tests on Day 1, documents format before Person A builds |
| Twilio credit runs out | WebRTC is free backup — identical AI experience |
| Railway cold start | Enable "always on" or health-check ping before demo |
| Supabase real-time slow | Fallback: poll every 2 seconds on LiveCallView |
| Live demo fails | Pre-recorded backup video ready |
| ElevenLabs rate limits | Test limits Day 3, avoid rapid successive calls |
| Agent gives wrong answer | Extensive prompt tuning Day 3 + knowledge base PDFs |

---

## NPM Dependencies

### Backend
```json
{
  "dependencies": {
    "fastify": "^5.3.0",
    "fastify-plugin": "^5.0.0",
    "@fastify/cors": "^10.0.0",
    "@supabase/supabase-js": "^2.49.0",
    "dotenv": "^16.5.0",
    "pino": "^9.6.0",
    "pino-pretty": "^13.0.0"
  },
  "devDependencies": {
    "typescript": "^5.8.0",
    "@types/node": "^22.0.0",
    "tsx": "^4.19.0"
  }
}
```

### Frontend
```json
{
  "dependencies": {
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "react-router-dom": "^6.23.0",
    "@supabase/supabase-js": "^2.49.0",
    "@11labs/react": "latest",
    "axios": "^1.7.0",
    "recharts": "^2.12.0",
    "lucide-react": "^0.400.0",
    "date-fns": "^3.6.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.3.0"
  }
}
```
