# Subscription + Monetization Plan

**Date:** 2026-04-30
**Status:** Locked decisions, ready to execute
**Owner:** Luu

## 1. Goals

Ship a complete monetization layer that turns Aura Coach AI from a free-only app into a sustainable product. Two pricing layers running together:

1. **Subscription** (Free + Pro) — recurring monthly/yearly. Pro raises daily quotas, unlocks Pro-only features, and offers higher caps on consumables.
2. **Consumable IAP** (one-shot purchases) — micro-transactions for users who exceed their cap on custom topics, custom contexts, and (future) avatar generation. Works for both Free and Pro users.

Cross-platform via **RevenueCat** SDK. Truth source for entitlement is **Firestore** (`users/{uid}.tier`), kept in sync by a **Cloud Function v2 webhook** RevenueCat fires on every purchase / renewal / refund event.

## 2. Decisions Locked

| # | Decision | Choice | Rationale |
|---|---------|--------|-----------|
| 1 | Tier structure | **2-tier: Free + Pro** | Simpler upsell; drop unused `premium` tier from `quota_constants.dart` |
| 2 | Payment platform | **RevenueCat** | Cross-platform IAP, free up to $2.5k MRR, handles receipt validation, restore, cancel deep-link |
| 3 | Free trial | **7-day on Yearly only** | Standard pattern; configured in App Store / Play Console (no code) |
| 4 | Pricing | **USD $9.99/mo, $71.88/yr** | App Store auto-localizes to VND for VN users |
| 5 | Pro feature gates | **MindMap unlock + raised AI quotas + higher (not unlimited) custom caps** | See § 4 quota matrix |
| 6 | Vocab Hub free | **20 lifetime AI calls then 3/day** | Applies to Analysis + Describe + Compare + Flashcards generate. Save to Library is free. Mind Map stays Pro-only |
| 7 | Custom topic/context IAP | **Free: 2 lifetime, Pro: higher cap, both can IAP after** | 3,000đ/topic, 5,000đ/context |
| 8 | Quota reset | **Daily 00:00 user-local time** | Predictable for VN users; custom topics/contexts are lifetime |
| 9 | Paywall entries | **Profile + Quota wall + Pro-locked feature card** | No onboarding paywall (avoid friction) |
| 10 | Receipt validation | **RevenueCat webhook → Cloud Function v2 → Firestore** | Truth source on Firebase, RevenueCat is cache |
| 11 | Manage / cancel | **Deep-link to App Store / Play Store** | App Store policy requires this; no in-app cancel |

## 3. Pricing & SKUs

### Subscription

| Plan | Price (USD) | Price (VND ~auto) | Trial | RevenueCat Product ID |
|------|------------|-------------------|-------|-----------------------|
| Pro Monthly | $9.99/mo | ~250,000đ/mo | none | `aura_pro_monthly` |
| Pro Yearly | $71.88/yr ($5.99/mo equivalent — save 40%) | ~1,750,000đ/yr | 7 days | `aura_pro_yearly` |

Both plans deliver the **same `pro` entitlement**. Yearly is the "Best Value" highlight on paywall.

### Consumable IAP

| Product | Price | RevenueCat Product ID |
|---------|-------|-----------------------|
| 1 Custom Topic credit | 3,000đ (~$0.12) | `aura_credit_topic_1` |
| 5 Custom Topic bundle | 12,000đ (saves 20%) | `aura_credit_topic_5` |
| 1 Custom Context credit | 5,000đ (~$0.20) | `aura_credit_context_1` |
| 5 Custom Context bundle | 20,000đ (saves 20%) | `aura_credit_context_5` |

(Avatar credits added later, same pattern.)

Bundle pricing reduces per-call friction without devaluing the subscription.

## 4. Quota Matrix

Full feature × tier × cap table. The `*` markers show what's **changing** vs. current `quota_constants.dart`.

| Feature | Free / day | Free lifetime | Pro / day | Pro lifetime | IAP price | Reset cadence |
|---------|-----------|---------------|-----------|--------------|-----------|--------------|
| Scenario session | 5 | — | 30 | — | n/a | daily |
| Story session | 3 | — | 20 | — | n/a | daily |
| Dictionary lookup (chat double-tap) | 5 | — | 50 | — | n/a | daily |
| TTS playback | 5 | — | 30 | — | n/a | daily |
| Vocab Hub AI call (Analysis + Describe + Compare + Flashcards) * | 3 (after grant) | 20 (one-time grant) | 50 | — | n/a | daily |
| Mind Map (generate root or expand) | **0** (locked) | — | 10 | — | n/a | daily |
| Grammar exercise (translate / fill / transform) | 30 | — | unlimited | — | n/a | daily |
| Custom topic add * | — | 2 | — | 30 / month | 3,000đ / 12,000đ × 5 | lifetime + monthly Pro reset |
| Custom context add * | — | 2 | — | 30 / month | 5,000đ / 20,000đ × 5 | lifetime + monthly Pro reset |
| AI illustration generate | 0 (locked) | — | 5/day | — | n/a | daily |

**Notes:**
- Tone Translator quotas are removed from the matrix — feature is behind `toneTranslatorEnabled = false`.
- "Vocab Hub AI call" is a single bucket shared across Analysis, Describe Word, Compare Words, and Flashcards-generate. Save to Library and viewing existing flashcards do NOT count. The "20 lifetime grant" is intentional onboarding generosity.
- Custom topic/context have BOTH lifetime free cap (2) AND monthly Pro cap (30). Pro user exceeding 30 in a month buys IAP credits. Free user exceeding 2 ever buys IAP credits.

## 5. Architecture

### 5.1 Domain layer

**Extend `UserProfile`** (`lib/domain/entities/user_profile.dart`):

```dart
class UserProfile {
  // ...existing fields...
  final String tier;                // 'free' | 'pro'
  final DateTime? proSince;         // first activation timestamp
  final DateTime? proExpiresAt;     // current period end (null if free)
  final String? proSource;          // 'apple' | 'google' | 'web' | 'admin_grant'
  final bool inFreeTrial;           // true during 7-day yearly trial
  // Lifetime + period counters live in a separate Firestore subcollection.
}
```

**New `UsageCounters` model** (`lib/domain/entities/usage_counters.dart`):

```dart
class UsageCounters {
  final String uid;
  // Daily counters — keyed by yyyymmdd in user-local timezone.
  final Map<String, int> daily;     // {'scenario_20260430': 3, 'vocab_ai_20260430': 1, ...}
  final Map<String, int> lifetime;  // {'vocab_ai_grant_used': 17, 'custom_topics_added': 1, ...}
  final Map<String, int> proPeriod; // {'pro_custom_topics_202604': 5, ...} — resets monthly for Pro
  final Map<String, int> credits;   // {'topic': 0, 'context': 3} — purchased IAP balance
}
```

Stored at `users/{uid}/usage/counters` (single doc, transactional updates).

### 5.2 Quota engine

Replace per-feature scattered guards with a **single `QuotaEngine`** at `lib/features/subscription/services/quota_engine.dart`:

```dart
class QuotaEngine {
  Future<QuotaCheck> check(String feature);          // peek
  Future<QuotaCheck> consume(String feature, {int amount = 1}); // peek + decrement atomically
  Future<void> grantCredits(String creditType, int amount);     // post-IAP receipt
}

class QuotaCheck {
  final bool allowed;
  final int remaining;       // -1 = unlimited
  final QuotaWall wall;      // none | hardCap | needsPro | needsIap
  final String? upgradeCta;  // 'pro' | 'topic_credit' | 'context_credit'
}
```

Backed by a Firestore transaction so concurrent calls (e.g. two devices) can't double-spend. Existing `dictionary_quota_guard.dart` becomes a thin wrapper that delegates to QuotaEngine.

### 5.3 RevenueCat integration

**Package**: `purchases_flutter` (^9.x) — official RevenueCat Flutter SDK.

**Boot flow** (in `main.dart` after Firebase init):
```
await Purchases.configure(PurchasesConfiguration(REVENUECAT_PUBLIC_KEY));
Purchases.logIn(uid);          // call again on auth changes
```

**Entitlement read** (cache):
```dart
final info = await Purchases.getCustomerInfo();
final isPro = info.entitlements.active.containsKey('pro');
```

**Purchase flow**:
```dart
final offerings = await Purchases.getOfferings();
final pkg = offerings.current?.annual; // or .monthly
final result = await Purchases.purchasePackage(pkg);
// result.customerInfo.entitlements.active['pro'] == EntitlementInfo
```

**Restore flow**:
```dart
final restored = await Purchases.restorePurchases();
// app then re-reads tier from Firestore (webhook should have synced by now)
```

### 5.4 Cloud Function webhook

**File**: `functions/src/revenuecat_webhook.ts` (Firebase Functions v2).

```ts
export const revenuecatWebhook = onRequest(
  { secrets: ['REVENUECAT_WEBHOOK_AUTH'] },
  async (req, res) => {
    // 1. Verify Authorization header matches secret
    // 2. Parse RC event payload
    // 3. Switch on event type:
    //    - INITIAL_PURCHASE / RENEWAL / TRIAL_STARTED → tier='pro', proExpiresAt=event.expiration
    //    - CANCELLATION / EXPIRATION → tier='free', proExpiresAt=null
    //    - NON_RENEWING_PURCHASE (consumable) → grant credits to user.usage.credits
    //    - REFUND → tier='free', clawback active credits if any
    // 4. Update users/{uid} + users/{uid}/usage/counters in a single batch
    // 5. Return 200 fast — RC retries on non-2xx
  }
);
```

The user's `appUserID` in RevenueCat = Firebase `uid`. Function looks up the user doc, applies the change, returns 200.

### 5.5 Paywall + Profile UI

**Paywall screen** (`lib/features/subscription/screens/paywall_screen.dart`) — replaces existing stub:
- Hero with mode-adjacent value prop (cycling animation through modes)
- Benefits grid: 4 tiles
- Plan picker: Monthly / Yearly (Yearly default selected, "Best Value" badge, "7-day free trial" badge)
- Bottom CTA: `Start free trial` (yearly default) or `Subscribe` (monthly)
- Footer: Restore Purchases, Terms, Privacy
- Loading state during purchase, error state with retry, success → close + tier badge animation

**Quota wall dialog** (`lib/features/subscription/widgets/quota_wall_dialog.dart`):
- Header: "You've reached your daily limit"
- Body: which feature + count + reset time
- Two CTAs: "Upgrade to Pro" (gold) or "Wait until tomorrow" (text button)
- For custom-topic/context overrun: show IAP option directly ("Add 1 topic — 3,000đ" alongside Pro upgrade)

**Pro lock card** (`lib/features/subscription/widgets/pro_lock_card.dart`):
- Inline replacement when free user opens MindMap / Insights deep-dive
- Compact gold border, "Unlock with Pro" CTA
- Already partially exists for MindMap (`vocab_feature_card.dart` `isLocked` prop)

**Profile row** (already exists in stub) — replace placeholder with live tier:
- Free: "Aura Free · Upgrade to Pro" → tap opens Paywall
- Pro: "Aura Pro · Active until {date}" → tap opens Manage Sub (deep-link)

**Manage sub deep-link** (`lib/features/subscription/services/manage_subscription.dart`):
- iOS: `https://apps.apple.com/account/subscriptions`
- Android: `https://play.google.com/store/account/subscriptions?package={pkg}&sku={sku}`

### 5.6 Firestore Schema Additions

```
users/{uid}                       # extended with proSince, proExpiresAt, proSource, inFreeTrial
users/{uid}/usage/counters        # NEW — daily / lifetime / proPeriod / credits
users/{uid}/billingEvents/{evt}   # NEW — append-only audit log of webhook events
```

**Firestore rules**:
```
match /users/{uid}/usage/counters {
  allow read: if request.auth.uid == uid;
  allow write: if false;        // server-only writes via Cloud Function
}
match /users/{uid}/billingEvents/{event} {
  allow read: if request.auth.uid == uid;
  allow write: if false;        // server-only
}
```

### 5.7 Feature flags

Extend `lib/core/constants/feature_flags.dart`:
```dart
abstract final class FeatureFlags {
  // ...existing...
  static const bool subscriptionEnabled = true;        // master switch
  static const bool consumableIapEnabled = true;       // custom-topic/context credits
  static const bool subscriptionDevMode = false;       // bypass paywall in dev
}
```

`subscriptionDevMode = true` lets developers test Pro features locally without a real RevenueCat purchase.

## 6. Paywall Entry Points (UX flow)

| Trigger | Surface | When |
|---------|---------|------|
| Profile → Subscription row | Always visible | Persistent |
| Quota wall dialog | Modal | Free user hits any daily cap (incl. Vocab Hub 3/day) |
| Vocab Hub initial-grant exhausted | Modal first time, then per-call dialog | After 20 lifetime grant used |
| Mind Map tab open while free | Inline `_ProUpgradeCard` | Tab tap |
| Insights deep-dive (Pro section) tap | Inline lock card | Section tap |
| AI illustration tap | Modal | Per-illustration request |
| Custom topic/context add when out | Modal with IAP + Pro options | Add tap |

## 7. Phasing

| Phase | Scope | Est | Blocking? |
|-------|-------|-----|-----------|
| **A** | Domain extensions: `UserProfile` fields, `UsageCounters` model, `QuotaEngine` skeleton + tests | 1d | No |
| **B** | Migrate existing guards → QuotaEngine. Daily reset logic. Lifetime grant logic for Vocab Hub | 1d | A |
| **C** | RevenueCat SDK integration: configure, login on auth change, read entitlement, expose in Provider | 0.5d | A |
| **D** | Paywall screen UI (full rebuild of stub) + Plan picker + Restore | 1d | C |
| **E** | Quota wall dialog + Pro lock card + Vocab Hub initial-grant modal | 0.5d | B + D |
| **F** | Cloud Function webhook + Firestore rules + billing audit log | 1d | none (parallel-able) |
| **G** | Consumable IAP flow: credit balance read, purchase Topic/Context credit, server-side credit grant | 0.5d | C + F |
| **H** | Manage subscription deep-link + Profile tier row update + tier badge | 0.25d | D |
| **I** | i18n: paywall + quota wall + lock cards (en + vi) | 0.5d | D + E |
| **J** | Edge cases: refund clawback, family sharing, downgrade, network-offline cache, expired-but-no-webhook fallback | 1d | F |
| **K** | Verification: flutter analyze + smoke (free → wall → upgrade → pro → IAP → restore → cancel) | 0.5d | All |

**Total**: ~8 dev-days. App Store / Play Console product config + RevenueCat dashboard setup happens in parallel (Luu).

## 8. Edge Cases

1. **Offline at purchase time** — RevenueCat SDK queues, retry on reconnect. Show "syncing" state.
2. **Webhook delayed** — client reads RevenueCat customerInfo as fast cache; Firestore tier is canonical. UI accepts EITHER source returning Pro.
3. **Refund** — webhook fires REFUND event → tier='free', clawback credits if user purchased and refunded. Audit logged.
4. **Family sharing (iOS)** — entitlement transfers. RC handles, just consume customerInfo.
5. **Downgrade Pro → Free at period end** — webhook fires EXPIRATION → tier flip. Lifetime caps stay enforced (don't reset). Pro-period custom-topic counter resets.
6. **Trial abuse** (subscribe → cancel → resub) — App Store deduplicates trial eligibility per Apple ID. RC enforces. No app code needed.
7. **Server-side validation failure** — webhook retries 3x then alerts. Client still sees Pro from RC cache, but Firestore stays free → quota engine fails closed (treats as free). Acceptable: user can restore purchase to retrigger.
8. **Clock skew on daily reset** — use server timestamp, not device time, for daily key generation. Function does `getDailyKey(serverNow, userTimezone)`.
9. **Concurrent device usage** — Firestore transaction on counter write. Both clients converge.
10. **VN payment friction** — App Store / Play Store accept VN credit cards + carrier billing (Viettel, MobiFone). RevenueCat handles. No special path.

## 9. Out of Scope (this plan)

- Discount codes / promo codes — defer to growth phase
- Family / Student plans — defer
- Lifetime purchase tier — defer (user picked 2-tier without lifetime)
- Web Stripe checkout — only mobile for now
- Avatar generation IAP — schema-ready but feature itself ships later
- A/B pricing experiments — RevenueCat supports, not configuring v1

## 10. Success Criteria

- Free user can hit every quota wall and clearly see Pro upgrade path
- 1-tap upgrade flow from any wall: ≤ 3 screens to complete purchase
- Pro entitlement reflects in Firestore within 60s of purchase (webhook-driven)
- Restore Purchases works on fresh device install
- Custom topic/context IAP usable for both Free and Pro users
- All paywall copy localized en + vi
- Zero "tier=pro but features locked" inconsistencies via single QuotaEngine source of truth
