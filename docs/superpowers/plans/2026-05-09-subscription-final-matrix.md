# Subscription Final Matrix — Locked

**Date:** 2026-05-09
**Status:** Quotas locked. Pricing pending — wait for 1-week real-data dogfood per user direction.
**Tier model:** 3-tier (Free + Pro + Premium)

---

## A. Custom Topic (global, surfaced in Onboarding flow)

| Tier | Total custom topics user can add (lifetime) |
|------|---------------------------------------------|
| Free | **1** |
| Pro | **4** (1 + 3 added) |
| Premium | **9** (1 + 3 + 5 added) |

Topics show as global list in onboarding screen + profile. Used by Scenario Coach + Story Mode + future modes that pick a topic.

---

## B. Scenario Coach (LOCKED — total turns w/ geometric decay refill + monthly cap)

### B.1 Session storage (lifetime)

| | Free | Pro | Premium |
|---|------|------|---------|
| Sessions stored max | **3** | **8** | **15** |

Reach session limit → must delete an old conversation to create new.

### B.2 Total turns budget (account-wide, NOT per-conversation)

| | Free | Pro | Premium |
|---|------|------|---------|
| Day 1 refill (max) | **10** | **25** | **40** |
| Decay rate per day | × 0.7 | × 0.7 | × 0.7 |
| Monthly hard cap | **30 turns/month** | **80 turns/month** | **130 turns/month** |

**Decay schedule:**

| Day | Free | Pro | Premium |
|-----|------|-----|---------|
| 1 | 10 | 25 | 40 |
| 2 | 7 | 18 | 28 |
| 3 | 5 | 12 | 20 |
| 4 | 3 | 9 | 14 |
| 5 | 2 | 6 | 10 |
| 6 | 2 | 4 | 7 |
| 7 | 1 | 3 | 5 |
| 8 | 1 | 2 | 3 |
| 9+ | 0 | 1 | 2 |

**Semantics:**
- Daily refill = `floor(max_refill × 0.7^(day_index - 1))`, floored at 0 after day 8-10
- Refills ACCUMULATE into bucket (leftover persists across days within a month)
- Monthly hard cap = absolute ceiling regardless of how many days passed
- Reset cycle on 1st of each month: Day 1 refill back to max
- Encourages daily engagement (front-load) then plateaus (push upgrade to Pro/Premium)

**Cost protection:**
- Worst case Premium 130 turns/mo × $0.000382/turn = $0.05/mo per user
- Vastly cheaper than previous per-conversation refill model

---

## C. Story Mode (LOCKED — same decay model as Scenario)

### C.1 Scenario storage (lifetime)

| | Free | Pro | Premium |
|---|------|------|---------|
| Built-in scenarios available | **2** | **5** (2+3) | **13** (2+3+8) |
| Custom scenarios user creates | **0** | **2** | **5** |

Reach scenario storage limit → must delete old to add new.

### C.2 Total turns budget (account-wide, NOT per-scenario)

Same pattern as Scenario Coach: geometric decay + monthly hard cap.

| | Free | Pro | Premium |
|---|------|------|---------|
| Day 1 refill (max) | **10** | **25** | **40** |
| Decay rate per day | × 0.7 | × 0.7 | × 0.7 |
| Monthly hard cap | **30 turns/month** | **80 turns/month** | **130 turns/month** |

Decay schedule identical to Scenario §B.2.

### C.3 Architecture decision — Separate or shared with Scenario?

**Currently locked: Separate buckets** (Scenario monthly + Story monthly are independent).

Total monthly across both modes:
- Free: 30 + 30 = **60 turns/month**
- Pro: 80 + 80 = **160 turns/month**
- Premium: 130 + 130 = **260 turns/month**

Alternative considered: shared bucket (1 quota across Scenario + Story). Rejected because:
- Users typically prefer 1 mode strongly — sharing would force choice
- Separate buckets = clearer paywall messaging ("Pro: 80 Scenario turns + 80 Story turns")
- Implementation slightly more code but Provider-level decoupling worth it

---

## D. Vocab Hub (per-feature daily refill, NOT shared budget)

**Common semantics for D.1, D.2, D.3:**
- Daily refill = hard reset at 00:00 user-local
- ❌ No accumulation — leftover discarded, next day fresh N
- Each feature has its own quota (not shared pool)

### D.1 Word Analysis (analyze 1 word — morphology + examples + synonyms)

| Free | Pro | Premium |
|------|-----|---------|
| 5/day | 20/day | 50/day |

### D.2 Compare Words (compare 2 words)

| Free | Pro | Premium |
|------|-----|---------|
| 5/day | 20/day | 50/day |

### D.3 Describe Word (reverse dictionary)

| Free | Pro | Premium |
|------|-----|---------|
| 3/day | 15/day | 50/day |

### D.4 Mind Map (lifetime model, NOT refill)

| | Free | Pro | Premium |
|---|------|------|---------|
| Maps lifetime | 0 (locked) | **2** | **5** |
| Node expansions per map | n/a | 5 | unlimited |

Mind Map intentionally uses lifetime model because:
- Mind maps are persistent artifacts user invests effort building
- Daily refill encourages spammy throwaway maps
- Lifetime cap → user thoughtful about which words deserve a map

### D.5 Flashcards — DEFERRED REDESIGN

User to redesign as independent feature based on selected topics. Current implementation (pulling from SavedItem) is buggy and to be replaced. v1 strategy not finalized — see Task #170.

### D.6 Vocab Hub words store (separate from My Library)

User flagged: Vocab Hub should have its own words collection (used by Word Analysis cache, Mind Map seed, future Flashcards source). Currently shares SavedItem store. Refactor task: split Firestore collections (`users/{uid}/vocabWords/` separate from `users/{uid}/savedItems/`).

---

## E. Grammar Coach (LOCKED — daily quota, no accumulation)

| | Free | Pro | Premium |
|---|------|------|---------|
| **Turns / day** | **15** | **30** | **50** |
| Accumulation | ❌ no rollover | ❌ no rollover | ❌ no rollover |
| Topics catalog access | All 55 | All 55 | All 55 |
| Per-topic turn limit | n/a | n/a | n/a |
| Topic pickup limit | n/a | n/a | n/a |

**Semantics:**
- Hard daily cap. Used 5/15 turns → 10 wasted, tomorrow fresh 15 (does NOT add to leftover).
- No accumulation across days = predictable daily cost, encourages daily-habit study pattern
- User free to distribute across topics (focus 1 topic 15 turns OR 3 topics × 5 turns each)
- Hit cap → grammar practice blocked until next-day reset (00:00 user-local)
- Cost predictable: max 15/30/50 turns/day regardless of usage burst patterns

---

## F. My Library (saved items)

| | Free | Pro | Premium |
|---|------|------|---------|
| Save items lifetime cap | **30** | **100** | **200** |

---

## G. Story translate-on-tap (tap AI bubble for VN translation)

| | Free | Pro | Premium |
|---|------|------|---------|
| Translates / day | **50** | **200** | **500** |

---

## H. TTS / Listen feature (LOCKED with dual daily+monthly cap)

| | Free | Pro | Premium |
|---|------|------|---------|
| Native flutter_tts (on-device) | unlimited | unlimited | unlimited |
| Gemini AI TTS — daily cap | **20/day** | **100/day** | **200/day** |
| Gemini AI TTS — monthly cap | **50/month** | **200/month** | **400/month** |
| Native fallback when AI quota exhausted | yes | yes | yes |

**Semantics:**
- Daily cap = rate-limit burst usage (prevents 1-day spike)
- Monthly cap = hard cost ceiling (prevents abuse over month)
- Hit either cap → automatic fallback to native flutter_tts
- Reset: daily at user-local 00:00, monthly at 1st of month

**Per-tier monthly TTS cost (Gemini Flash TTS, estimated):**
| Tier | Max calls/mo | Low cost ($0.0003/call) | High cost ($0.0015/call) |
|------|--------------|----------------------------|-----------------------------|
| Free | 50 | $0.015/mo | $0.075/mo |
| Pro | 200 | $0.060/mo | $0.30/mo |
| Premium | 400 | $0.120/mo | $0.60/mo |

Predictable. Margin protected even at worst-case pricing.

---

## I. Pay-per-use IAP (consumable)

| Product | Price (VND) | Notes |
|---------|-------------|-------|
| AI Illustration single | **5,000đ** | ~$0.20 |
| AI Illustration 5-pack | **20,000đ** | save 20%, ~$0.80 |

Available for all tiers. Subscription does NOT include illustrations — pay-per-use only.

---

## J. Deferred to v1.1+

- **AI Agent help chat** — quota model TBD (Task #171)
- **Flashcards** — redesign required (Task #170)
- **Insights AI Weekly Summary** (Pro) / Monthly Report (Premium) — future feature
- **Saved Item enrichment** — currently auto-calls dictionary on save with own quota; will fold into unified QuotaEngine
- **Premium AI Voice TTS exclusive features** — already counted in §H but UI exposure post-launch

---

## K. Pricing — NOT LOCKED

User direction: setup logging infrastructure first, dogfood 1 week, then lock pricing based on real data.

### Pre-launch tasks before pricing decision

1. Verify `gemini-3-flash-preview` and `gemini-2.5-flash-preview-tts` actual rates on Google AI pricing page
2. Build per-call cost logging → Firestore `users/{uid}/aiUsage/{yyyymmdd}` with token count + cost
3. Dogfood 7 days with 5-10 beta testers
4. Aggregate data → realistic cost/user/day per tier
5. Lock pricing with 60-90% margin target

### Tentative pricing (subject to verification)

| | Monthly | Yearly | Notes |
|---|---------|--------|-------|
| Free | $0 | — | |
| Pro | $7-10 USD | 40% off | Final TBD |
| Premium | $15-20 USD | 40% off | Final TBD |

VN auto-localize: Pro ~199-249k/mo, Premium ~379-499k/mo.

---

## L. Commission & Fees Stack (RevenueCat + Apple/Google + VAT)

### L.1 Key clarification — RevenueCat does NOT replace Apple/Google fees

RevenueCat is an SDK wrapper, NOT a mobile payment processor. Internally it calls:
- iOS: Apple StoreKit
- Android: Google Play Billing

Payment still flows through Apple/Google. They take their commission FIRST. RevenueCat adds 1% on top (above $2.5k MTR threshold) only as an analytics + cross-platform entitlement-sync layer. **Fees stack; they do not replace each other.**

### L.2 Payment flow

```
User taps "Subscribe $9.99"
       │
       ▼
Apple StoreKit / Google Play Billing   ← RevenueCat SDK invokes this
       │
       │ Apple/Google retain 15–30% commission FIRST
       │ VN VAT 10% withheld by store
       │
       ▼
Net amount routed to dev account
       │
       │ RevenueCat tracks event (no money flow through RC)
       │
       ▼
Developer payout (App Store Connect / Google Play Console)
```

### L.3 Net revenue — Pro $9.99/month (Vietnam market)

| Fee layer | Year 1 (standard 30%) | Year 2+ (Small Business 15%) |
|-----------|------------------------|-------------------------------|
| Gross | $9.99 | $9.99 |
| − Apple/Google commission | −$3.00 | −$1.50 |
| − VN VAT 10% (store withholds) | −$1.00 | −$1.00 |
| **Net after store** | **$5.99** | **$7.49** |
| − RevenueCat 1% (only above $2.5k MTR) | −$0.06 | −$0.07 |
| **Net to developer** | **~$5.93** | **~$7.42** |

### L.4 Net revenue — Premium $19.99/month

| Fee layer | Year 1 (30%) | Year 2+ (15%) |
|-----------|--------------|----------------|
| Gross | $19.99 | $19.99 |
| − Apple/Google commission | −$6.00 | −$3.00 |
| − VN VAT 10% | −$2.00 | −$2.00 |
| **Net after store** | **$11.99** | **$14.99** |
| − RevenueCat 1% | −$0.12 | −$0.15 |
| **Net to developer** | **~$11.87** | **~$14.84** |

### L.5 Apple Small Business Program (auto-enroll)

- Reduces Apple commission from 30% → 15% if total annual proceeds < $1M USD
- Auto-enroll for eligible developers (no application required)
- Resets each calendar year — if proceeds exceed $1M, commission reverts to 30% for the rest of that year
- Google Play has equivalent program: 15% on first $1M/year per developer

At launch scale, both auto-apply → effective commission **15%** from year 1.

### L.6 RevenueCat free tier (MTR-based)

- $0 fee on first $2,500 MTR (Monthly Tracked Revenue, computed on gross)
- 1% fee only on the portion of revenue ABOVE $2,500/month
- Launch phase (1k MAU, ~50 Pro users → ~$500 MTR) → **RevenueCat = $0/month**
- Crosses 1% threshold roughly at 250 Pro users on $9.99 plan

### L.7 Vietnam VAT 10%

Apple/Google withhold VAT 10% on Vietnam transactions and remit to Vietnamese tax authority directly. Developer's payout report shows net (post-VAT, post-commission) figure.

Note: VN consumers see prices INCLUDING VAT. Pricing strategy must factor this in:
- Display 249,000đ on App Store → dev nets ~149,400đ (after 15% commission + 10% VAT, year 2+)
- Display 499,000đ Premium → dev nets ~299,400đ

### L.8 Cannot bypass Apple/Google fees while on App Store / Play Store

Per App Store Guideline 3.1.1 and Google Play Payments policy:
- In-app subscriptions MUST use platform IAP (StoreKit / Google Play Billing)
- Cannot link to external web checkout from in-app context (post-Epic v. Apple 2024 ruling, allowed with disclaimer screens + Apple's External Link Account Entitlement, but Apple still takes 12–27% commission on external transactions)
- Stripe web checkout viable only for marketing site / sign-up outside app — not a real escape valve for mobile IAP

Conclusion: Apple/Google commission is **unavoidable** for mobile in-app subscriptions. Build pricing model with this as baseline assumption.

### L.9 Effective gross margin (after all fees)

Using realistic AI cost figures from §M:

| | Pro | Premium |
|---|-----|---------|
| Gross price | $9.99 | $19.99 |
| Net after fees (year 1, 30% commission) | $5.93 | $11.87 |
| Net after fees (year 2+, 15% commission) | $7.42 | $14.84 |
| Realistic AI cost (§M) | $1.98 | $6.48 |
| **Gross margin year 1** | **67%** | **45%** |
| **Gross margin year 2+** | **73%** | **56%** |

Premium margin lower because TTS + Translate-on-tap + Vocab quotas higher. Premium tier is primarily value-add for committed learners, not the margin driver. Pro is the volume + margin tier.

### L.10 One-line summary

> RevenueCat = SDK middleman so we don't have to code StoreKit + Google Billing ourselves + get analytics + webhook + cross-platform entitlement sync. Money still flows through Apple/Google, still taxed 15–30% by them. RevenueCat takes additional 1% but only when MTR > $2.5k. Launch-phase effective fee = **15% (Apple/Google Small Business) + 10% VAT VN + $0 RevenueCat**.

---

## M. AI cost estimates per tier (NEEDS VERIFICATION)

Token rate assumptions (gemini-2.5-flash baseline; gemini-3-flash-preview rate TBD):
- Input: $0.075 / 1M tokens
- Output: $0.30 / 1M tokens
- TTS: ~$0.50 / 1M input tokens (preview, est)

### Cost MAX (monthly hard caps applied)

| Component | Free / month | Pro / month | Premium / month |
|-----------|--------------|-------------|------------------|
| Scenario (30/80/130 monthly cap) | **$0.011** | **$0.031** | **$0.050** |
| Story (30/80/130 monthly cap, same decay) | **$0.010** | **$0.028** | **$0.045** |
| Grammar (15/30/50 daily reset) | $0.11 | $0.22 | $0.37 |
| Word Analysis (5/20/50 daily reset) | $0.07 | $0.30 | $0.74 |
| Compare Words (5/20/50 daily reset) | $0.04 | $0.14 | $0.36 |
| Describe Word (3/15/50 daily reset) | $0.009 | $0.044 | $0.147 |
| Translate-on-tap (50/200/500 daily) | $0.07 | $0.27 | $0.68 |
| TTS AI (50/200/400 monthly hard cap) | $0.015 | $0.060 | $0.120 |
| Mind Map (rare, lifetime) | $0 | ~$0.001 | ~$0.004 |
| **Total / month MAX** | **$0.39** ↓ | **$1.47** ↓ | **$4.49** ↓ |
| Realistic 30% | **~$0.12** | **~$0.44** | **~$1.35** |

### Cost realistic (30% utilization typical engagement)

| Tier | Realistic monthly cost |
|------|------------------------|
| Free | $0.41 |
| Pro | $1.98 |
| Premium | $6.48 |

### Margin scenarios (tentative pricing)

| | Pro $9.99 | Pro $7.99 | Premium $19.99 | Premium $14.99 |
|---|-----------|-----------|------------------|------------------|
| Realistic margin | 80% | 75% | 68% | 57% |
| MAX margin | 34% | 17% | 0%* | -44%* |

*Premium MAX scenario primarily driven by TTS quota — if Premium user maxes TTS daily 300 times the AI cost spikes. Mitigation: cap TTS aggressively or add monthly TTS cap (e.g., 5000/month).

---

## N. Open issues for discussion

1. ~~TTS quota contradiction~~ — **RESOLVED**: dual cap (daily + monthly) shared pool, native fallback always available. See §H.
2. **Flashcards quota** — depends on redesign outcome (Task #170)
3. **Saved Item enrichment quota** — folds into QuotaEngine; currently uses standalone `ensureDictionaryQuota` guard
4. ~~App Store / Play Store 30% commission~~ — **RESOLVED**: 15% via Apple/Google Small Business at launch scale. See §L.3, §L.5.
5. ~~RevenueCat fee~~ — **RESOLVED**: $0 below $2.5k MTR, 1% above. See §L.6.
6. ~~VN tax~~ — **RESOLVED**: VAT 10% withheld by Apple/Google directly. See §L.7.

---

## O. Implementation impact (Phase A QuotaEngine)

`QuotaConstants` matrix needs ~25 quota types tracked:

```
Per-day reset (refill 0:00 user-local):
- scenario_turns_per_conversation_refill
- story_turns_per_scenario_refill
- grammar_topics_pickup
- grammar_turns_per_topic
- vocab_word_analysis
- vocab_compare_words
- vocab_describe_word
- translate_on_tap
- tts_ai_pool

Lifetime caps:
- custom_topics_added
- scenario_sessions_stored
- scenario_turns_per_conversation
- story_built_in_scenarios_available
- story_custom_scenarios
- story_turns_per_scenario
- vocab_mind_maps
- vocab_mind_map_node_expansions
- library_saved_items

IAP credits:
- illustration_credits
```

Each requires:
- `getLimit(tier, type)` lookup
- `consume(uid, type, amount)` atomic Firestore txn
- `peek(uid, type)` for UI gauges
- daily reset key generation (yyyymmdd in user TZ)

---

## P. Next concrete actions

1. ~~Resolve TTS quota contradiction (§N.1)~~ — done, see §H
2. Update `lib/core/constants/quota_constants.dart` with 3-tier matrix
3. Phase A — QuotaEngine domain layer + UsageCounters model
4. Phase A.1 — `aiUsage` logging infrastructure (Firestore subcollection)
5. Verify Gemini pricing on official page
6. Phase B — Migrate existing guards
7. Dogfood 7 days
8. Lock pricing using §L net-revenue formulas (target 65–75% gross margin year 1, accounting for Apple/Google 15% + VAT 10%)
9. Phases E, F, G, I, J, K
