# Demo Script — ClaimsAgent

> **Total runtime:** 4-5 min conversation + 1 min closing
> **Hero:** Arjun Mehta (SF Bay Area, Indian-diaspora policyholder)
> **Why Arjun:** One natural conversation triggers all 6 AI tools. Memorable name. Emotional arc.

---

## The Story

Arjun had a car accident 11 days ago (April 10). He filed a claim but hasn't submitted all the docs yet, so it's stalled. **Last night**, a pipe burst in his bathroom — water damage everywhere. He calls SafeGuard stressed, dealing with two problems at once. He wants: *status on the car claim → info on what docs he's missing → check his home policy → file the new water damage claim → talk to a senior specialist → schedule a callback for tomorrow morning.*

One call. Six tools. Real narrative.

---

## Before You Record

- [ ] Reset seed data (paste `backend/database/seed.sql` into Supabase SQL Editor → Run)
- [ ] Open https://loops-hackerhouse.vercel.app on Screen 1
- [ ] Go to **Claims** page — confirm **CLM-2026-000456 (Arjun Mehta)** is at the top
- [ ] Open a second tab on **Analytics** — judges see charts update live at the end
- [ ] Test the widget once in advance to warm up ElevenLabs
- [ ] Verify ngrok/Railway/Vercel are all green
- [ ] Have this script on your phone or second monitor

---

## The 60-Second Opening (Narrator Voice-Over)

> *"Meet Arjun Mehta — a SafeGuard Insurance customer. Eleven days ago he got rear-ended at a red light. His claim is still sitting in review because he hasn't sent in the repair estimate. He's stressed. And last night, a pipe burst in his bathroom. Water everywhere.*
>
> *He picks up the phone and calls his insurance company.*
>
> *Watch what happens."*

**[Click phone button → Start Call → Allow mic]**

---

## The Conversation

> **Tip:** Speak naturally. You don't have to say these words exactly. The phrases in **bold** are the ones that trigger each tool — keep those intact.

### Tool 1: `lookup_claim`

**Ansh:** *"Hi, this is Ansh from SafeGuard Insurance claims. How can I help you today?"*

**You (as Arjun):**
> *"Hi Ansh, this is Arjun Mehta. I want to check on my auto claim from the accident last week."*

**Ansh:** *"Of course Mr. Mehta. Could you give me the claim number?"*

**You:**
> ***"CLM-2026-000456"***

**[Dashboard lights up — lookup_claim tool card appears]**

**Ansh:** *"Got it — your collision claim is currently under review with Neha Agarwal. Looks like we're still waiting on a couple of documents from you..."*

---

### Tool 2: `check_documents`

**You:**
> *"Yeah, what am I missing?"*

**[Dashboard — check_documents tool fires]**

**Ansh:** *"We still need your repair estimate and photos of the damage. Once those come in, Neha can move the claim forward."*

---

### Tool 3: `check_policy`

**You:**
> *"OK I'll get that this week. Actually Ansh, there's another problem. Last night a pipe burst in my bathroom. There's water damage all over the ceiling and my hardwood floors. I don't know what to do."*

**Ansh:** *"I'm really sorry to hear that — that sounds stressful. Let me check your home policy to see what's covered. What's the policy number?"*

**You:**
> ***"POL-2024-005678"***

**[Dashboard — check_policy tool fires]**

**Ansh:** *"Good news — water damage is covered. You have $450,000 in dwelling coverage with a $2,500 deductible. Let me file this new claim for you right now."*

---

### Tool 4: `file_claim`

**Ansh:** *"Can you describe what happened?"*

**You:**
> *"A pipe burst in the upstairs bathroom around 11 PM. Water came through the ceiling into the living room. The hardwood floors are warped. An emergency plumber stopped the leak."*

**[Dashboard — file_claim tool fires → NEW claim appears in Claims list in real-time]**

**Ansh:** *"Alright, I've filed your claim. The new claim number is CLM-2026-XXXXXX. An adjuster will be assigned within 24 to 48 hours. You'll need the plumber's invoice, photos, and a contractor repair estimate."*

**[POINT AT THE SCREEN — say to audience:]**
> *"Watch this — a brand new claim just appeared in the dashboard, in real-time."*

---

### Tool 5: `escalate_to_human`

**You:**
> *"Ansh, this is a lot. Two claims at once, a stalled car claim, now this mess at home. Can I talk to someone senior who can look at everything together?"*

**[Dashboard — escalate_to_human tool fires]**

**Ansh:** *"Absolutely. I'm escalating this to a senior specialist who can coordinate both claims. This is being flagged as high priority — someone will contact you within 2 hours."*

---

### Tool 6: `schedule_callback`

**You:**
> *"Actually, tomorrow morning would be better. Can someone call me at 10 AM?"*

**Ansh:** *"Of course. What number should they call?"*

**You:**
> *"+1 415-555-0101"*

**[Dashboard — schedule_callback tool fires]**

**Ansh:** *"Done. Callback scheduled for tomorrow at 10 AM. Is there anything else I can help you with today, Mr. Mehta?"*

**You:**
> *"No, that's everything. Thank you, Ansh."*

**Ansh:** *"You're welcome. Take care of yourself, and we'll talk tomorrow."*

**[End call]**

---

## The 60-Second Close (Narrator Voice-Over)

> *"In one phone call, Arjun got everything done:*
>
> *→ Checked his stalled claim*
> *→ Learned exactly what documents were missing*
> *→ Verified his home policy coverage*
> *→ Filed a brand new claim — no forms, no email, no waiting*
> *→ Got escalated to a senior specialist*
> *→ Scheduled a callback for tomorrow*
>
> *No hold music. No transferring between departments. No lost claims. All in under 5 minutes."*

**[Switch to Analytics tab]**

> *"And everything he said was logged, structured, and searchable. The insurance company has full transparency into every call, every tool the AI fired, and every decision made."*

**[Switch back to Claims — show the new claim at the top]**

> *"This is what insurance customer service should feel like in 2026. Thanks."*

---

## Claim Numbers to Memorize

| Customer | Claim # | Status | Use For |
|----------|---------|--------|---------|
| **Arjun Mehta** | **CLM-2026-000456** | under_review | 🎯 Main demo |
| Arjun's home policy | **POL-2024-005678** | active | 🎯 Main demo (file_claim) |
| Rohit Kapoor | CLM-2026-000789 | denied | Backup: escalation demo |
| Ananya Iyer | CLM-2026-000112 | submitted | Backup: theft example |
| Rahul Nair | CLM-2026-000345 | documents_needed | Backup: fire damage |

---

## Recovery Phrases (If Agent Goes Off-Script)

- **If Ansh asks a clarifying question you didn't expect:** *"Got it, that's fine — let me just continue."*
- **If a tool fails:** *"Ansh, let me just double-check my claim number — yes, CLM-2026-000456."*
- **If you get confused:** *"Sorry Ansh, can you repeat that?"*
- **If the call drops:** Start again — seed data is stable, claim will still be there.

---

## One-Line Pitch (For the Slide Deck)

> **"ClaimsAgent replaces insurance call centers with AI voice agents that file claims, resolve questions, and escalate complex cases — handling 80% of routine calls at 1/10th the cost. $840 billion market. Built on ElevenLabs."**
