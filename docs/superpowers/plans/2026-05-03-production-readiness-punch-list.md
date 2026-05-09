# Production Readiness Punch List — 10-30 Day Window

**Date:** 2026-05-03
**Target release window:** 30 days (split into 3 sprints)
**Source:** 2 parallel audit agents + existing task backlog (151–163)

Tổng cộng **62 items** chia thành **6 buckets** theo severity. Sprint plan ở §7.

## Bucket A — Production Blockers (P0, MUST FIX)

Không qua được App Store / Play Store review hoặc gây cost/security disaster nếu không fix.

### Security & Compliance

1. ☐ **Mismatched Firebase projects** — iOS dùng `emerald-green-1754237937`, Android/web dùng `aura-coach-ai`. Users không sync cross-platform. **Action:** thống nhất 1 project, regen `firebase_options.dart`, re-test auth flow trên cả 2 OS.
2. ☐ **API keys leak trong source** — Firebase config + Gemini key trong `.env` đã commit. **Action:** rotate tất cả keys + apply API key restrictions (Firebase App Check, IP/bundle restrictions trên Google Cloud Console). Thêm `.env` vào `.gitignore` nếu chưa.
3. ☐ **iOS Info.plist thiếu privacy descriptors** — Sẽ bị App Store reject. Thêm:
   - `NSMicrophoneUsageDescription` (TTS feature)
   - `NSCameraUsageDescription` (avatar selection)
   - `NSUserTrackingUsageDescription` (RevenueCat ATT)
   - `NSPhotoLibraryUsageDescription` nếu có image picker
4. ☐ **Android ProGuard disabled** — `isMinifyEnabled = false`. Bật minify + add ProGuard rules cho `purchases_flutter`, `firebase_*`, `google_sign_in`, `flutter_local_notifications`.
5. ☐ **Apple Sign-In entitlements** — `sign_in_with_apple` v7 trong pubspec nhưng không có entitlements file validated. Add Sign In with Apple capability trong Xcode + entitlements.

### Cost Control (Unbounded API Spend)

6. ☐ **Story session — no quota gate** trên `_startSession()`. Free user spam "New Story" → unlimited Gemini billing.
7. ☐ **Scenario session — no pre-charge** trong `generateNextLesson()`; user abort → duplicate charges trên retry.
8. ☐ **Grammar exercise loop — no quota gate** trên `nextExercise()`; user generate vô hạn exercises.
9. ☐ **AI Agent help chat — no quota gate** trên `send()`; unlimited Ask AI.
10. ☐ **Compare Words — no quota guard** trên generate analysis.
11. ☐ **Vocab Hub initial-grant 20 + 3/day** — chưa wire (Phase B); free user dùng vô hạn AI calls.

### Subscription Stack Hoàn Chỉnh

12. ☐ **Phase A: QuotaEngine + UsageCounters domain** (Task #153). Single source of truth cho tất cả gating.
13. ☐ **Phase B: Migrate scattered guards → QuotaEngine + daily reset logic + 20-grant Vocab Hub** (Task #154).
14. ☐ **Phase F: Cloud Function v2 RevenueCat webhook + Firestore rules + audit log** (Task #158). Truth-source-of-tier.
15. ☐ **Phase E: Quota wall dialog + Pro lock cards + initial-grant modal** (Task #157). Wire to all gated features.
16. ☐ **Phase G: Consumable IAP flow** (Task #159) — custom topic/context credits.

## Bucket B — User-Facing Reliability (P1)

Không phải store-blocker nhưng users sẽ frustrated → bad reviews.

### Error State Coverage

17. ☐ **describe_word_provider:37** — error swallow, screen không show toast. Wire `_error` → snackbar.
18. ☐ **story_provider:348** — TimeoutException caught nhưng UI không guarantee rebuild. Add error toast.
19. ☐ **ai_agent_chat_provider:97** — race condition khi send-while-sending=true.
20. ☐ **scenario_provider:225** — Gemini fail → silent cache fallback. Add "offline mode" toast khi `_currentScenarioSource == cache`.
21. ☐ **grammar_provider:139** — hydrateProgress catch swallow → first-tap generation error. Surface error.
22. ☐ **notifications_screen** — không phân biệt loading vs error-loaded khi list rỗng.
23. ☐ **my_library_screen** — Firestore query fail → blank list, no error UI.

### Empty State Coverage

24. ☐ **story_home_screen** — featured stories ListView không có empty state.
25. ☐ **conversation_history_screen** — filtered conversations không có empty guard.
26. ☐ **progress_dashboard_screen** — GridView skill cards không empty state cho cold-start.
27. ☐ **insights_screen** — multiple chart widgets crash khi data rỗng.

### Loading State Coverage

28. ☐ **mind_map_provider.generateNewMap** — race condition canvas render trước khi root node generated.
29. ☐ **compare_words_provider** — không có `_loading` field; suy luận từ `_result == null` unreliable.
30. ☐ **flashcards_provider.loadDueToday** — không clear `_isLoading`; tab spin vô hạn nếu Firestore hang.
31. ☐ **grammar_topic_detail_screen** — render trước khi hydrateProgress complete (timing gap mạng chậm).

### Asset Reliability

32. ☐ **CloudinaryAssets fallback** — mode card icons (home_screen:462+), avatars (edit_profile:65+), splash orb. Add `errorWidget` cho `cached_network_image` hoặc local SVG fallback.
33. ☐ **bottom_nav_bar:56** — nav icon Cloudinary URL no fallback.

## Bucket C — i18n Gaps (P1)

VN locale claim nhưng còn nhiều English hardcoded. Bad UX cho target market.

34. ☐ **scenario_chat_screen:32-68** — `_topicLabels` hardcode 16 topic names (Travel, Business, Daily Life…).
35. ☐ **flashcards_tab:86** — `'Card X of Y'` hardcoded.
36. ☐ **notifications_screen:46** — "Mark all read" hardcoded.
37. ☐ **my_library_screen:52-88** — `_typeLabels`, `_posLabels` (noun/verb/adj/adv) hardcoded.
38. ☐ **ai_agent_chat_provider:43** — welcome message Vietnamese-only, no English fallback.
39. ☐ **subscription_screen** — toàn bộ paywall copy hiện hardcode EN. Migrate sang ARB (Phase I, Task #161).
40. ☐ **i18n Task 9** (Task #135) — Story chat hints + summary screens + Story Home + custom form.
41. ☐ **Dark mode Task** (Task #122) — finalize ThemeExtension + bulk surface migration audit.
42. ☐ **VI localization Task** (Task #123) — finalize coverage check.

## Bucket D — Backend & Deployment (P1)

### Firestore

43. ☐ **firestore.indexes.json incomplete** — chỉ có 1 index. Add composite cho:
    - `conversations` (mode + createdAt desc)
    - `savedItems` (userId + updatedAt desc)
    - `stories` (mode + order)
    - `mindMaps` (userId + updatedAt desc)
    - `grammarAttempts` (topicId + isCorrect + timestamp desc)
44. ☐ **Rate-limiting rules** — không có write throttle. User spam writes → Firestore quota exhaustion.
    Add Cloud Function rate limit hoặc App Check.

### CI/CD

45. ☐ **No `.env.example`** — onboard new dev. List required keys + dummy values.
46. ☐ **No staging environment** — TestFlight/internal track go direct từ tag. Add staging Firebase project + workflow.
47. ☐ **No lint/test gate trong CI** — `ci.yml` chưa rõ. Add `flutter analyze --fatal-infos --fatal-warnings` + `flutter test --coverage` step.

### Versioning

48. ☐ **No CHANGELOG.md** — track release history.

## Bucket E — Test Coverage (P2)

Tests existing: 8 files (sm2, story_provider, story_repo, story_cache, story_session_status, storage_quota). **Coverage <2%.**

49. ☐ **grammar_provider_test** — exercise generation, EWMA mastery, session lifecycle, sessionMistakes accumulation.
50. ☐ **scenario_provider_test** — dedup logic + seenSentences exclusion.
51. ☐ **mind_map_provider_test** — seed flow, expand depth, position autosave.
52. ☐ **compare_words_provider_test** — generate flow + error handling.
53. ☐ **describe_word_provider_test** — reverse dictionary + parser.
54. ☐ **library_provider_test** — addItem, dedup, type filtering, masteryScore.
55. ☐ **subscription_provider_test** — entitlement read, login/logout sync, purchase result wrapping.
56. ☐ **quota_engine_test** — daily reset key generation across timezones, transactional consume, IAP credit grant.
57. ☐ **Widget tests** cho ít nhất paywall + quota wall + grammar practice screen.

## Bucket F — Polish (P2 / Defer to v1.1)

58. ☐ **Plugin deprecation cleanup** — `setDebugLogsEnabled` → `setLogLevel`, `keyWindow` deprecation, etc. Most are SDK warnings; safe to defer if upgrade timeline clear.
59. ☐ **Subscription Phase J** (Task #162) — refund clawback / family sharing / downgrade / offline / clock skew edge cases.
60. ☐ **Subscription Phase K** (Task #163) — verification + smoke flow.
61. ☐ **App Store / Play Store metadata** — screenshots, description, keywords, category, age rating, privacy nutrition labels.
62. ☐ **Crashlytics + Analytics** — `firebase_crashlytics` chưa wire. Add cho post-launch debugging + retention metrics.

## §7. Sprint Plan (3 × 10 days)

### Sprint 1 (Days 1-10) — Cost Control + Security Foundation

**Goal:** Không bị bankrupt từ Gemini bills + qua App Store privacy review.

- Bucket A items 1-11 (security + cost control gates)
- Bucket A items 12-13 (Phase A + B QuotaEngine + reset logic)
- 1, 2, 3, 4, 5 (privacy descriptors + ProGuard + Apple Sign-In)
- 6-11 (quota gates trên 6 features)
- 32-33 (Cloudinary fallback)

**Deliverable:** Free user không thể spam unlimited AI calls. App qua được initial Apple privacy check.

### Sprint 2 (Days 11-20) — Paywall + Webhook + UX Reliability

**Goal:** Real subscription flow ship-able + UX không break trên slow network.

- Bucket A items 14-16 (Phase E + F + G — paywall walls + webhook + IAP)
- Bucket B items 17-31 (error/empty/loading states)
- Bucket D items 43-44 (Firestore indexes + rate limit)

**Deliverable:** End-to-end purchase flow works. Error/empty/loading states cover top user-facing screens.

### Sprint 3 (Days 21-30) — i18n + Tests + Submission Prep

**Goal:** VN market ready + minimum test confidence + ready submit stores.

- Bucket C items 34-42 (i18n + Dark mode + VI completion)
- Bucket D items 45-48 (CI/CD + CHANGELOG)
- Bucket E items 49-57 (top priority tests — providers + quota engine)
- Bucket F items 58-62 (polish + Crashlytics + store metadata)

**Deliverable:** App localized fully en+vi. Test coverage > 30%. Submitted to App Store + Play Store internal track.

## Dependencies Map

```
Phase A (QuotaEngine domain) ─┬─→ Phase B (migrate guards) ─┬─→ Phase E (quota walls)
                              │                              │
Phase C+D (RC SDK + paywall) ─┼─→ Phase F (webhook) ──────────┼─→ Phase G (IAP)
                              │                              │
                              └─→ Phase H (manage sub) ───────┘
                                                              │
                                                              ↓
                                                          Phase J (edge cases) → K (verify)
```

## Out of Scope (defer to v1.1+)

- Promo / discount codes
- Family / Student plans
- Lifetime tier
- Web Stripe checkout
- A/B pricing experiments
- Avatar generation IAP (schema-ready, feature ships later)
- Premium tier (current 2-tier locks Pro only)
- AI weekly read-out (Insights deep-dive)
- Per-feature radar / trend lines

## Open Questions for Luu

1. **Webhook URL** — đã có Cloud Function URL chưa? Cần để config trong RevenueCat dashboard.
2. **App Store Connect / Play Console** — products + entitlement đã set chưa? Hiện code expect identifier `Aura Coach Pro`.
3. **Crashlytics opt-in** — bật ngay v1 hay defer? Cần thêm `firebase_crashlytics` package + initialize.
4. **Staging Firebase project** — tạo project riêng hay reuse `aura-coach-ai` với separate collections?
5. **Test infra** — accept coverage 30% v1 hay aim 60%?
