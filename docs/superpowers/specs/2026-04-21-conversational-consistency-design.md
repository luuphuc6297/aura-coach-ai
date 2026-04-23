# Conversational Consistency — Design Spec

**Date:** 2026-04-21
**Owner:** Luu
**Scope:** Story Mode + Scenario Coach Mode (foundation for all future conversational modes)

---

## Why this spec exists

Luu reported 6 bugs on Story Mode Round 4, but the root cause is that **Story Mode and Scenario Coach Mode diverged in conversational behaviour** — Back button, loading state, Stop button, session lifecycle, conversation filtering, level filtering. Conversational logic must be unified because all 6 modes of Aura Coach AI share the same turn-based chat pattern.

On top of unification, Luu added three product-level concerns that only make sense once consistency is in place:

1. **Storage quota** — prevent unbounded Firestore growth across 6 modes used for months by heavy learners.
2. **Stop button for Scenario** — Scenario currently has no way to cancel a slow Gemini request.
3. **End-session confirmation redesign** — current confirm dialogs are thin; they should carry session stats + quota reminders so Back/End actions feel meaningful.

This spec defines the 4 pillars that will be implemented in a single coherent change, plus the target pattern for every future conversational mode.

---

## Pillars

### Pillar 1 — Session lifecycle consistency (Back button + filtering)

**Current state:**

| Behaviour | Scenario Coach | Story Mode | Decision |
|---|---|---|---|
| Back button | Shows dialog "Continue / End & Review" | Calls `abandonSession()` → navigates `/home` | Align Story to Scenario |
| Session status on abandonment | Stays `in-progress` (no abandon call) | Writes `abandoned` to Firestore | Remove `abandoned` state |
| History filter | `status != 'completed'` | `status == 'in-progress'` | Use `!= 'completed'` everywhere |
| Navigation after end | `context.push('/scenario/summary')` (keeps stack) | `context.go('/story/summary')` (clears stack) | Use `push` everywhere |

**Target pattern (one rule for every mode):**

- Back button always opens an **end-session dialog** with two options: **Continue** (dismiss) and **End & Review** (writes `completed`, pushes summary).
- There is no `abandoned` status. A session is either `in-progress` or `completed`. If a user kills the app mid-chat, the session stays `in-progress` and resumes next time.
- History sheet and home-screen "resume" popup filter by `status != 'completed'`.
- Navigation uses `push` for summary so the back-stack is preserved and `context.pop()` returns the learner to Home naturally.

**Consequence:** `StorySessionStatus.abandoned` is removed from the model. Any existing Firestore docs with `status: 'abandoned'` are migrated forward on read by treating them as `in-progress`. `StoryProvider.abandonSession()` is deleted.

**User concern this solves:** Issue #2 (history popup never shows), Issue #3 (Back goes to Home), Issue #4 (no confirmation).

---

### Pillar 2 — Unified loading + Stop button (both modes)

**Current state:**

| Element | Scenario | Story | Decision |
|---|---|---|---|
| AI thinking indicator | Animated 3-dot `_TypingIndicator` | Animated 3-dot | Replace with text `Thinking…` widget |
| Stop button in input bar | Missing | Wired to `cancelCurrentMessage` | Port Story's wiring to Scenario |
| `cancelCurrentMessage` | Missing | Truncates user bubble as well | Fix: keep user bubble, only drop AI placeholder |
| Input disabled while AI is thinking | Already disabled | Already disabled | Keep |

**Target pattern (one rule for every mode):**

- Single shared widget `ThinkingIndicator` (text `Thinking…` with a subtle animated ellipsis) used for both chat turn-generation and assessment-report generation.
- `ChatInputBar` always takes `enabled` + `onStop` props. While `enabled == false`, the input field is locked and the send icon becomes a **Stop** icon calling `onStop`.
- `cancelCurrentMessage()` behaviour: monotonic seq gets bumped, in-flight Gemini future is dropped, **user bubble stays**, AI placeholder is removed, no assessment is generated for that turn, **but the turn still counts against the daily quota** (the token cost was already incurred).
- In Scenario, Stop cancels the in-flight assistant reply only; user bubble and prior turns are untouched. If Scenario's assistant reply includes per-turn assessment (to be verified during implementation), the assessment is dropped together with the reply.

**User concern this solves:** Earlier rounds (Scenario has no Stop), assessment-report loading shows inconsistent dots, token cost must still be charged when user stops.

**Business rule locked by Luu:** "user vào session rồi thoát ra thì vẫn phải được tính là một conversation". Stop does not refund quota. Starting a session and abandoning it does not refund the daily start.

---

### Pillar 3 — End-session confirmation redesign

A single shared widget `EndSessionDialog` replaces the current thin confirm dialogs in both Story and Scenario. Triggered by Back button or End button.

**Content (top to bottom):**

1. Title: `End this session?` (localizable).
2. **Session stats strip** (3 tiles):
   - `Turns` — `userTurnCount`
   - `Avg score` — `averageScore` rounded to 1 decimal (hidden if no scored turns yet)
   - `Duration` — `now - startedAt` formatted `mm:ss` for <1h, else `h:mm`
3. **Highlight line** (optional) — if any user turn has an assessment with score ≥ 85, show `🌟 Best line so far: "<first-6-words-of-that-turn>…"`. Skipped if no scored turns.
4. **Quota reminder line** — `<remainingStarts>/<dailyLimit> sessions left today` using `QuotaConstants` for the current mode and subscription tier.
5. Two buttons:
   - Secondary: `Keep going` (dismiss dialog, returns learner to chat)
   - Primary: `End & review` (writes `completed`, pushes summary screen)

**Design constraints:**

- Follows existing Clay design tokens: `AppColors.teal` primary for Scenario, `AppColors.purpleDeep` for Story, bottom-sheet shape with rounded top.
- Dialog is keyboard-safe (uses `MediaQuery.viewInsetsOf`) — if the learner taps Back while still typing, the dialog slides up without layout jump.
- Stats strip uses the same mini-card component as the existing assessment summary for visual consistency.

**Accessibility:** both buttons have semantic labels; the stats tiles are grouped under one `Semantics` label (`Session stats: 4 turns, average score 82.3, duration 5 minutes 12 seconds`).

---

### Pillar 4 — Storage quota (new feature)

**Problem Luu is solving:** learners who use the app for months across 6 modes will accumulate hundreds of Firestore conversation documents, increasing read cost per home-screen load and Firestore storage footprint. There is currently no cap.

**Decision summary (from Luu, 2026-04-21):**

- Storage is a **single aggregate count** of conversations across all modes (scenario + story + future 4 modes). Rationale: each mode has different per-turn token cost, so capping per mode is unfair to heavy scenario users / light story users. One global cap is simpler and token-cost-agnostic.
- Tiers: **free = 20**, **premium = 500**. Numbers are placeholders — Luu can tune anytime before launch.
- Counted items: every conversation document across all modes, regardless of status (`in-progress` or `completed`).

**Thresholds and behaviours:**

| State | Count | Behaviour |
|---|---|---|
| Healthy | `< 80% of cap` | No UI change. |
| Soft warning | `>= 80% and < 100%` | Home screen shows a dismissible banner with a **per-mode breakdown** (e.g. `Story 8 · Scenario 10 · Others 0`) and an aggregate line `18/20 conversations used. Delete old ones or upgrade to keep chatting.` Banner has two CTAs: `Manage` (opens Conversation History) and `Upgrade` (opens paywall). Reappears after 24h even if dismissed. |
| Hard cap | `>= 100%` | All "Start new" entry points (Begin Scenario, Begin Story, …) are **disabled for new-session creation only**. Tapping a disabled button shows a snackbar: `Storage full. Delete a conversation or upgrade to start a new one.` with a compact inline `Upgrade` action. Learners retain full access to **existing** conversations: they can open, resume, and complete `in-progress` ones and view `completed` ones for review. The restriction is creation-only. |

**Where the counting happens:**

- New provider `StorageQuotaProvider` watches `users/{uid}/conversations` count via a Firestore aggregation query (`count()` — one billed read per check) and caches the number with a 60-second TTL. Invalidated immediately after any `saveConversation` / `deleteConversation` local call.
- Home screen subscribes to this provider; entry-point buttons are wired to it.
- Subscription tier provider (existing) decides which cap applies.

**Implementation note:** Firestore `count()` aggregation on a sub-collection does not require a composite index when no filter fields are used. If future iterations need per-mode count, a composite index on `(mode)` will be added then.

**User concern this solves:** "nếu user cứ tạo mới liên tục thì sao, nếu user sử dụng 2 tháng cứ tạo mới liên tục conversation cho tất cả các mode thì sao". Hard cap prevents unbounded database growth; soft warning gives users time to clean up or upgrade.

**Interaction with existing `QuotaConstants`:** Storage quota (this pillar) and daily start quota (`QuotaConstants`) are independent. A user can hit the daily quota without hitting storage, and vice versa. Home screen entry-point button state becomes:

```
enabled = dailyQuotaRemaining > 0 AND storageUsage < storageCap
```

Disabled reason shown in snackbar is whichever check failed first (daily first, storage second).

---

## Out of scope for this spec

- Localization (Vietnamese copy). English copy ships first; Luu will translate before release.
- Deleting conversation documents from Firestore UI — already tracked separately; this spec only wires the `Manage` CTA target.
- Migrating existing Firestore docs with `status: 'abandoned'`. Read-side compatibility is enough (map `abandoned` → treat as `in-progress`). No backfill script needed since the data volume is tiny at this stage.
- Other conversational modes (Debate, Interview, etc.) — the patterns in Pillars 1-3 will be applied when those modes are built, not now.

---

## Files that will change

**New:**
- `lib/shared/widgets/thinking_indicator.dart`
- `lib/shared/widgets/end_session_dialog.dart`
- `lib/features/shared/providers/storage_quota_provider.dart`
- `lib/shared/widgets/storage_quota_banner.dart`

**Modified:**
- `lib/features/story/screens/story_chat_screen.dart` — remove `_onBackPressed` logic, adopt dialog
- `lib/features/story/providers/story_provider.dart` — drop `abandonSession`, fix `cancelCurrentMessage` bubble retention, tighten filter
- `lib/features/story/models/story_session.dart` — remove `StorySessionStatus.abandoned`
- `lib/features/scenario/screens/scenario_chat_screen.dart` — replace `_TypingIndicator`, add Stop button wiring, use shared dialog
- `lib/features/scenario/providers/scenario_provider.dart` — port `cancelCurrentMessage`, seq invalidation, 30s timeout
- `lib/features/home/screens/home_screen.dart` — consume `StorageQuotaProvider` for entry-point button state, host banner
- `lib/features/home/widgets/start_story_sheet.dart` — relaxed filter `status != 'completed'`
- `lib/data/repositories/story_repository.dart` — add "Other levels" section support (see next file)
- `lib/features/story/screens/story_home_screen.dart` — render "Featured for you" + "Other levels" two-section layout
- `lib/data/datasources/firebase_datasource.dart` — add `countConversations(uid)` aggregation query
- `lib/core/constants/quota_constants.dart` — add `kStorageCapFree = 20`, `kStorageCapPremium = 500`, `kStorageWarningThreshold = 0.80`

**Note on "Other levels":** Luu approved a section approach (not a filter chip) so current layout stays clean. `StoryRepository.fetchFeatured(level: ...)` returns the primary list; a sibling method `fetchOtherLevels(level: ...)` returns all stories NOT at the user's level, sorted by level distance. `StoryHomeScreen` renders both sections.

---

## Testing strategy (high level; full test plan lives in the implementation plan)

- Unit: `StorySession.fromJson` accepts `status: 'abandoned'` and normalises to `in-progress`.
- Unit: `cancelCurrentMessage` keeps user bubble, drops AI placeholder, leaves seq advanced.
- Unit: `StorageQuotaProvider` returns correct state across `healthy / warning / cap` boundaries with mocked count.
- Widget: Back button on Story chat opens `EndSessionDialog`; dialog shows stats + quota line.
- Widget: Stop button on Scenario chat cancels in-flight AI reply; input re-enables; user bubble persists.
- Widget: Home screen start buttons disable when storage at cap; banner visible when ≥ 80%.
- Integration: full Story session → Back → Keep going → continue; full Scenario session → Stop → resume input → End & review.

---

## Open questions for Luu (review gate)

1. **Storage display copy** — is a single number `18/20` acceptable, or should the soft-warning banner also show per-mode breakdown (e.g. `Story: 8, Scenario: 10`)? My recommendation: single aggregate number on banner, per-mode breakdown only on the Conversation History screen.
2. **Hard-cap UX** — when the learner taps a disabled `Start` button, do we want a snackbar (current proposal) or a modal bottom sheet with Upgrade CTA? Snackbar is lighter-weight; modal is more "sales-y". I'd ship snackbar first.
3. **"Other levels" ordering** — sort by closest level first (A2 before A1 for a B1 learner), or mix randomly? I'd pick closest-first because it's the gentlest difficulty ramp.

Answer these three and I'll lock the plan.

---

## Interpretation note Luu should verify

Luu's answers 1 and 4 on storage quota read as a tension on first pass:

- Answer 1: "B là total quote cho từng mode"
- Answer 4: "Tính tổng số conversation của tất cả các mode"

My reading: the **counting unit** is the aggregate across all modes (Answer 4 is authoritative); the **rationale** in Answer 1 is that modes consume tokens differently, which is why we picked a single global cap instead of per-mode caps. If my reading is wrong — and you actually want separate counters per mode with per-mode caps — say so now and I'll rewrite Pillar 4 before the plan is written.
