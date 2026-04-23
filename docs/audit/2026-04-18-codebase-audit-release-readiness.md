# Aura Coach AI — Codebase Audit (Release Readiness)

**Date:** 2026-04-18
**Last updated:** 2026-04-18 (Phase E complete — 16 of 16 categories, **final**)
**Audit type:** Flat 16-category deep-dive, report-only
**Audit driver:** Pre-release readiness
**Auditor:** Luu (via Claude, brainstorming + direct execution)
**Spec:** `docs/superpowers/specs/2026-04-18-codebase-audit-release-readiness-design.md`

## Baseline

- **Commit SHA audited:** `88cefdc554d00c118fcdbd319adee23d7ad53262` (HEAD of `master`)
- **Baseline mode:** **Option (b)** — audited `HEAD` **plus uncommitted working-tree changes** (user chose "start immediately", not clean-commit-first). Line numbers reflect working-tree state. ~40 tracked files modified, several new untracked files including new `lib/core/services/`, `lib/core/utils/`, `lib/domain/`, profile feature, my_library feature, shared painters/widgets, localization files, and this audit's sibling spec.
- **Tool environment:** `flutter` and `dart` CLI **not available** in audit sandbox. All "automated scan" steps in methodology performed via `grep`/`find` heuristics. User must re-run `flutter analyze`, `dart pub outdated`, and `flutter test --coverage` locally before shipping — see **FINDING-08** (Phase B dependency audit), **FINDING-27** (Phase D testing coverage), **FINDING-28** (Phase D CI/CD pipeline).

## Status

**Progress:** 16 of 16 categories complete (Phase A Foundation + Phase B Correctness + Phase C Runtime + Phase D Safety Net + Phase E UI/UX & Platform Integration). **Audit complete.**
- ✅ Category 1 — Architecture & Design
- ✅ Category 2 — Code Quality
- ✅ Category 3 — Performance
- ✅ Category 4 — Lifecycle & Resource
- ✅ Category 5 — Network & API
- 🔴 Category 6 — Security (**1 CRITICAL release blocker — FINDING-24**)
- ✅ Category 7 — Testing
- ✅ Category 8 — Dependency Management
- ✅ Category 9 — CI/CD
- ✅ Category 10 — UI/UX
- 🔴 Category 11 — Logging & Monitoring (**1 CRITICAL release blocker — FINDING-29**)
- ✅ Category 12 — State & Data Flow
- ✅ Category 13 — Business Logic
- ✅ Category 14 — Offline Capability
- 🔴 Category 15 — Platform Integration (**1 CRITICAL release blocker — FINDING-35**)
- ✅ Category 16 — Maintainability

**Final verdict:** 🔴 `BLOCKING_RELEASE` — **3 CRITICAL + 7 HIGH** findings. Three CRITICAL blockers must be resolved before shipping: (1) client-side Gemini API key bundled in APK/IPA (FINDING-24), (2) zero production observability (FINDING-29), (3) release APK signed with debug keystore (FINDING-35). See **Section 9: Checkpoint 3** for the full remediation roadmap and Go/No-Go checklist.

---

## 1. Executive Summary

**Final verdict:** 🔴 `BLOCKING_RELEASE` — **3 CRITICAL + 7 HIGH** findings across 16 categories. Shipping this build as-is would mean (a) publishing the Gemini API key, (b) operating blind post-release with no crash reporting, and (c) attempting to upload a debug-signed APK that Google Play will reject outright. Product-level code (architecture intent, Clay design system, scenario offline fallback, Firestore security rules, modern native toolchain) is in good shape — the failure is concentrated in **release plumbing**: signing, secrets pipeline, telemetry, CI, branding, tests. See **Section 9: Checkpoint 3** for full verdict, tiered remediation roadmap, and Go/No-Go checklist.

**Phase E headlines (UI/UX + Platform Integration):**
- **FINDING-35 (CRITICAL, Platform Integration):** `android/app/build.gradle.kts:36-42` still ships the stock Flutter comment `// Signing with the debug keys for now` — release builds are signed with the debug keystore. Google Play will reject the upload. Must generate an upload keystore, wire `keystore.properties` into the `release` signing config, and enroll Play App Signing.
- **FINDING-36 (HIGH, Platform Integration):** Android displays `aura_coach_ai` (snake_case developer slug) as launcher label; iOS `CFBundleDisplayName` is `Aura Coach Ai` (wrong capitalization of "AI"). Both visible to every user on install. Set Android label to `Aura Coach AI` and fix iOS casing.
- **FINDING-37 (HIGH, Platform Integration):** Default Flutter launch screens on both platforms — Android `launch_background.xml` has the default white-background stub with the bitmap commented out; iOS `LaunchImage.imageset/` still ships the template `README.md` and default `LaunchImage.png`. First-install impression is "this is a demo app".
- **FINDING-30 (MEDIUM, UI/UX):** Localization infrastructure is fully wired in `pubspec.yaml`/`l10n.yaml`/`.arb` files and code-gen runs, but `MaterialApp.router` has no `localizationsDelegates` or `supportedLocales`, and only 1 screen calls `AppLocalizations.of(context)` — the other ~24 `Text(...)` calls are hardcoded English. Vietnamese users see English.
- **FINDING-31 (MEDIUM, UI/UX):** Only `AppTheme.light` exists; no dark theme. `systemOverlayStyle: SystemUiOverlayStyle.dark` is hardcoded in the AppBar, baking in the light-bg assumption.
- **Positive:** iOS `Info.plist` is minimal and correct (no over-requested permissions); Firebase config is properly generated and wired; Google Sign-In URL scheme is declared correctly; MainActivity and AppDelegate are clean default subclasses; `google-services.json` matches `applicationId` on both Android and Firebase project `aura-coach-ai`. Clay design system + typography + component tokens are internally consistent.

**Phase D headlines (carried forward):**
- **FINDING-24 (CRITICAL, Security):** `.env` declared as a Flutter asset in `pubspec.yaml:41` → `GEMINI_API_KEY` bundled into the APK/IPA and extractable from the release binary within minutes. Must move Gemini calls behind a backend proxy (Cloud Function) before release and rotate the key.
- **FINDING-29 (CRITICAL, Logging & Monitoring):** Zero production observability — no Crashlytics, no Sentry, no Analytics, no `FlutterError.onError`, no `runZonedGuarded`, no `ErrorWidget.builder`. Combined with FINDING-12 (silent empty catches), the team is blind both in code and in the cloud.
- **FINDING-27 (HIGH, Testing):** Near-zero automated coverage — one test file with 2 trivial enum assertions. No widget tests, no integration tests, no mocking library in `dev_dependencies`.
- **FINDING-28 (HIGH, CI/CD):** No CI pipeline of any kind. No enforcement point for lints (FINDING-13), tests (FINDING-27), or Crashlytics symbol uploads (FINDING-29). Every release is a developer-laptop build.

**Prior-phase headlines (carried forward):**
- **Architecture:** 3 HIGH findings from Phase A/B (repository gap, provider-to-datasource coupling, silent error swallowing) — inputs to the Phase D safety-net story: testing (FINDING-27) is blocked on FINDING-02 provider-coupling; crash reporting (FINDING-29) has to retrofit the 10 empty-catch sites from FINDING-12.
- **Performance + Network + Offline** are in better shape than the safety-net and release-plumbing categories — see Phase C summary for detail.

**Final totals (16/16 categories):**
| Severity | Count | Δ Phase E | % |
|---|---|---|---|
| CRITICAL | 3 | +1 🔴 | 7% |
| HIGH | 7 | +2 | 17% |
| MEDIUM | 19 | +6 | 46% |
| LOW | 12 | +3 | 29% |
| **Total** | **41** | **+12** | 100% |

**Top items across all phases (ordered by severity then finding ID):**
1. 🔴 **FINDING-24 (CRITICAL)** — GEMINI_API_KEY bundled into release APK/IPA; extractable. Must move server-side + rotate. **Release blocker.**
2. 🔴 **FINDING-29 (CRITICAL)** — Zero production observability; no crash reporting, no global error handler, no analytics. **Release blocker.**
3. 🔴 **FINDING-35 (CRITICAL)** — Android release build signed with debug keystore; Play Store will reject. **Release blocker.**
4. FINDING-01 (HIGH) — Domain layer vestigial; repositories folder empty despite being declared.
5. FINDING-02 (HIGH) — Providers import data layer directly, bypassing domain/repo abstraction. *Blocks testability for FINDING-27.*
6. FINDING-12 (HIGH) — Silent empty catches in 10 files suppress all errors including Firestore/Gemini failures. *Pairs with FINDING-29 remediation.*
7. FINDING-27 (HIGH) — Near-zero test coverage; no mocking infrastructure.
8. FINDING-28 (HIGH) — No CI/CD pipeline anywhere in the repo.
9. FINDING-36 (HIGH) — Wrong Android label + wrong iOS display-name casing; visible on every install.
10. FINDING-37 (HIGH) — Default Flutter launch screens on both platforms; off-brand first-impression.
11. FINDING-03, 05, 06, 07, 09, 14, 15, 16, 19, 21, 22, 25, 26, 30, 31, 32, 38, 39, 40 (MEDIUM × 19) — DI inconsistency, file size, unused dep, no CI-driven dep audit, default README, onboarding triple-state, offline re-onboarding, lifecycle, fire-and-forget writes, connectivity detection, write-replay queue, missing `.env.example`, release-manifest permissions, l10n not wired, no dark mode, accessibility minimal, default Android icons, no flavors, bundle-ID casing mismatch.
12. FINDING-04, 08, 10, 11, 13, 17, 18, 20, 23, 33, 34, 41 (LOW × 12) — app.dart SRP drift, deferred pub outdated, missing ARCHITECTURE/CONTRIBUTING docs, tracked `.DS_Store`, minimal lints, rebuild granularity, Lottie dead code, retry tuning, offline-cache scope, no tablet/responsive layout, inconsistent error/empty/loading UX, no R8/ProGuard shrinking.

---

## 2. Coverage Dashboard

| # | Category | Findings | CRIT | HIGH | MED | LOW | Release Risk | Status |
|---|----------|---------:|-----:|-----:|----:|----:|--------------|--------|
| 1 | Architecture & Design | 5 | 0 | 2 | 2 | 1 | MEDIUM | ⚠️ NEEDS_WORK |
| 2 | Code Quality | 2 | 0 | 1 | 0 | 1 | MEDIUM | ⚠️ NEEDS_WORK |
| 3 | Performance | 2 | 0 | 0 | 0 | 2 | LOW | ✅ OK |
| 4 | Lifecycle & Resource | 1 | 0 | 0 | 1 | 0 | LOW | ⚠️ NEEDS_WORK |
| 5 | Network & API | 2 | 0 | 0 | 1 | 1 | LOW | ⚠️ NEEDS_WORK |
| 6 | Security | 3 | 1 | 0 | 2 | 0 | **HIGH** | 🔴 BLOCKING_RELEASE |
| 7 | Testing | 1 | 0 | 1 | 0 | 0 | MEDIUM | ⚠️ NEEDS_WORK |
| 8 | Dependency Management | 3 | 0 | 0 | 2 | 1 | LOW | ⚠️ NEEDS_WORK |
| 9 | CI/CD | 1 | 0 | 1 | 0 | 0 | MEDIUM | ⚠️ NEEDS_WORK |
| 10 | UI/UX | 5 | 0 | 0 | 3 | 2 | MEDIUM | ⚠️ NEEDS_WORK |
| 11 | Logging & Monitoring | 1 | 1 | 0 | 0 | 0 | **HIGH** | 🔴 BLOCKING_RELEASE |
| 12 | State & Data Flow | 1 | 0 | 0 | 1 | 0 | LOW | ⚠️ NEEDS_WORK |
| 13 | Business Logic | 1 | 0 | 0 | 1 | 0 | LOW | ⚠️ NEEDS_WORK |
| 14 | Offline Capability | 3 | 0 | 0 | 2 | 1 | LOW | ⚠️ NEEDS_WORK |
| 15 | Platform Integration | 7 | 1 | 2 | 3 | 1 | **HIGH** | 🔴 BLOCKING_RELEASE |
| 16 | Maintainability | 3 | 0 | 0 | 1 | 2 | LOW | ⚠️ NEEDS_WORK |
| **Σ** | **Total** | **41** | **3** | **7** | **19** | **12** | **HIGH** | 🔴 **BLOCKING_RELEASE** |

**Legend — Release Risk:** `HIGH` = ≥1 CRITICAL; `MEDIUM` = 0 CRITICAL + ≥1 HIGH; `LOW` = 0 CRITICAL + 0 HIGH.
**Legend — Status:** `✅ OK` = no findings or only LOW · `⚠️ NEEDS_WORK` = ≥1 MEDIUM or HIGH, 0 CRITICAL · `🔴 BLOCKING_RELEASE` = ≥1 CRITICAL · `➖ N/A` = doesn't apply.

---

## 3. Release Blockers

**Three (3) CRITICAL findings block release. Do not ship until all three are resolved.**

| # | Finding | Category | Summary | Minimum fix | Effort |
|---|---------|----------|---------|-------------|--------|
| 1 | **FINDING-24** | 6 Security | `GEMINI_API_KEY` is bundled into the release APK/IPA as a Flutter asset (`pubspec.yaml:41`) and extractable from any signed build within minutes. | Move Gemini calls behind a Firebase Cloud Function proxy. Remove `.env` from `pubspec.yaml` assets. Rotate the key. | M |
| 2 | **FINDING-29** | 11 Logging | Zero production observability — no crash reporting, no global error handler, no analytics. Crashes and regressions are invisible post-release. Compounds FINDING-12 silent catches. | Add `firebase_crashlytics` + `firebase_analytics`, wire `runZonedGuarded` + `FlutterError.onError` in `lib/main.dart`, retrofit FINDING-12 empty catches to report errors. | M |
| 3 | **FINDING-35** | 15 Platform | Android release build is signed with the debug keystore (`android/app/build.gradle.kts:36-42` still ships the stock Flutter `// Signing with the debug keys for now` comment). Google Play will reject the upload. | Generate an upload keystore, wire `keystore.properties` into the `release` signing config, enroll Play App Signing. | S |

**Coupling note:** all three blockers are mostly independent and can be parallelized. Suggested order when a single contributor works them serially:
1. **FINDING-29 first** — stand up Crashlytics + global error handler. Gives visibility to detect whether FINDING-24 is being exploited during rollout and whether FINDING-35-related signing changes cause unexpected install failures.
2. **FINDING-24 second** — Cloud Function proxy + key rotation. Non-reversible security fix; every day delayed is another day the key could leak.
3. **FINDING-35 third** — keystore wiring. S-effort and can be batched with the Tier-1 platform-polish fixes (FINDING-36, FINDING-37) in the same PR.

**Non-blocking but ship-adjacent:** FINDING-27 (tests), FINDING-28 (CI/CD), FINDING-36 (app label/display name), FINDING-37 (launch screens) — the two platform HIGHs should be fixed in the same PR as FINDING-35 to avoid a second release-branding pass. See the full tiered plan in **Section 9.4 Prioritized remediation roadmap**.

---

## 4. Category Deep-Dives

### Category 1 — Architecture & Design — ⚠️ NEEDS_WORK

**Scope:** High-level structural decisions: layer separation, dependency flow, state management, feature modularity. Evaluates `lib/` overall shape, not individual file quality.

**Inputs audited:**
- Files: `lib/main.dart`, `lib/app.dart`, `lib/core/**`, `lib/data/**`, `lib/domain/**`, `lib/shared/**`, all 5 `lib/features/*/providers/*.dart`, representative screens from each feature.
- Tools run: `find`/`wc -l` for file sizes, `grep -rn "extends ChangeNotifier"`, `grep -rn "import.*data/"` for cross-layer import checks, `grep -n "ChangeNotifierProvider\|MultiProvider"` in app.dart.
- Docs cross-referenced: `docs/superpowers/specs/2026-04-08-aura-coach-comprehensive-design.md`, `docs/business-flow/aura-coach-mobile-business-flows-v2.md`.

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| Layer separation | core / data / domain / features / shared, each with clear role | Partial — `domain/` vestigial (1 entity only); `data/repositories/` folder empty despite layer being declared | `IMPLEMENTED_NOT_USED` | HIGH |
| Dependency flow | Downward only; features → domain → data (via repo/interface) | Direction correct ✅; but features **skip** domain+repo and import data/datasources directly | `ANTI_PATTERN` | HIGH |
| State management consistency | Single pattern for all providers | All 5 use `ChangeNotifier` ✅; wiring inconsistent (4 app-level via `.value`, 1 screen-local via `.create`) | `INCONSISTENT` | MEDIUM |
| Modularity / feature structure | Self-contained, uniform structure per feature | Feature-first layout correct ✅; some features (`profile`) lack provider; several files >700 LOC indicate breakdown needed | Partial OK (file size concern) | MEDIUM |

**Findings:**

#### FINDING-01: Domain layer is vestigial — repository interfaces missing
- **Category:** 1
- **Severity:** HIGH
- **Gap type:** IMPLEMENTED_NOT_USED
- **Location:**
  - `lib/domain/entities/user_profile.dart` (only file in `lib/domain/`)
  - `lib/data/repositories/` (empty directory)
- **Evidence:**
  ```
  $ find lib/domain -name "*.dart" -exec wc -l {} \;
  60 lib/domain/entities/user_profile.dart

  $ ls lib/data/repositories/
  (empty)
  ```
- **Impact:** Declared clean-architecture layering is only partially implemented. Without repository interfaces, providers are tightly coupled to concrete `FirebaseDatasource`/`GeminiService` implementations → difficult to unit-test provider logic, difficult to swap Firestore for another backend, difficult to mock AI calls deterministically in tests.
- **Remediation:** Define repository interfaces in `lib/domain/repositories/` (e.g. `AuthRepository`, `ScenarioRepository`, `LibraryRepository`). Move Firebase/Gemini concrete implementations to `lib/data/repositories/` implementing those interfaces. Providers consume interfaces via DI.
- **Effort:** L
- **Status:** OPEN

#### FINDING-02: Providers import data layer directly, bypassing repo/domain
- **Category:** 1
- **Severity:** HIGH
- **Gap type:** ANTI_PATTERN
- **Location:**
  - `lib/features/auth/providers/auth_provider.dart:5-6`
  - `lib/features/home/providers/home_provider.dart:2`
  - `lib/features/my_library/providers/library_provider.dart:2-3`
  - `lib/features/scenario/providers/scenario_provider.dart:7-11`
- **Evidence:**
  ```dart
  // scenario_provider.dart
  import '../../../data/cache/scenario_cache.dart';
  import '../../../data/datasources/firebase_datasource.dart';
  import '../../../data/datasources/local_datasource.dart';
  import '../../../data/gemini/config.dart';
  import '../../../data/gemini/gemini_service.dart';
  ```
- **Impact:** Providers can never be unit-tested without real Firestore/Gemini SDKs or heavy mocks. Swapping or refactoring any data-layer file forces touching every consuming provider. Violates dependency inversion principle.
- **Remediation:** Dependent on FINDING-01 — once repository interfaces exist, change every provider constructor to take the interface, not the concrete datasource. Register interface → implementation mapping in app-level DI.
- **Effort:** L (coupled with FINDING-01)
- **Status:** OPEN

#### FINDING-03: Inconsistent provider DI — OnboardingProvider wired locally vs. others globally
- **Category:** 1
- **Severity:** MEDIUM
- **Gap type:** INCONSISTENT
- **Location:**
  - `lib/app.dart:171-179` (4 providers wired at app level via `.value`)
  - `lib/features/onboarding/screens/onboarding_screen.dart:50-57` (OnboardingProvider created via `ChangeNotifierProvider(create: ...)`)
- **Evidence:**
  ```dart
  // app.dart:171-179
  MultiProvider(providers: [
    Provider<FirebaseDatasource>.value(...),
    Provider<LocalDatasource>.value(...),
    ChangeNotifierProvider<app.AuthProvider>.value(value: _authProvider),
    ChangeNotifierProvider<HomeProvider>.value(value: _homeProvider),
    ChangeNotifierProvider<LibraryProvider>.value(value: _libraryProvider),
    ChangeNotifierProvider<ScenarioProvider>.value(value: _scenarioProvider),
  ])

  // onboarding_screen.dart:50
  ChangeNotifierProvider(create: (_) => OnboardingProvider(...), child: ...)
  ```
- **Impact:** Two coexisting DI patterns confuse contributors. New features may pick either. OnboardingProvider cannot be accessed from outside the onboarding screen tree. Tests require different setup per provider. Lifecycle of OnboardingProvider is coupled to screen lifetime which may or may not be intentional.
- **Remediation:** Decide: (a) global — move OnboardingProvider into `app.dart` (persists if user backgrounds onboarding); or (b) screen-local — move AuthProvider/HomeProvider/Library/Scenario to `.create` at their first-use boundary. Document choice in `ARCHITECTURE.md` (see FINDING-10).
- **Effort:** S
- **Status:** OPEN

#### FINDING-04: Router, DI, and MaterialApp all coexist in `lib/app.dart` (191 LOC) — SRP drift
- **Category:** 1
- **Severity:** LOW
- **Gap type:** INCONSISTENT
- **Location:** `lib/app.dart:1-191`
- **Evidence:**
  - Lines 39-77: datasource + provider instantiation (DI concern)
  - Lines 79-156: `GoRouter` config with `redirect` logic and 8 routes (routing concern)
  - Lines 170-189: `MultiProvider` + `MaterialApp.router` wrap (app shell concern)
- **Impact:** `app.dart` grows with every new feature. Minor today; becomes god-file after 2–3 more features. Hard to review diffs in PRs when routing, DI, and shell changes mix.
- **Remediation:** Extract router to `lib/core/router/app_router.dart` (pure routing, takes `AuthProvider` as param for redirect). Extract DI to `lib/core/di/app_providers.dart`. `app.dart` becomes a ~40-line shell.
- **Effort:** S
- **Status:** OPEN

#### FINDING-05: Multiple files >700 LOC — SRP drift in scenario/my_library features
- **Category:** 1 (also cross-cuts Code Quality #2 and Performance #3)
- **Severity:** MEDIUM
- **Gap type:** ANTI_PATTERN
- **Location:**
  - `lib/features/scenario/screens/conversation_history_screen.dart` — 745 LOC
  - `lib/features/scenario/widgets/assessment_card.dart` — 736 LOC
  - `lib/features/my_library/screens/my_library_screen.dart` — 717 LOC
  - `lib/features/scenario/providers/scenario_provider.dart` — 423 LOC
  - `lib/shared/painters/topic_painters.dart` — 723 LOC (painter grouping, more acceptable)
  - `lib/shared/painters/feature_painters.dart` — 668 LOC (same)
- **Evidence:**
  ```
  $ find lib -name "*.dart" | xargs wc -l | sort -rn | head
    745 lib/features/scenario/screens/conversation_history_screen.dart
    736 lib/features/scenario/widgets/assessment_card.dart
    723 lib/shared/painters/topic_painters.dart
    717 lib/features/my_library/screens/my_library_screen.dart
    668 lib/shared/painters/feature_painters.dart
    469 lib/shared/painters/action_painters.dart
    463 lib/data/gemini/types.dart
    423 lib/features/scenario/providers/scenario_provider.dart
    409 lib/features/scenario/screens/scenario_chat_screen.dart
  ```
- **Impact:** Large widget files slow hot-reload builds, increase merge conflict rates, make diff review harder, and typically harbor duplicated UI logic. Providers >400 LOC often mix orchestration with helper logic that belongs elsewhere.
- **Remediation:** For each offender:
  - Extract sub-widget blocks as private `StatelessWidget`/`StatefulWidget` in sibling files (e.g. `assessment_card_header.dart`, `assessment_card_body.dart`).
  - `scenario_provider.dart` → split computation helpers (prompt building, scoring math) into `lib/features/scenario/services/` or similar.
  - Shared painters (topic/feature) are acceptable at size because they group many icon definitions; consider splitting by category if they grow further.
- **Effort:** M
- **Status:** OPEN

**Category summary:** `⚠️ NEEDS_WORK`. No release blockers *in this category*, but architectural debt is significant: domain/repository layer is a skeleton, and every feature provider tightly couples to concrete data implementations. Testability is the primary casualty — addressing FINDING-01 + FINDING-02 is a prerequisite for achieving any meaningful unit-test coverage (now confirmed in **FINDING-27**, Category 7).

---

### Category 2 — Code Quality — ⚠️ NEEDS_WORK

**Scope:** In-the-small code hygiene: error handling correctness, naming consistency, SOLID/DRY adherence at function/class level, dead code, comment discipline, lint strictness. Large-scale SRP drift is tracked in Category 1 (FINDING-05).

**Inputs audited:**
- Files: all `lib/**/*.dart` (113 files, ~18k LOC), `analysis_options.yaml`.
- Tools run: `grep -rn "TODO\|FIXME\|HACK\|XXX"`, `grep -rn "^\s*print("`, `grep -rn "catch (_)"`, `grep -rn "catchError((_)"`, `grep -rn "debugPrint"`, `grep -rn "extends\|with" lib/features/*/providers` for naming consistency, `find lib -name '*.dart' | xargs wc -l`.
- Docs cross-referenced: `CLAUDE.md` clean-code rules (no Vietnamese comments, no redundant comments, consistent naming).

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| Clean code — error handling | Every caught exception is logged or surfaced; no empty catch | 13 `catch (_) {}` + 2 `catchError((_) {})` across 10 files silently swallow everything | `ANTI_PATTERN` | HIGH |
| Clean code — no leftover markers | No TODO/FIXME/HACK/XXX markers | ✅ 0 occurrences in `lib/` | OK | — |
| Clean code — no stray prints | Use `debugPrint` or logger | ✅ 0 `print()` calls; 9 `debugPrint("[Component] ...")` with consistent prefix | OK | — |
| Naming convention | Files `snake_case`, classes `PascalCase`, vars/methods `lowerCamelCase` | ✅ Consistent across `lib/`; provider classes uniformly `*Provider`; screen files `*_screen.dart`; widget files descriptive | OK | — |
| SOLID / DRY | Single responsibility per class; no copy-paste blocks | Mostly OK at class level; file-level SRP drift covered in FINDING-05 (Cat 1) | Partial (see Cat 1) | — |
| Dead code | No unreferenced classes/functions; no unused imports | No dead Dart code found in `lib/` scan; one unused package dep (`sign_in_with_apple`) — see FINDING-06 (Cat 8) | See FINDING-06 | — |
| Comments | Only when clarifying non-obvious intent; no Vietnamese comments | Spot-check passed ✅ — existing comments are intent-clarifying (e.g. `// Firestore unavailable — default to onboarding not complete.`) | OK | — |
| Lint strictness | Project-specific `analyzer.language` rules / `strong-mode`; opinionated custom rules | Minimal — extends `flutter_lints` + 3 rules (`prefer_const_constructors`, `prefer_const_declarations`, `avoid_print`). No `strict-casts`, no `strict-inference`, no custom rules. | `MISSING` | LOW |

**Findings:**

#### FINDING-12: Silent empty catches in 13 locations suppress all errors
- **Category:** 2 (owner) — cross-ref Category 13 (Business Logic), Category 11 (Logging)
- **Severity:** HIGH
- **Gap type:** ANTI_PATTERN
- **Location:**
  - `lib/features/auth/providers/auth_provider.dart:54` (Firestore onboarding check on init)
  - `lib/features/auth/providers/auth_provider.dart:129` (`_checkOnboarding` after sign-in)
  - `lib/features/scenario/providers/scenario_provider.dart:122` (scenario generation)
  - `lib/features/scenario/providers/scenario_provider.dart:220` (`catchError((_) {})` on fire-and-forget save)
  - `lib/features/scenario/providers/scenario_provider.dart:366` (evaluate flow)
  - `lib/features/scenario/providers/scenario_provider.dart:385` (`catchError((_) {})` on end-session save)
  - `lib/features/scenario/screens/conversation_history_screen.dart:61`, `:227`, `:561`
  - `lib/features/my_library/providers/library_provider.dart:152`
  - `lib/features/onboarding/providers/onboarding_provider.dart:136`
  - `lib/features/splash/screens/splash_screen.dart:57`
  - `lib/data/datasources/local_datasource.dart:40`, `:62`
  - `lib/core/services/tts_service.dart:57`
- **Evidence:**
  ```dart
  // scenario_provider.dart:218-221 — save silently drops errors
  unawaited(
    _firebase.saveConversation(uid: uid, session: session)
        .catchError((_) {}));

  // auth_provider.dart:120-131 — onboarding check eats Firestore errors
  Future<void> _checkOnboarding() async {
    if (currentUser == null) return;
    try {
      _hasCompletedOnboarding =
          await _firebaseDatasource.hasCompletedOnboarding(currentUser!.uid);
      if (_hasCompletedOnboarding) {
        await _localDatasource.setOnboardingComplete(true);
        await _localDatasource.setCachedUid(currentUser!.uid);
      }
    } catch (_) {
      // Firestore unavailable — default to onboarding not complete.
    }
  }
  ```
- **Impact:**
  - **Users see no error** when scenario save, TTS playback, or history refresh silently fail. A scenario session completed but not saved looks identical to a successful save.
  - **No telemetry trail.** Category 11 (**FINDING-29**, CRITICAL) confirms there is no crash reporting in place at all — these suppressed exceptions are permanently lost at the `catch` site. Even once Crashlytics is wired, every one of these 10 sites must be retrofitted to report + rethrow/fallback or the observability hole remains.
  - **Debugging is blind.** A contributor reproducing a bug has no `debugPrint` or stack trace from the failure point. Intermittent Firestore/Gemini failures appear as "nothing happened" in the UI.
  - **Business-logic impact** (see Category 13): the onboarding catch in `auth_provider.dart:54` is the mechanism behind FINDING-15 — returning users on fresh devices with offline Firestore are re-onboarded silently.
- **Remediation:**
  1. Replace every `catch (_) {}` with `catch (e, st) { debugPrint('[<Component>] <operation> failed: $e'); <optional user-facing fallback>; }` at minimum.
  2. For fire-and-forget saves (`unawaited(...).catchError((_) {})`), replace with a named helper like `_logAndSwallow` that funnels to a central error-reporting hook (hookable to Crashlytics/Sentry once Category 11 is addressed).
  3. Where operation is user-initiated, surface a user-visible error via existing error state on the provider (e.g. `_errorMessage` field like `AuthProvider._errorMessage`).
  4. Add an analyzer rule to fail future empty catches (`empty_catches: error` in `analysis_options.yaml`).
- **Effort:** M (20+ call sites, each needs per-site judgment on swallow vs surface vs retry)
- **Status:** OPEN

#### FINDING-13: `analysis_options.yaml` is minimal — no strict-casts/inference, no custom rules
- **Category:** 2
- **Severity:** LOW
- **Gap type:** MISSING
- **Location:** `analysis_options.yaml:1-8`
- **Evidence:**
  ```yaml
  include: package:flutter_lints/flutter.yaml

  linter:
    rules:
      prefer_const_constructors: true
      prefer_const_declarations: true
      avoid_print: true
  ```
- **Impact:** Contributors can introduce implicit `dynamic` casts, loose type inference, empty catches, and other footguns without warning. `flutter_lints` is a good baseline but does not enforce the project's clean-code principles (esp. empty catches — see FINDING-12).
- **Remediation:** Adopt a stricter baseline:
  ```yaml
  analyzer:
    language:
      strict-casts: true
      strict-inference: true
      strict-raw-types: true
  linter:
    rules:
      empty_catches: true
      require_trailing_commas: true
      prefer_final_locals: true
      unawaited_futures: true
      use_build_context_synchronously: true
      avoid_dynamic_calls: true
  ```
  Run `flutter analyze` once to surface backlog, triage into follow-up tasks.
- **Effort:** S (add rules) + variable (fix surfaced warnings)
- **Status:** OPEN

**Positive findings (no action needed):**
- Zero `TODO`/`FIXME`/`HACK`/`XXX` markers in `lib/` — discipline around leftover placeholders is strong.
- Zero `print()` calls (enforced by `avoid_print` lint). All debug output goes through `debugPrint`.
- `debugPrint` statements follow a consistent `[Component]` prefix style (e.g. `debugPrint('[Gemini] ...')`), aiding log filtering.
- Naming conventions are uniform across 113 Dart files: snake_case files, PascalCase classes, lowerCamelCase members, `*Provider`/`*Screen`/`*Service` suffixes applied consistently.
- No Vietnamese comments (`grep` scan passed).

**Category summary:** `⚠️ NEEDS_WORK`. One HIGH — silent error handling — cross-cuts business logic and logging and must be fixed before release. Otherwise, code hygiene is above average: no stray prints, no leftover markers, consistent naming, disciplined comments. The lint ruleset gap (FINDING-13) is a process improvement, not a release blocker.

---

### Category 3 — Performance — ✅ OK

**Scope:** Widget rebuild granularity, list rendering strategy, image loading efficiency, animation cost, build-time `const` discipline. Bundle-size concerns for media-heavy libraries. No profiler runs in this audit — static heuristics only.

**Inputs audited:**
- Files: all feature screens, all `lib/shared/widgets/*`, all `lib/features/*/widgets/*`; `lib/features/scenario/screens/conversation_history_screen.dart`, `scenario_chat_screen.dart`, `my_library_screen.dart` for list rendering; `lib/shared/widgets/cloud_image.dart`, `lottie_asset.dart` for media.
- Tools run: `grep -rn "ListView"` (8 usages, 4 are `.builder`), `grep -rn "Consumer<\|Selector<\|context\.watch\|context\.read\|context\.select"` (5 / 0 / 7 / 18 / 0), `grep -rn "CachedNetworkImage"`, `grep -rn "LottieAsset"`, inspection of `scenario_chat_screen.dart` rebuild scopes.
- Docs cross-referenced: N/A (no perf benchmarks in repo).

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| Rebuild granularity | Prefer `Selector`/`context.select` for fields; only whole-provider `Consumer`/`watch` when truly needed | 5 `Consumer<T>`, 7 `context.watch`, **0** `Selector`/`context.select`. Every provider observation rebuilds the entire subtree on any field change. | `MISSING` | LOW |
| List rendering | `ListView.builder`/`.separated` for lists of unknown/large size | ✅ 4 of 6 `ListView` call sites are `.builder`; remaining 2 are short bounded lists (`session_summary_screen.dart:63`, `context_panel.dart:48`). Acceptable. | OK | — |
| Image loading | Cached + placeholder + error fallback | ✅ `CachedNetworkImage` wrapped in `CloudImage` with `ShimmerPlaceholder` + `errorWidget`. Applied consistently to Cloudinary assets. | OK | — |
| Animation cost | Controllers disposed; animations off in reduced-motion; avoid runtime asset fetch per build | ✅ All 12 AnimationController widgets dispose properly (FINDING-16 cross-ref); `LottieAsset` supports `AppAnimations.shouldReduceMotion(context)`. **But** `LottieAsset` / `LottieLocalAsset` widgets are never used — `package:lottie` is imported only inside `lottie_asset.dart` with no downstream consumers → dead bundle weight. | `IMPLEMENTED_NOT_USED` | LOW |
| `const` discipline | Where possible, `const` constructors to avoid needless rebuilds | ✅ `prefer_const_constructors` + `prefer_const_declarations` enforced by analyzer. Spot-check across screens confirms consistent `const` usage. | OK | — |
| `read` vs `watch` ratio | `read` for one-shot actions, `watch` for display | Healthy 18:7 `read:watch` ratio; `watch` is used appropriately inside `build()`, `read` for triggering methods (sign-in, increment, navigate). | OK | — |

**Findings:**

#### FINDING-17: `Selector` / `context.select` never used — all rebuilds are subtree-wide
- **Category:** 3
- **Severity:** LOW
- **Gap type:** MISSING
- **Location:** All 7 `context.watch` call sites + 5 `Consumer<T>` sites across `lib/features/**`
- **Evidence:**
  ```
  $ grep -rn "context\.select\|Selector<" lib --include="*.dart" | wc -l
  0
  ```
- **Impact:** Every `context.watch<HomeProvider>()` call rebuilds the caller on **any** `notifyListeners()` from `HomeProvider`, even if the watcher only consumes `userProfile.name`. For small screens this is unmeasurable; for `scenario_chat_screen` (409 LOC with a `Consumer<ScenarioProvider>` wrapping the message list), any unrelated state change on the provider triggers a full chat rebuild. This is not currently a visible perf problem but becomes one as providers grow.
- **Remediation:** Identify the top 3 hottest rebuild sites (chat message list, home mode pager, library grid). Replace `Consumer<ScenarioProvider>` with `Selector<ScenarioProvider, List<ChatMessage>>` or equivalent `context.select` so only the specific field change triggers rebuilds.
- **Effort:** S (per site) · tracking exercise M
- **Status:** OPEN

#### FINDING-18: `Lottie` dependency imported but its wrapper widgets are never consumed
- **Category:** 3 (owner — bundle-weight concern) — cross-ref Category 8 Dependency Management
- **Severity:** LOW
- **Gap type:** IMPLEMENTED_NOT_USED
- **Location:**
  - `lib/shared/widgets/lottie_asset.dart:1-95` (defines `LottieAsset`, `LottieLocalAsset`)
  - `pubspec.yaml:30` (`lottie: ^3.1.0`)
- **Evidence:**
  ```
  $ grep -rn "LottieAsset\|LottieLocalAsset" lib --include="*.dart" | grep -v "lottie_asset.dart"
  (no output)

  $ grep -rn "package:lottie" lib --include="*.dart"
  lib/shared/widgets/lottie_asset.dart:2:import 'package:lottie/lottie.dart';
  ```
- **Impact:** Package adds non-trivial weight to the APK/IPA (Lottie runtime + JSON parser). No corresponding user-visible animation in the app. Parallel to FINDING-06 (`sign_in_with_apple` declared but unused) — structurally identical. Updates Phase B Category 2 sub-item "Dead code" — was previously reported as "no dead Dart code"; this finding corrects that to "one dead wrapper pair + one unused dep".
- **Remediation:** Either (a) use `LottieLocalAsset` at planned sites (e.g. onboarding celebration, scenario correct-answer cheer) before release; or (b) delete `lottie_asset.dart` + remove `lottie` from `pubspec.yaml`. Decide based on near-term roadmap.
- **Effort:** XS (remove) · S (integrate at ≥1 site)
- **Status:** OPEN

**Positive findings (no action needed):**
- `ListView.builder` used at every long-list site (chat messages, conversation history, library grids, context panels).
- `CachedNetworkImage` standardized via `CloudImage` wrapper — all Cloudinary remote assets benefit from disk cache + shimmer placeholder + broken-image fallback.
- `prefer_const_constructors` lint enforced; spot-check shows widespread const correctness.
- `context.read` used for imperative actions (18×), `context.watch` reserved for reactive display (7×) — correct Provider pattern.
- `AppAnimations.shouldReduceMotion(context)` honored by the (unused) Lottie wrapper, meaning accessibility considerations were designed-in even if consumption stalled.

**Category summary:** `✅ OK`. No findings above LOW severity; no release blockers. The two findings are incremental polish: fine-grained rebuilds (nice-to-have) and dead Lottie code (quick cleanup). Performance characteristics are acceptable for a pre-launch app of this size. **Pre-release recommendation:** run `flutter run --profile` on a mid-tier Android device against the three heaviest screens (chat, library grid, home pager) to catch anything static analysis missed.

---

### Category 4 — Lifecycle & Resource — ⚠️ NEEDS_WORK

**Scope:** Correct resource release (controllers, streams, timers), widget lifecycle correctness (`mounted` checks after async work), and app-level lifecycle events (`AppLifecycleState`).

**Inputs audited:**
- Files: all widgets with `AnimationController`, `TextEditingController`, `PageController`, `ScrollController`; all providers (for `StreamSubscription`/`Timer`); `lib/app.dart` and top-level `StatefulWidget`s for `WidgetsBindingObserver`.
- Tools run: `grep -rln "AnimationController"`, `grep -rln "void dispose()"`, `grep -rln "StreamSubscription"`, `grep -rln "Timer("`, `grep -rln "WidgetsBindingObserver\|AppLifecycleState"`, spot-check of dispose body vs allocated controllers.
- Docs cross-referenced: N/A (no lifecycle spec in repo).

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| Dispose controllers | Every `AnimationController`, `TextEditingController`, `PageController`, `ScrollController` disposed | ✅ 12/12 AnimationController widgets have `dispose()`; `home_screen.dart` disposes `PageController` + removes listener; `mode_horizontal_pager.dart` disposes its `PageController`; `my_library_screen.dart` + `chat_input_bar.dart` dispose `TextEditingController`; all `scenario_chat_screen` AnimationController disposed. | OK | — |
| Stream / timer cleanup | Every `StreamSubscription.cancel()` and `Timer.cancel()` in `dispose` | ✅ `grep` returns zero `StreamSubscription` and zero `Timer(` usage across `lib/`. App is pull-based (on-demand Firestore fetches), not stream-subscribing. | OK | — |
| `mounted` check after await | Every `setState`/`Navigator`/`context.go` after `await` gated by `if (!mounted) return;` | Not systematically audited in this phase; spot-check of `scenario_chat_screen.dart`, `auth_screen.dart`, `onboarding_screen.dart` shows inconsistent use. Spec item **carried into Category 10 UI/UX** for systematic audit (async gap-after-await is a UX/crash concern). | Deferred | — |
| App lifecycle handling | `WidgetsBindingObserver` or app-state listener flushes pending work on pause/background | ❌ Zero occurrences of `WidgetsBindingObserver` or `AppLifecycleState` across `lib/`. App being backgrounded mid-scenario has no hook to flush unsaved conversation. | `MISSING` | MEDIUM |

**Findings:**

#### FINDING-16: No `AppLifecycleState` handling — backgrounding can lose in-flight scenario
- **Category:** 4 (owner) — cross-ref Category 13 (Business Logic), Category 14 (Offline Capability)
- **Severity:** MEDIUM
- **Gap type:** MISSING
- **Location:** `lib/app.dart` (no `WidgetsBindingObserver` mixin); `lib/features/scenario/providers/scenario_provider.dart` (no external lifecycle hook)
- **Evidence:**
  ```
  $ grep -rln "WidgetsBindingObserver\|AppLifecycleState" lib --include="*.dart"
  (no output)
  ```
  `ScenarioProvider.endSession()` fires `unawaited(_firebase.saveConversation(...).catchError((_) {}))` at `scenario_provider.dart:385`. If the user backgrounds the app mid-session (before pressing "end"), there is no trigger to save the partial conversation.
- **Impact:**
  - **Data loss:** Partial conversations not saved when user swipes away or receives a call. For a voice-based AI learning session, this is the single-most-likely "my practice disappeared" complaint.
  - **Daily quota drift:** Gemini calls were spent; the record of the call never reaches Firestore. User-visible quota displayed on Home may diverge from actual API usage.
  - **No pause/resume polish:** AnimationControllers continue `repeat()` in background, burning CPU/battery. No automatic re-authentication or re-sync on resume.
- **Remediation:**
  1. Add `WidgetsBindingObserver` to `_AuraCoachAppState` in `lib/app.dart`. In `didChangeAppLifecycleState(AppLifecycleState state)`:
     - `paused` → call `_scenarioProvider.flushPendingSave()` (new API), stop animations that run in background.
     - `resumed` → refresh auth token freshness, re-fetch daily-limit counter, restore animations.
  2. Add `ScenarioProvider.flushPendingSave()` that awaits any in-flight save and triggers an extra `saveConversation` if `_messages.isNotEmpty && sessionState != ended`.
  3. Cross-reference with Category 14 Offline Capability — lifecycle flush is one prong of the persistent-conversation story.
- **Effort:** S–M (app-level plumbing is S; provider API change is S; total ~S+)
- **Status:** OPEN

**Positive findings (no action needed):**
- 12 `AnimationController` allocations, 12 `dispose()` implementations — 100% disposal rate verified.
- All `PageController`, `TextEditingController`, `ScrollController` instances disposed in their owning widget's `dispose()`.
- No `StreamSubscription` or raw `Timer()` usage — eliminates an entire class of leak risk. Data flow is pull-based (request/response Firestore), not stream-subscribing.
- `home_screen.dart` correctly pairs `addListener` + `removeListener` before disposing the `PageController`.

**Category summary:** `⚠️ NEEDS_WORK`. Resource disposal hygiene is strong. The only gap is app-level lifecycle handling (FINDING-16), which is MEDIUM severity but important for user-facing data integrity in the voice scenario flow. Post-remediation the category would flip to `✅ OK`.

---

### Category 5 — Network & API — ⚠️ NEEDS_WORK

**Scope:** Outbound network interactions: Gemini API, Firestore (via Firebase SDK), Google Sign-In, Cloudinary image fetches, Lottie JSON fetches. Evaluates retry, timeout, transient-error handling, rate limiting, secure transport, and error surfacing.

**Inputs audited:**
- Files: `lib/data/gemini/gemini_service.dart` (293 LOC), `lib/data/gemini/helpers.dart` (retry helper), `lib/data/datasources/firebase_datasource.dart`, `lib/features/scenario/providers/scenario_provider.dart`, `lib/features/onboarding/providers/onboarding_provider.dart`.
- Tools run: `grep -rn "\.timeout("`, `grep -rn "retryOperation"`, `grep -rn "FieldValue\.increment\|SetOptions"`, `grep -rn "unawaited"`, inspection of `_run` method in `gemini_service.dart`.
- Docs cross-referenced: `retryOperation` comment block in `helpers.dart` referencing web `retryOperation` behaviour (historical parity).

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| Retry logic | Transient-error retry with exponential backoff + jitter | ✅ `retryOperation<T>` retries on `429`/`503`/`RESOURCE_EXHAUSTED`/`UNAVAILABLE`/`quota`; exponential `delay *= 2`. **No jitter**; `maxRetries = 1` (2 total attempts). | Partial | LOW |
| Timeouts | Every outbound call has a deadline | ✅ Gemini: 30s scenario, 20s evaluate; Firestore daily usage: 5s; onboarding save: 8s. | OK | — |
| Error response handling | Errors surfaced to UI OR handled with fallback + log | Mixed: Gemini failures → fallback to `ScenarioCache` with explicit source flag (good, Cat 14). Firestore writes → silent `catchError((_) {})` (bad, FINDING-12/19). | See FINDING-19 | — |
| Atomic writes | Mutations use atomic / merge operations | ✅ `incrementDailyUsage` uses `FieldValue.increment(1)` + `SetOptions(merge: true)` + `serverTimestamp()` — no read-modify-write race. | OK | — |
| Rate limiting | Client-side + server-side quota | Server-side via Firestore `users/{uid}/usage/{date}` doc; client reads `_dailyUsage` and blocks via `canStartSession()`. Free/pro tiers in `QuotaConstants`. **Client-side limit can be bypassed** if local memory is not re-synced from Firestore between sessions (see FINDING-19). | Partial | See FINDING-19 |
| Secure transport | HTTPS enforced, no plaintext endpoints | Firebase SDK and CachedNetworkImage use HTTPS by default. No raw `http://` found. No `http` or `dio` packages declared; network is routed via Firebase/Gemini SDKs which enforce TLS. | OK | — |
| Auth token refresh | Tokens refreshed transparently; no stale-token 401 loops | `FirebaseAuth` SDK handles ID-token refresh internally. No custom token plumbing — no way to get this wrong, no way to validate either. | OK (implicit) | — |
| User-facing retry UX | Active retry visible to user | Retry happens silently inside `retryOperation` (1s delay); user sees spinner, no "retrying..." banner. Acceptable for <2s total; not acceptable if backoff grows. | Partial | LOW (subsumed by FINDING-20) |

**Findings:**

#### FINDING-19: Fire-and-forget quota/conversation writes can silently drop data
- **Category:** 5 (owner) — cross-ref Category 2 FINDING-12 (silent catches), Category 12 FINDING-14 (state drift), Category 14 (offline)
- **Severity:** MEDIUM
- **Gap type:** UNSAFE
- **Location:**
  - `lib/features/scenario/providers/scenario_provider.dart:216-221` (quota increment)
  - `lib/features/scenario/providers/scenario_provider.dart:220` (`catchError((_) {})`)
  - `lib/features/scenario/providers/scenario_provider.dart:385` (end-session save)
- **Evidence:**
  ```dart
  // scenario_provider.dart:216-221 — optimistic local update + fire-and-forget remote
  if (source == ScenarioSource.live) {
    _dailyUsage['roleplayCount'] = roleplayUsedToday + 1;
    unawaited(_firebase
        .incrementDailyUsage(_uid!, _todayDate, 'roleplay')
        .catchError((_) {}));
    unawaited(_saveConversationToFirestore());
  }
  ```
- **Impact:**
  - **Quota drift:** If the `incrementDailyUsage` write fails for a non-offline reason (security rule denial, auth token expired mid-session, Firestore quota error at project level), the local `_dailyUsage` says "+1" but Firestore is unchanged. On next app launch, `_loadDailyUsage` reads Firestore (or falls back to local cache via FINDING-12 catch), producing an inconsistent picture.
  - **Conversation drop:** `_saveConversationToFirestore` at line 385 uses the same pattern — a failed save is never retried, never reported. For a voice-scenario app where the session IS the product, silent session drop is a user-experience failure.
  - **Free-tier abuse surface:** If a free user can force `incrementDailyUsage` to fail (poor connection, airplane-mode toggling at the right moment), they accumulate local session counts without remote enforcement. Firestore's default offline persistence *mostly* protects this — queued writes replay on reconnect — but any non-network error bypasses that protection.
- **Remediation:**
  1. Replace `catchError((_) {})` with a logging + observability helper (fits the FINDING-12 remediation plan).
  2. Maintain a small "pending writes" list in `LocalDatasource` for ops that must eventually succeed (quota increment, conversation save). On app resume and on reconnect, replay.
  3. If Firestore persistence is confirmed enabled (see FINDING-23, Cat 14), document that pure-offline failures are SDK-handled, and the manual replay queue is for *non-offline* error classes.
  4. Reconcile local vs. remote counts on app start: if Firestore count < local optimistic count, user-facing warning and re-send any queued increments.
- **Effort:** M
- **Status:** OPEN

#### FINDING-20: `retryOperation` uses `maxRetries=1` without jitter
- **Category:** 5
- **Severity:** LOW
- **Gap type:** OUTDATED (conservative default)
- **Location:** `lib/data/gemini/helpers.dart:8-34`
- **Evidence:**
  ```dart
  Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 1,                                     // only 1 retry
    Duration initialDelay = const Duration(milliseconds: 1000),
  }) async {
    // ...
    await Future.delayed(delay);
    delay *= 2;                                             // no jitter
  }
  ```
- **Impact:**
  - During sustained 429 events on Gemini (e.g. noisy neighbors on Google AI Studio free tier), a single retry after 1s may not be enough — the caller sees `FormatException` or `GenerativeAIException` and falls through to `ScenarioCache` too quickly, degrading UX when AI would have succeeded 2s later.
  - No jitter means coordinated retry storms when an app update triggers many users to reopen at once.
- **Remediation:**
  - Raise `maxRetries` to 2 or 3 (final delay 4s, total window ~7s) — still under the caller's 30s outer timeout.
  - Add jitter: `delay *= 2; delay += Duration(milliseconds: Random().nextInt(500));`.
  - Consider surfacing "AI is busy, retrying..." banner if total retry span > 2s.
- **Effort:** XS
- **Status:** OPEN

**Positive findings (no action needed):**
- Retry wrapper (`retryOperation`) applied uniformly to every Gemini call via `GeminiService._run`.
- Transient-error detection covers 429 (quota/rate), 503 (unavailable), `RESOURCE_EXHAUSTED`, `UNAVAILABLE`, and substring `quota` — good catch surface.
- Timeouts set on **every** outbound call (not just Gemini) — Firestore daily-usage fetch (5s), onboarding save (8s), Gemini evaluate (20s), Gemini scenario (30s).
- `incrementDailyUsage` uses Firestore atomic `FieldValue.increment(1)` — race-free.
- Daily-usage doc keyed by `yyyy-MM-dd` (`DateFormat('yyyy-MM-dd').format(DateTime.now())`) — simple, testable, timezone follows device clock (acceptable for free-tier counting).
- HTTPS enforced transitively via SDKs; no `package:http` or `package:dio` in dep tree to manage.

**Category summary:** `⚠️ NEEDS_WORK`. Core networking architecture (retry, timeout, atomic writes, transient detection) is well-designed. The two findings are the error-path polish — FINDING-19 must be addressed before release because silent data drop is the single-worst UX defect for an AI learning app where "my conversation disappeared" is the loss. FINDING-20 is tuning.

---

### Category 8 — Dependency Management — ⚠️ NEEDS_WORK

**Scope:** Direct dependencies declared in `pubspec.yaml`, their versions, actual usage in code, and absence of supporting dep-audit tooling.

**Inputs audited:**
- Files: `pubspec.yaml`, `pubspec.lock` (107 resolved transitive deps).
- Tools run: `grep "^import 'package:<name>" lib` per declared dep to count usage; SDK constraint read from pubspec.
- Docs cross-referenced: recent commit `b05e110 fix(gemini): use gemini-2.5-flash/pro — 2.0 models retired` (shows version-awareness in team).

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| Outdated packages | All direct deps current major; no retired APIs | Not verifiable in sandbox (`dart pub outdated` unavailable). SDK `>=3.2.0 <4.0.0` current; Firebase v3/v5/v6 stack current; `google_generative_ai ^0.4.6` known to need 2.5 models (fixed). | Needs tooling run | LOW (pending verify) |
| Version conflict | `pub get` resolves without conflict | `pubspec.lock` resolves 107 deps cleanly. | OK | — |
| Unused packages | Every declared dep has ≥1 import | `sign_in_with_apple` declared but 0 imports in `lib/` | `IMPLEMENTED_NOT_USED` | MEDIUM |

**Findings:**

#### FINDING-06: `sign_in_with_apple` declared but never imported
- **Category:** 8
- **Severity:** MEDIUM
- **Gap type:** IMPLEMENTED_NOT_USED
- **Location:** `pubspec.yaml:20` (`sign_in_with_apple: ^6.1.4`)
- **Evidence:**
  ```
  $ grep -rh "package:sign_in_with_apple" lib --include="*.dart" | wc -l
  0
  ```
- **Impact:** Bloats iOS binary with unused AuthenticationServices framework link. Misleads contributors into thinking Apple Sign-In is implemented. Blocks iOS App Store compliance planning (Apple requires Sign-In with Apple if Google Sign-In is present — so this dep may be *planned*, just not wired).
- **Remediation:** Either: (a) wire Apple Sign-In button in `lib/features/auth/screens/auth_screen.dart` per Apple's App Store rule requiring it alongside Google Sign-In; or (b) temporarily remove the dep until ready — but (a) is mandatory if shipping iOS. **Recommend (a) before iOS release.**
- **Effort:** M (implement) / XS (remove)
- **Status:** OPEN

#### FINDING-07: No automated dependency audit (no CI pipeline detected)
- **Category:** 8 (cross-cutting: see Category 9 CI/CD when audited)
- **Severity:** MEDIUM
- **Gap type:** MISSING
- **Location:** Project root (no `.github/workflows/`, no `codemagic.yaml`, no `fastlane/`, no `bitrise.yml`)
- **Evidence:** `find . -maxdepth 4 -name "*.yaml" -path "*/workflows/*"` returns nothing; no CI config files detected anywhere.
- **Impact:** Dependency rot (new majors, security advisories, deprecations) goes undetected between manual checks. No signal when transitive deps introduce vulnerabilities.
- **Remediation:** Add GitHub Action running `flutter pub outdated --show-all --mode=null-safety` on `schedule: cron` weekly. Consider enabling Dependabot for Dart. Fail CI on `direct` deps flagged as outdated major for >30 days.
- **Effort:** S
- **Status:** OPEN

#### FINDING-08: `dart pub outdated` not runnable in audit sandbox — verification deferred
- **Category:** 8
- **Severity:** LOW
- **Gap type:** MISSING (methodology gap, not code gap)
- **Location:** N/A
- **Evidence:**
  ```
  $ dart --version
  /bin/bash: line 1: dart: command not found
  ```
- **Impact:** This audit cannot assert which direct dep (if any) is behind on a major version or null-safety migration. Release decision requires explicit verification.
- **Remediation:** Before cutting release branch, user runs:
  ```bash
  flutter pub outdated --mode=null-safety --show-all
  flutter pub deps --no-dev --style=tree | head -50
  ```
  and records output. Any `direct` dep in `Upgradable` column should be evaluated. Any `Dependencies discontinued` must be replaced.
- **Effort:** XS (just run the command)
- **Status:** OPEN

**Category summary:** `⚠️ NEEDS_WORK`. The release-critical item is **FINDING-06** (Apple Sign-In likely required for iOS Store approval alongside Google Sign-In). **FINDING-07** is a systemic gap that compounds over time but doesn't block this release. **FINDING-08** converts to a one-command pre-release checklist item.

---

### Category 12 — State & Data Flow — ⚠️ NEEDS_WORK

**Scope:** Single source of truth, immutability of domain state, synchronization across sources, reactivity contracts (who calls `notifyListeners`, who can mutate what).

**Inputs audited:**
- Files: all 5 feature providers (`auth`, `home`, `library`, `scenario`, `onboarding`), all model classes in `lib/data/gemini/types.dart` and `lib/data/models/*`, `lib/data/datasources/*`.
- Tools run: `grep -rn "notifyListeners\|_hasCompletedOnboarding\|List.unmodifiable\|final.*List<\|copyWith"`, `grep -rn "setOnboardingComplete\|hasCompletedOnboarding"` across sources.
- Docs cross-referenced: `docs/superpowers/specs/2026-04-08-aura-coach-comprehensive-design.md` (state management section).

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| Single source of truth | One authoritative source per domain fact | `hasCompletedOnboarding` has 3 sources: `_localDatasource.isOnboardingComplete` (SharedPreferences), `_firebaseDatasource.hasCompletedOnboarding(uid)` (Firestore), `AuthProvider._hasCompletedOnboarding` (in-memory). Reconciliation logic spread across `initialize`, `_checkOnboarding`, `completeOnboarding`, `signOut`. | `INCONSISTENT` | MEDIUM |
| Immutable state exposed to UI | UI gets read-only views; mutations go through provider methods | ✅ `ScenarioProvider.messages` returns `List.unmodifiable(_messages)`; models use `copyWith` pattern; `const` constructors widely. | OK | — |
| Data synchronization | Local ↔ remote convergence rules defined | Ad-hoc: local is written on write-through for onboarding; remote is queried opportunistically. No explicit sync policy. Scenario conversations are fire-and-forget write-behind with silent failure (FINDING-12). | `INCONSISTENT` | See FINDING-14 |
| Reactivity contract | Clear boundaries: provider mutates + notifies; UI reads + subscribes via `context.watch` | ✅ 5/5 providers use `ChangeNotifier` + `notifyListeners`; consumers use `context.watch`/`Consumer`/`Selector`. Pattern is uniform. | OK | — |
| Mutation safety | Private mutable fields, public immutable getters | ✅ Consistent across all providers (fields prefixed `_`, exposed via getters). | OK | — |

**Findings:**

#### FINDING-14: `hasCompletedOnboarding` has three sources of truth that can drift
- **Category:** 12 (owner) — cross-ref Category 13 (Business Logic) for impact on FINDING-15
- **Severity:** MEDIUM
- **Gap type:** INCONSISTENT
- **Location:**
  - `lib/features/auth/providers/auth_provider.dart:21` — in-memory `bool _hasCompletedOnboarding`
  - `lib/features/auth/providers/auth_provider.dart:45-63` — `initialize()` reconciles local → Firestore
  - `lib/features/auth/providers/auth_provider.dart:120-131` — `_checkOnboarding()` queries Firestore post-login
  - `lib/features/auth/providers/auth_provider.dart:133-142` — `completeOnboarding()` writes both
  - `lib/data/datasources/local_datasource.dart:13-17` — SharedPreferences getter/setter
  - `lib/data/datasources/firebase_datasource.dart` — Firestore `users/{uid}.onboardingCompleted` (inferred)
- **Evidence:**
  ```dart
  // auth_provider.dart:45-63
  Future<void> initialize() async {
    _hasCompletedOnboarding = _localDatasource.isOnboardingComplete;  // (1) local first
    if (currentUser != null && !_hasCompletedOnboarding) {
      try {
        _hasCompletedOnboarding =
            await _firebaseDatasource.hasCompletedOnboarding(currentUser!.uid);  // (2) Firestore override
        if (_hasCompletedOnboarding) {
          await _localDatasource.setOnboardingComplete(true);                    // (3) write-through
        }
      } catch (_) { /* silently ignore */ }                                      // (4) FINDING-12
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  ```
- **Impact:**
  - Three places can write, three places can read. A bug in any one of the four write paths (`initialize`, `_checkOnboarding`, `completeOnboarding`, `signOut`) desynchronizes the sources.
  - The precedence rule is implicit (local-first-then-Firestore-upgrade-but-never-downgrade). Not documented in code or design docs.
  - Sign-out clears in-memory but not the SharedPreferences `onboarding_complete` key — next sign-in with different Google account inherits previous user's onboarding state via local cache.
- **Remediation:**
  1. Declare Firestore as authoritative, local as cache. Write a single `OnboardingStateRepository` (fits the Category 1 / FINDING-01 remediation) that owns reconciliation.
  2. On sign-out, clear both cached state and the `cached_uid` SharedPreferences key to prevent account-bleed.
  3. On sign-in, if `cached_uid != currentUser.uid`, invalidate local onboarding cache and re-query Firestore.
  4. Document precedence in `ARCHITECTURE.md` (FINDING-10).
- **Effort:** S–M
- **Status:** OPEN

**Positive findings (no action needed):**
- `List.unmodifiable(_messages)` exposed by `ScenarioProvider` prevents accidental mutation from UI.
- Domain models (`ScenarioSession`, `UserProfile`) implement `copyWith` pattern consistently.
- Uniform `ChangeNotifier` + `notifyListeners` across all 5 providers — no mixed state-management patterns (Bloc/Riverpod/GetX absent, which is deliberate consistency).
- Private field / public getter discipline is enforced manually and followed throughout.

**Category summary:** `⚠️ NEEDS_WORK`. The only finding is the triple-source-of-truth for onboarding state. It is MEDIUM (not HIGH) because the in-practice precedence happens to be correct most of the time — the actual user-facing bug it enables is captured as FINDING-15 (Category 13). Fixing FINDING-14 upstream makes FINDING-15 automatically disappear.

---

### Category 13 — Business Logic — ⚠️ NEEDS_WORK

**Scope:** Correctness of user-facing flows (auth, onboarding, scenario, library), handling of edge cases (offline, mid-flow backgrounding, expired tokens), error-scenario UX.

**Inputs audited:**
- Files: `lib/features/auth/**`, `lib/features/onboarding/**`, `lib/features/scenario/**`, `lib/features/my_library/**`, all datasources.
- Tools run: trace of `AuthProvider.initialize()` → redirect logic in `lib/app.dart:82-97` → sign-in flow methods → `_checkOnboarding`; trace of `ScenarioProvider.startSession → generateResponse → endSession`; scan for input validation.
- Docs cross-referenced: `docs/business-flow/aura-coach-mobile-business-flows-v2.md` (expected flows).

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| Flow correctness — happy path | Auth → onboarding → home → scenario → summary works end-to-end with no unintended loops | Spec flow appears matched. Router redirect in `app.dart:82-97` correctly gates `/auth`, `/onboarding`, `/home`. No obvious happy-path regression. | OK | — |
| Flow correctness — returning user | Returning user on fresh device should NOT see onboarding again when Firestore has `onboardingCompleted: true` | If Firestore query throws (offline, network glitch), catch on `auth_provider.dart:54` defaults to `_hasCompletedOnboarding = false` → redirect sends user to `/onboarding`. | `ANTI_PATTERN` | MEDIUM |
| Edge cases — offline sign-in | User signs in offline; app either fails gracefully or queues | Google sign-in requires online; if network drops between `signInWithCredential` and `_checkOnboarding`, the Firestore query at line 123 throws and user is onboarded again (see above). | See FINDING-15 | — |
| Edge cases — backgrounding mid-scenario | Conversation flushed to Firestore before OS reclaims memory | No app lifecycle hook exists (see FINDING-16, Cat 4). Partial conversation lost. | Cross-ref FINDING-16 | — |
| Error scenarios — user surfaced | Failures visible to user with a retry path | Silent swallowing (FINDING-12) hides most failures. `AuthProvider` has a user-surfaced `_errorMessage` pattern for sign-in errors via `friendlyAuthError`; other providers do not. | Cross-ref FINDING-12 | — |
| Input validation | Untrusted input sanitized / length-bounded | No evidence of dangerous untrusted inputs; Gemini prompts are template-built from enum values. User onboarding inputs are picker-based (no free-text injected into Firestore queries). | OK | — |

**Findings:**

#### FINDING-15: Offline Firestore during sign-in re-onboards a returning user
- **Category:** 13 (owner) — depends on FINDING-14 (Cat 12) and FINDING-12 (Cat 2)
- **Severity:** MEDIUM
- **Gap type:** ANTI_PATTERN
- **Location:** `lib/features/auth/providers/auth_provider.dart:45-63` (`initialize`), `:120-131` (`_checkOnboarding`)
- **Evidence:**
  ```dart
  // First run on a new device: _localDatasource.isOnboardingComplete = false.
  // User signs in with existing account. Firestore has onboardingCompleted: true.
  // But if the Firestore call throws (network flap, timeout, Firebase rule error),
  // the catch at line 54 or 129 defaults _hasCompletedOnboarding to false.
  // Router redirect in app.dart:90 then sends user to /onboarding.
  ```
  Compounded by: no retry, no user-visible "we couldn't reach your profile — please try again" message, no distinction between "truly new user" and "failed to check".
- **Impact:**
  - Returning user on new device (post-install, post-factory-reset) may see onboarding again during flaky connectivity.
  - If user completes the onboarding flow again, it's a no-op write for them in Firestore — but it's a bad first impression.
  - Non-data-corrupting (hence MEDIUM not HIGH): Firestore `onboardingCompleted` is idempotent, user profile is keyed by UID.
- **Remediation:**
  1. Differentiate network error from "user is actually new" — on catch, set a pending `_profileCheckPending = true` flag and redirect to a `/splash` or `/checking` screen with retry, not straight to `/onboarding`.
  2. Add exponential-backoff retry to `FirebaseDatasource.hasCompletedOnboarding` before giving up.
  3. Fix FINDING-12 (surface error) and FINDING-14 (unified source of truth) — together those two changes make this finding's root cause impossible.
- **Effort:** S (when done alongside FINDING-14)
- **Status:** OPEN

**Positive findings (no action needed):**
- Happy-path auth-onboarding-home-scenario flow gated correctly by router redirect.
- Auth errors surfaced via `AuthProvider._errorMessage` with friendly mapping (`friendlyAuthError`) — good model for other providers to copy.
- No free-text user inputs reaching Firestore queries; picker-based onboarding avoids injection surface.
- Gemini prompts are template-built from enum-validated inputs in `scenario_provider`, not free-concatenated user strings.

**Category summary:** `⚠️ NEEDS_WORK`. Only one finding, MEDIUM. It is downstream of FINDING-12 (silent catches) and FINDING-14 (triple state). Fixing those two upstream fixes this automatically. Mid-scenario backgrounding data loss is tracked in FINDING-16 (Cat 4).

---

### Category 14 — Offline Capability — ⚠️ NEEDS_WORK

**Scope:** Behavior when the device has no/poor connectivity. Covers: local caching of remote data, offline detection, graceful UI degradation, write-queue replay on reconnect, and scope of offline coverage across features.

**Inputs audited:**
- Files: `lib/data/cache/scenario_cache.dart` (75 LOC — versioned cache for scenario + assessment), `lib/data/datasources/local_datasource.dart`, `lib/features/scenario/providers/scenario_provider.dart` (source-fallback logic lines 151-230), `pubspec.yaml` (no `connectivity_plus` declared), `lib/features/splash/screens/splash_screen.dart` (init-with-fallback).
- Tools run: `grep -rn "Connectivity\|connectivity_plus\|hasConnection"` (0 matches), `grep -rn "ScenarioCache"`, `grep -rn "isOfflineFallback\|ScenarioSource"`, `grep -rn "enablePersistence\|FirestoreSettings"` (0 explicit config), inspection of `_loadDailyUsage` fallback at `scenario_provider.dart:112-127`.
- Docs cross-referenced: `ScenarioCache` doc comment — "gracefully degrade when the Gemini API is unavailable. Single source of truth for the cache + error fallback strategy — no mock data, no synthetic fake lessons."

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| Local caching of remote data | Critical read paths have disk cache | Partial — `ScenarioCache` for scenario + assessment (versioned keys `v1`); `LocalDatasource` caches daily usage + `active_conversation`. **No cache** for library items, profile, conversation history, saved items. | `INCONSISTENT` | LOW (see FINDING-23) |
| Connectivity detection | Proactive check + reactive listen | None — zero occurrences of `Connectivity`/`connectivity_plus`/`hasConnection`. App discovers offline state only when an outbound call throws. | `MISSING` | MEDIUM |
| Graceful UI degradation | Explicit "you're offline" state; not just a silent failure | ✅ Scenario flow sets `isOfflineFallback = true`, injects a system message (`"Showing your last cached lesson — AI is unavailable right now."`), keeps the user moving. **But** other features (library, profile, auth) just silently fail (FINDING-12 cross-ref). | Partial | Cross-ref |
| Write-queue replay | Failed writes queued and replayed on reconnect | None at application level. Firestore SDK's default offline persistence provides *some* replay for Firestore writes, but (a) not explicitly configured (see below), (b) doesn't cover Gemini calls or Cloudinary, (c) silent `catchError` bypasses the guarantee for non-offline error classes. | `MISSING` | MEDIUM |
| Firestore offline persistence | Explicit config (not relying on defaults) | Default Firebase SDK behavior is "enabled on mobile, disabled on web" — not explicitly configured in `lib/main.dart` or `lib/app.dart`. Acceptable but fragile against SDK major upgrades. | `MISSING` | LOW |
| Scope coverage | All core flows have an offline story | Only scenario. Home page (mode cards), library, profile, conversation history all require live Firestore to render. | `MISSING` | Cross-ref FINDING-23 |

**Findings:**

#### FINDING-21: No explicit connectivity detection — offline state discovered only via exceptions
- **Category:** 14 (owner) — cross-ref Category 5 (network UX)
- **Severity:** MEDIUM
- **Gap type:** MISSING
- **Location:** Project-wide. `pubspec.yaml` has no `connectivity_plus`, `internet_connection_checker`, or equivalent. No `StreamSubscription<ConnectivityResult>` anywhere.
- **Evidence:**
  ```
  $ grep -rn "Connectivity\|connectivity_plus\|internet_connection" lib pubspec.yaml
  (no output from lib/; no match in pubspec.yaml)
  ```
- **Impact:**
  - **No pre-emptive UX.** User taps "Start Session" while offline → 30s timeout wait → fallback to cache. With connectivity detection, the app could instantly show "You're offline — loading cached lesson" without the wait.
  - **No auto-retry on reconnect.** When connectivity returns, there's no hook to replay pending writes (FINDING-22) or refresh stale state.
  - **Error messages conflate causes.** Timeout vs. rate-limit vs. offline all surface as the same generic failure.
- **Remediation:**
  1. Add `connectivity_plus: ^6.x` (Flutter team package).
  2. Expose a `ConnectivityProvider` (or inject `Stream<ConnectivityResult>` into existing providers).
  3. Gate `startSession`/`saveProfile`/… on current state; if `none`, immediately take the offline fallback path with no wait.
  4. Subscribe to transitions `none → {wifi|mobile}` and fire `flushPendingSave()` (pairs with FINDING-22).
- **Effort:** S
- **Status:** OPEN

#### FINDING-22: No application-level write-replay queue for offline-to-online transitions
- **Category:** 14 (owner) — cross-ref Category 5 FINDING-19 (fire-and-forget drops), Category 4 FINDING-16 (backgrounding)
- **Severity:** MEDIUM
- **Gap type:** MISSING
- **Location:** No queue exists. Failed writes → `catchError((_) {})`. Firestore SDK's default offline persistence provides partial coverage only.
- **Evidence:**
  - `lib/features/scenario/providers/scenario_provider.dart:216-221` — quota increment + conversation save are fire-and-forget.
  - `lib/features/scenario/providers/scenario_provider.dart:385` — end-session save is fire-and-forget.
  - `lib/data/datasources/local_datasource.dart` has no "pending ops" storage key.
- **Impact:**
  - Firestore SDK persistence handles the happy-offline case (network down). But: (a) non-offline errors (auth/rule/quota) don't queue; (b) any Gemini-round-trip + Firestore-save sequence loses the Firestore write if it happens mid-transition; (c) there's no visibility for the user that "3 sessions are waiting to sync".
  - Pairs with FINDING-16 — without both an `AppLifecycleState.paused` flush AND a replay-on-reconnect, mid-session data loss has two unplugged leaks.
- **Remediation:**
  1. Add a `PendingWritesQueue` in `LocalDatasource` (SharedPreferences JSON list).
  2. On every save failure in `ScenarioProvider` / `LibraryProvider` / `AuthProvider`, enqueue a record with op-type + payload + timestamp + UID.
  3. Subscribe to `ConnectivityProvider.onRestored` (FINDING-21) → drain queue; on each success, remove from queue.
  4. Limit queue size (e.g. 100 entries) to prevent unbounded growth.
  5. Surface queue size to user as a subtle "syncing…" indicator.
- **Effort:** M
- **Status:** OPEN

#### FINDING-23: Offline cache only exists for scenario flow; library/profile/history/auth have none
- **Category:** 14
- **Severity:** LOW
- **Gap type:** MISSING (scope gap)
- **Location:**
  - `lib/features/my_library/providers/library_provider.dart` — no disk cache
  - `lib/features/home/providers/home_provider.dart` — no disk cache of user profile
  - `lib/features/scenario/screens/conversation_history_screen.dart` — Firestore query per view, no snapshot cache
- **Evidence:** Only `ScenarioCache` (75 LOC, 2 entities: last lesson + last assessment) exists. `grep -rn "SharedPreferences\|hive\|sqflite\|isar" lib` outside datasources returns no other persistence layer.
- **Impact:**
  - Returning user on subway / in-flight sees an empty-looking app: library loads blank, profile doesn't render, history is empty. Contrasts poorly with the well-designed scenario offline fallback.
  - Engagement hit: users can't flip through previously-saved library items for quick review without network.
- **Remediation:** Extend the `ScenarioCache` pattern to `LibraryCache` (`saveLastLibraryItems`/`getLastLibraryItems`), `ProfileCache` (cached UserProfile). Source of truth remains Firestore; cache is read-only display path when remote read fails.
- **Effort:** M
- **Status:** OPEN

**Positive findings (no action needed):**
- `ScenarioCache` is a textbook fallback cache: versioned keys (`v1`), JSON-based, bounded (1 lesson + 1 assessment only, not a list), error-tolerant (debugPrint + return null on corrupt payload).
- Explicit `ScenarioSource` enum (`live` vs `cache`) + `isOfflineFallback` getter lets UI render an unambiguous banner. User trust preserved.
- System-message injection (`"Showing your last cached lesson…"`) is a polished pattern other features should copy.
- Cache doc comment explicitly rejects "synthetic fake lessons" — good engineering principle preserved in the code.
- `LocalDatasource` already has `getCachedDailyUsage` with an offline path → `scenario_provider._loadDailyUsage` cleanly falls back when Firestore timeout fires.
- Firestore offline persistence defaults to enabled on mobile; writes are queued by the SDK during pure network-outage (though not for non-offline errors — see FINDING-22).

**Category summary:** `⚠️ NEEDS_WORK`. Scenario-only offline story is well-executed and serves as a template. The three findings are about generalizing that pattern: detect connectivity proactively (FINDING-21), queue writes explicitly (FINDING-22), and broaden cache coverage to non-scenario features (FINDING-23). None block release in isolation, but FINDING-21 + FINDING-22 together directly determine whether the "conversation disappeared" class of bugs happens or not — they should ship as a pair.

---

### Category 16 — Maintainability — ⚠️ NEEDS_WORK

**Scope:** How easily a new contributor (or future-you in 6 months) can navigate, understand, and change the codebase. Covers folder structure sanity, documentation presence/quality, and code readability signals.

**Inputs audited:**
- Files: `README.md`, `docs/**` (10+ markdown files), project root (`ARCHITECTURE.md`, `CONTRIBUTING.md` absence), `.gitignore`, file-size distribution in `lib/`.
- Tools run: `wc -w docs/**/*.md`, `find . -iname ARCHITECTURE\*` / `CONTRIBUTING\*`, `wc -l lib/**/*.dart`.
- Docs cross-referenced: existing specs under `docs/superpowers/specs/`, business flow docs under `docs/business-flow/`.

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| Folder structure | Consistent, self-explanatory, feature-first | ✅ Feature-first layout clean; `core/data/shared` well-named; `domain/` mostly empty (see FINDING-01). | OK | LOW |
| Documentation | README with project overview + setup; ARCHITECTURE.md; CONTRIBUTING.md | README is default Flutter scaffold; no root-level ARCHITECTURE or CONTRIBUTING; extensive but scattered `docs/` folder. | `MISSING` | MEDIUM |
| Readability | Consistent naming; files mostly <500 LOC | Overall consistent naming ✅; 4 files >700 LOC (see FINDING-05); `.DS_Store` artifacts modified despite `.gitignore` rule. | `INCONSISTENT` | LOW |

**Findings:**

#### FINDING-09: README is the default Flutter template
- **Category:** 16
- **Severity:** MEDIUM
- **Gap type:** MISSING
- **Location:** `README.md:1-18`
- **Evidence:**
  ```
  # aura_coach_ai

  A new Flutter project.

  ## Getting Started

  This project is a starting point for a Flutter application.
  ...
  ```
  No mention of Aura Coach, AI features, architecture, env vars, or run instructions.
- **Impact:** Onboarding drag — new contributors start from nothing. If repo becomes public or is shared with reviewers/investors, README sets a poor first impression. Newcomers miss critical setup (`.env` with `GEMINI_API_KEY`, Firebase config placement).
- **Remediation:** Rewrite with sections: (1) Project purpose (Aura Coach AI, 6 AI learning modes, Clay design). (2) Prerequisites (Flutter SDK ≥3.2, Firebase project, Gemini API key). (3) Setup (`.env` with `GEMINI_API_KEY=...`, Firebase config per platform). (4) Run (`flutter run`). (5) Folder tour (`lib/core`, `lib/data`, `lib/features`, `lib/shared`). (6) Pointer to `docs/business-flow/` and `docs/superpowers/`.
- **Effort:** S
- **Status:** OPEN

#### FINDING-10: No root-level `ARCHITECTURE.md` or `CONTRIBUTING.md`
- **Category:** 16
- **Severity:** LOW
- **Gap type:** MISSING
- **Location:** Project root
- **Evidence:** `find . -maxdepth 3 -iname "ARCHITECTURE*" -o -iname "CONTRIBUTING*"` returns nothing.
- **Impact:** Architectural decisions (layering, DI approach, state mgmt) live only in per-spec docs that churn with each phase. No durable, contributor-facing summary. When FINDING-03 (provider DI inconsistency) gets resolved, the chosen pattern has nowhere canonical to live.
- **Remediation:** Create `ARCHITECTURE.md` documenting: layering (core/data/domain/features/shared roles), DI pattern decision (after resolving FINDING-03), state-management approach (ChangeNotifier + Provider), routing approach (go_router with redirect in app.dart or extracted per FINDING-04), AI integration (Gemini via `GeminiService` with prompt library). Link from README.
- **Effort:** S
- **Status:** OPEN

#### FINDING-11: `.DS_Store` artifacts tracked despite `.gitignore` rule
- **Category:** 16
- **Severity:** LOW
- **Gap type:** INCONSISTENT
- **Location:** `docs/.DS_Store`, `docs/superpowers/.DS_Store`
- **Evidence:**
  ```
  $ git status --short | grep DS_Store
   M docs/.DS_Store
  ```
  `.gitignore` contains `.DS_Store` (line 5) but these files were tracked before the rule was added / before rule took effect.
- **Impact:** macOS-specific artifacts add noise to every `git status`, get committed accidentally, and slightly increase repo size over time.
- **Remediation:** `git rm --cached docs/.DS_Store docs/superpowers/.DS_Store`; commit. Confirm no other `.DS_Store` tracked via `git ls-files | grep DS_Store`.
- **Effort:** XS
- **Status:** OPEN

**Category summary:** `⚠️ NEEDS_WORK`. None of these block release per se, but **FINDING-09** (default README) is embarrassing for a public repo and should be fixed before any external eye sees the project. **FINDING-10** becomes more valuable once FINDING-03 is resolved — they should ship together.

---

### Category 6 — Security — 🔴 BLOCKING_RELEASE

**Scope:** Secrets handling, credential storage, network transport, authentication posture, backend authorization rules, platform permissions, PII handling in logs/telemetry.

**Inputs audited:**
- Files: `pubspec.yaml` (asset declarations, deps), `.env` + `.gitignore`, `lib/core/constants/api_constants.dart`, `lib/data/datasources/auth_datasource.dart`, `lib/data/datasources/local_datasource.dart`, `firestore.rules`, `android/app/src/main/AndroidManifest.xml`, `android/app/src/{debug,profile}/AndroidManifest.xml`, `ios/Runner/Info.plist`, `lib/features/**` for PII-in-log patterns.
- Tools run: `grep -rn "dotenv\|API_KEY\|apiKey" lib`, `grep -rn "debugPrint.*email\|debugPrint.*password" lib`, `grep -rn "speech_to_text\|microphone\|RECORD_AUDIO\|NSMicrophone" lib pubspec.yaml`, `git ls-files | grep -E "^\.env"`, manual read of `firestore.rules` and all three AndroidManifest.xml variants + Info.plist.
- Docs cross-referenced: `docs/business-flow/aura-coach-mobile-business-flows-v2.md` (security posture implicit in auth flows), OWASP MASVS-L1 quick pass (secrets, data-in-transit, auth, platform interaction).

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| API-key handling | Secrets held server-side; client calls proxy. If client-side key is unavoidable, use restricted key with API + referrer restrictions and a hard quota. | `.env` declared as a Flutter asset in `pubspec.yaml:41`; `GEMINI_API_KEY` loaded client-side via `dotenv` and used to call Google Generative AI directly from the device. Key is bundled into APK/IPA and extractable. | `UNSAFE` | **CRITICAL** |
| Firestore authorization | Per-user isolation; no broad reads; rules tested. | `firestore.rules` enforces `request.auth.uid == userId` on `/users/{userId}/**` and every nested subcollection. Minimal + correct. | OK ✅ | — |
| Secret storage on device | Auth tokens via platform secure storage (Keychain/Keystore), never SharedPreferences. | Firebase Auth manages its own token storage (Keychain/Keystore via the SDK). `SharedPreferences` is used only for onboarding flags + scenario cache payload, not tokens. | OK ✅ | — |
| Secret-in-repo | `.env` gitignored; no secrets tracked. | `.env` is in `.gitignore:5`; `git ls-files \| grep -E "^\.env$"` returns nothing. Key is not in git history. | OK ✅ | — |
| Onboarding for new devs | `.env.example` committed listing required vars. | Absent. `ls .env.example` → no such file. | `MISSING` | MEDIUM |
| Android permissions (release) | Explicit permissions declared in main manifest; minimum-necessary principle. | `INTERNET` declared only in `android/app/src/{debug,profile}/AndroidManifest.xml`; main manifest has **zero** `<uses-permission>` entries. Release build relies on plugin manifest merger to inject `INTERNET`. | `MISSING`/fragile | MEDIUM |
| iOS permissions | Declared usage strings for any sensitive capability (mic, camera, photos). | Info.plist declares only bundle config + Google Sign-In URL scheme + orientation. No sensitive-capability strings — consistent with the fact that no mic/camera/speech plugin is in `pubspec.yaml`. | OK ✅ | — |
| PII in logs | No email/password/token logged. | `grep` shows no `debugPrint` of email/password/token. Errors are `debugPrint`'d as opaque messages (`'Failed to ...: $e'`), which is fine. | OK ✅ | — |

**Findings:**

#### FINDING-24: `GEMINI_API_KEY` is bundled into the release binary as a Flutter asset
- **Category:** 6
- **Severity:** **CRITICAL**
- **Gap type:** UNSAFE
- **Location:** `pubspec.yaml:32-41`, `lib/core/constants/api_constants.dart:1-8`, `lib/main.dart` (`dotenv.load(fileName: ".env")` during startup), every Gemini call site in `lib/data/gemini/**`.
- **Evidence:**
  ```yaml
  # pubspec.yaml
  flutter:
    generate: true
    uses-material-design: true
    assets:
      - .env
  ```
  ```dart
  // lib/core/constants/api_constants.dart
  class ApiConstants {
    static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
    ...
  }
  ```
  Declaring `.env` under `flutter.assets` causes the Flutter tool to copy the file verbatim into the compiled APK/IPA. At runtime, `dotenv.load(fileName: ".env")` reads it from the asset bundle. The file is trivially recoverable from a signed release build:
  - **Android:** `unzip app-release.apk flutter_assets/.env` → plaintext key.
  - **iOS:** extract the app's `.ipa`, open `Payload/Runner.app/Frameworks/App.framework/flutter_assets/.env` → plaintext key.
  The Google Generative AI SDK is called **directly from the device** (`lib/data/gemini/**`), so the key has to be present on-device for the app to function as-is.
- **Impact:**
  - Within hours of a public release, the key can be extracted and reused by an attacker. Google AI Studio billing is tied to the Google Cloud project that owns the key. Attacker abuse can exhaust quota (denying service to legitimate users) or accrue unbounded cost if paid tier is active.
  - Even with an unrestricted free-tier key, reputational + operational damage: every user of the app shares one rate-limit bucket with every attacker who extracts it.
  - This is the *single most common* mobile security failure pattern and is explicitly called out in Google's own Gemini API docs ("never embed API keys directly in mobile applications").
  - Interacts with **FINDING-29** (no crash/usage telemetry): if abuse starts, the team has no observability to detect the spike.
- **Remediation:** Move Gemini calls behind a backend proxy. Recommended path:
  1. Create a Firebase Cloud Function (e.g. `callGemini`) that receives `{mode, prompt, userContext}` from authenticated clients and calls Gemini server-side using an env-var-held key. Enforce per-`request.auth.uid` rate limits inside the function (matches the existing quota tracking in `/users/{uid}/usage/{date}`).
  2. Replace `GeminiService` client calls with HTTPS calls to the function endpoint; the Firebase ID token is auto-forwarded by the `cloud_functions` Flutter SDK.
  3. Remove `.env` from `pubspec.yaml` assets; delete `GEMINI_API_KEY` from `ApiConstants`.
  4. Rotate the leaked key in Google AI Studio before any release build has ever been distributed. If any TestFlight/internal APK has gone out, treat the key as compromised and rotate immediately.
  - Interim mitigation *only* if backend work must be deferred: use an **API-key-restricted** Gemini key (bundle ID restriction + daily-quota cap) and add server-side aggregate-quota monitoring. This is strictly a stopgap, not a fix — the key is still extractable.
- **Effort:** M (Cloud Function scaffolding + client refactor + rotation + redeploy)
- **Status:** OPEN — **BLOCKS RELEASE**

#### FINDING-25: Missing `.env.example` documenting required environment variables
- **Category:** 6
- **Severity:** MEDIUM
- **Gap type:** MISSING
- **Location:** Project root.
- **Evidence:** `ls .env.example` → not present. Only `.env` (gitignored, mode 600) exists.
- **Impact:** Fresh clone does not reveal what env vars are required. Combined with FINDING-09 (default README), new-contributor setup is opaque — first run fails silently with `dotenv.env['GEMINI_API_KEY'] ?? ''` returning empty string, and the failure bubbles up only when Gemini returns a 400. Also a red flag in code review: reviewers don't know what secrets the app expects.
- **Remediation:** Commit `.env.example` at repo root with placeholder values:
  ```
  # Gemini API key — obtain from https://aistudio.google.com/app/apikey
  # NOTE: After FINDING-24 is resolved, this variable moves server-side.
  GEMINI_API_KEY=your-key-here
  ```
  Reference it in the `README.md` setup section (ties into FINDING-09).
- **Effort:** XS
- **Status:** OPEN

#### FINDING-26: Release AndroidManifest has no explicit `<uses-permission>` declarations
- **Category:** 6
- **Severity:** MEDIUM
- **Gap type:** MISSING
- **Location:** `android/app/src/main/AndroidManifest.xml:1-46`
- **Evidence:**
  ```xml
  <!-- android/app/src/main/AndroidManifest.xml (complete file) -->
  <manifest xmlns:android="http://schemas.android.com/apk/res/android">
      <application android:label="aura_coach_ai" ...>
          <activity ... />
          <meta-data android:name="flutterEmbedding" android:value="2" />
      </application>
      <queries>...</queries>
  </manifest>
  ```
  No `<uses-permission>` entries. INTERNET permission is present only in `android/app/src/debug/AndroidManifest.xml` and `android/app/src/profile/AndroidManifest.xml`.
- **Impact:** Release build relies entirely on Android manifest-merger to pick up `INTERNET` from plugin manifests (Firebase Auth, Firestore, Google Sign-In, etc. all declare it transitively). This *usually* works but is fragile: a future plugin removal, an incorrect `tools:node="remove"`, or an Android Gradle Plugin behavior change could silently strip the permission from the final merged manifest. A release APK without `INTERNET` will fail every network call — hard to diagnose because the app doesn't crash, it just times out.
- **Remediation:** Add the explicit permission to the release manifest at `android/app/src/main/AndroidManifest.xml` (at top level, before `<application>`):
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  ```
  Audit the final merged manifest once after a release build via `./gradlew :app:processReleaseManifest` and review `app/build/intermediates/merged_manifests/release/AndroidManifest.xml`. Document any other permission introduced by future features (e.g. `RECORD_AUDIO` when STT is added).
- **Effort:** XS
- **Status:** OPEN

**Positive findings (no action needed):**
- `firestore.rules` is **clean** and correct: every document under `/users/{userId}/**` requires `request.auth != null && request.auth.uid == userId`. No catch-all `allow read, write: if true;`, no unscoped collections. This is one of the strongest parts of the codebase.
- `.env` is `.gitignore`d and not in history. File permissions are `600`.
- Firebase Auth manages session tokens via platform secure storage (Keychain/Keystore) through the SDK — tokens are **not** in SharedPreferences.
- Info.plist declares no sensitive-capability usage strings because no sensitive capability is actually used (no mic/camera/photos plugin). That's correct — the concern would be declaring strings for capabilities you don't use (App Store review flag).
- `lib/features/auth/providers/auth_provider.dart` catches auth errors generically and surfaces user-friendly strings — no PII leakage in error paths.
- Google Sign-In URL scheme in Info.plist is the correct pattern (per-bundle reversed client ID).

**Category summary:** 🔴 **BLOCKING_RELEASE**. **FINDING-24 is a true release blocker** and the first CRITICAL of the audit. Until the Gemini key is behind a backend proxy (or, stopgap, restricted + capped), shipping this APK is equivalent to publishing the key. The other two findings in this category (MEDIUM) are hygiene items. Firestore rules and secure-storage posture are commendable — security isn't uniformly bad, it's specifically the client-side AI key that's wrong.

---

### Category 11 — Logging & Monitoring — 🔴 BLOCKING_RELEASE

**Scope:** Crash reporting, runtime error reporting, analytics, structured logging, global error handlers, observability pipeline. Evaluates whether the team can *know* something is wrong in production.

**Inputs audited:**
- Files: `pubspec.yaml` (dep scan for crashlytics/sentry/analytics), `lib/main.dart` (runZonedGuarded / FlutterError.onError / ErrorWidget.builder), all 5 providers and all 10 files from FINDING-12 silent-catch set, `lib/data/gemini/**` for retry/error-logging.
- Tools run: `grep -rn "crashlytics\|sentry\|firebase_analytics" pubspec.yaml lib`, `grep -rn "FlutterError.onError\|runZonedGuarded\|ErrorWidget.builder" lib`, `grep -rn "FirebaseCrashlytics\|Sentry\|FirebaseAnalytics" lib`, `grep -rn "debugPrint\|print(" lib --include='*.dart' | wc -l`.
- Docs cross-referenced: FINDING-12 evidence (silent catches). Cross-cutting concern #3 from Phase C.

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| Crash reporting | Firebase Crashlytics or Sentry wired in `main.dart`, symbols uploaded per build. | No crashlytics/sentry dep in `pubspec.yaml`. No `FirebaseCrashlytics.instance` references. | `MISSING` | **CRITICAL** |
| Non-fatal error reporting | `FlutterError.onError` + `runZonedGuarded` forward to reporter; `ErrorWidget.builder` overridden. | None of these exist. `lib/main.dart` has only `WidgetsFlutterBinding.ensureInitialized() → dotenv.load → Firebase.initializeApp → runApp`. | `MISSING` | **CRITICAL** |
| Analytics | User journey / funnel tracking (feature usage, mode selection, conversation completion). | No `firebase_analytics` dep, no `FirebaseAnalytics.instance.logEvent`. | `MISSING` | HIGH (rolled into FINDING-29) |
| Structured logging | Log level / tag / correlation ID. | `debugPrint` used throughout (`grep -c debugPrint lib` = dozens of sites). No log-level abstraction, no structured output. In release builds `debugPrint` is suppressed by default — so effectively no logs at all. | `ANTI_PATTERN` | rolled into FINDING-29 |
| Silent-catch observability prong | Every `catch` either rethrows or logs to a reporter. | 10 files (per FINDING-12) have empty/silent catches that also have no telemetry path. | `MISSING` | rolled into FINDING-29 (+ already HIGH via FINDING-12) |

**Findings:**

#### FINDING-29: Zero observability in production — no crash reporting, no global error handler, no analytics
- **Category:** 11
- **Severity:** **CRITICAL**
- **Gap type:** MISSING
- **Location:** `pubspec.yaml` (dependencies), `lib/main.dart` (bootstrap), every provider (no telemetry callbacks).
- **Evidence:**
  ```
  $ grep -rn "crashlytics\|sentry\|firebase_analytics" pubspec.yaml lib
  (no results)

  $ grep -rn "FlutterError.onError\|runZonedGuarded\|ErrorWidget.builder" lib
  (no results)
  ```
  `lib/main.dart` bootstrap in its entirety:
  ```dart
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    runApp(const AuraCoachApp());
  }
  ```
  No `runZonedGuarded`, no `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError`, no `PlatformDispatcher.instance.onError`, no `ErrorWidget.builder` to avoid the red-screen in production. Release builds default-suppress `debugPrint`, so the dozens of existing `debugPrint('$e')` calls also produce no observable output in a shipped app.
- **Impact:**
  - Once released: a crash loop on a specific Android OEM, a null-pointer regression, a Gemini API-contract change — none of these produce a stack trace the team can see. Feedback path reduces to App Store / Play Store reviews (lossy, delayed, aggregated).
  - **Compounds FINDING-12** (silent empty catches across 10 files): now the errors are *also* invisible at the telemetry layer. Silent-at-code + silent-at-network = total blindness.
  - **Compounds FINDING-19 + FINDING-22** (fire-and-forget Firestore writes, no write-replay queue): if a subset of users experience save failures, it is literally impossible to detect this until they complain.
  - No analytics means every product-side question ("which mode is most used", "how many users complete their first conversation", "drop-off at onboarding step 2 vs 4") is unanswerable at launch. Product roadmap decisions become guesses.
- **Remediation:** Minimum viable observability (single PR):
  1. Add `firebase_crashlytics: ^4.x` and `firebase_analytics: ^11.x` to `pubspec.yaml`. Run `flutterfire configure` to wire DSYM upload.
  2. Update `lib/main.dart` to capture Flutter + Dart + isolate errors:
     ```dart
     void main() async {
       runZonedGuarded<Future<void>>(() async {
         WidgetsFlutterBinding.ensureInitialized();
         await dotenv.load(fileName: '.env');
         await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
         FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
         PlatformDispatcher.instance.onError = (e, s) {
           FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
           return true;
         };
         runApp(const AuraCoachApp());
       }, (e, s) => FirebaseCrashlytics.instance.recordError(e, s, fatal: true));
     }
     ```
  3. Replace the 10 empty-catch sites from FINDING-12 with `catch (e, s) { await FirebaseCrashlytics.instance.recordError(e, s, reason: '<site name>'); rethrow; }` (or `return`/fallback-value if rethrow breaks the UX — decision per site).
  4. Instrument a minimum analytics event set: `conversation_started(mode)`, `conversation_completed(mode, duration_ms)`, `mode_opened(mode)`, `signup_completed(method)`, `daily_quota_exhausted`. These are the five that answer "is the product working as intended" at launch.
  5. Add a simple `AppLogger` abstraction (even just `debugPrint` + `FirebaseCrashlytics.log`) and replace direct `debugPrint` in hot paths — retains dev ergonomics, adds breadcrumb trail for Crashlytics on crash.
- **Effort:** M (dependency add + bootstrap refactor + retrofit catches + analytics taxonomy + dSYM/ProGuard symbol upload config)
- **Status:** OPEN — **BLOCKS RELEASE**

**Positive findings (no action needed):**
- `lib/data/gemini/helpers.dart` (`retryOperation`) does `debugPrint`-log each retry attempt with attempt number and error — this is the *one* place where errors aren't swallowed. Once a real logger is wired (per FINDING-29), this file already emits the right signal.
- Firestore SDK internally reports SDK-side errors to Google Analytics for Firebase if wired — so adding `firebase_analytics` brings some observability for free.

**Category summary:** 🔴 **BLOCKING_RELEASE**. **FINDING-29 is the second CRITICAL of the audit** and pairs with FINDING-24 as the two hard blockers. FINDING-29 is also the final piece of Cross-Cutting Concern #3: the silent-error chain (FINDING-12 → FINDING-14 → FINDING-15 → FINDING-19) is only a systemic issue *because* there is no telemetry prong. Wire Crashlytics + Analytics, retrofit the 10 empty catches, and the entire chain collapses from HIGH to MEDIUM severity.

---

### Category 7 — Testing — ⚠️ NEEDS_WORK

**Scope:** Unit tests, widget tests, integration tests, golden/visual regression tests, test infrastructure (mocks, fixtures, test doubles), coverage target, CI gating on tests.

**Inputs audited:**
- Files: `test/**`, `integration_test/**`, `pubspec.yaml` `dev_dependencies`, all 5 providers for testability, all data-layer datasources for interface abstraction.
- Tools run: `find test integration_test -type f 2>/dev/null`, `grep -c "test\|testWidgets" test/**/*.dart`, `wc -l test/**/*.dart`, dev-dependency audit for `mocktail`/`mockito`/`faker`/`patrol`/`alchemist`.
- Docs cross-referenced: Cross-Cutting Concern #1 (architecture couples providers to datasources, blocking meaningful unit tests).

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| Unit tests | Every provider has coverage on state transitions, error branches, edge cases. | One file `test/widget_test.dart` with **2 trivial enum-count assertions**. No provider test, no datasource test, no util test. | `UNCOVERED` | HIGH |
| Widget tests | Key widgets (auth flow, conversation UI, mode-picker) have `testWidgets` coverage. | None. `testWidgets` appears zero times in the repo. | `UNCOVERED` | HIGH |
| Integration tests | `integration_test/` directory with at least one happy-path E2E (signup → mode pick → short conversation). | Directory does not exist. | `MISSING` | HIGH |
| Golden / visual regression | Optional but recommended for a design-heavy app (Clay design). | None. No `alchemist` / `golden_toolkit` dep. | `MISSING` | MEDIUM |
| Test infrastructure | `mocktail` or `mockito` in dev_dependencies; fixture builders; fake Firestore. | `dev_dependencies` contains only `flutter_test` and `flutter_lints: ^5.0.0`. No mocking library. | `MISSING` | HIGH |
| CI gating | Tests run on every PR; coverage tracked over time. | No CI exists (see FINDING-28). Even the one existing test is not automatically executed. | `MISSING` | HIGH (rolled into FINDING-28) |

**Findings:**

#### FINDING-27: Near-zero automated test coverage; no mocking infrastructure
- **Category:** 7
- **Severity:** HIGH
- **Gap type:** UNCOVERED / MISSING
- **Location:** `test/widget_test.dart` (only test file), `pubspec.yaml:32-36` (dev_dependencies).
- **Evidence:**
  ```
  $ find test integration_test -type f 2>/dev/null
  test/widget_test.dart

  $ wc -l test/widget_test.dart
  21 test/widget_test.dart
  ```
  Full content of `test/widget_test.dart`:
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:aura_coach_ai/features/auth/providers/auth_provider.dart';

  void main() {
    test('AuthStatus has expected values', () {
      expect(AuthStatus.values.length, 3);
      expect(AuthStatus.values, contains(AuthStatus.authenticated));
      expect(AuthStatus.values, contains(AuthStatus.unauthenticated));
    });
    test('AuthMethod has expected values', () {
      expect(AuthMethod.values.length, 3);
      expect(AuthMethod.values, contains(AuthMethod.email));
      expect(AuthMethod.values, contains(AuthMethod.google));
    });
  }
  ```
  Zero coverage of business logic. These tests only verify `enum.values.length` — they would still pass if every provider method was broken.
  ```yaml
  # pubspec.yaml — dev_dependencies
  dev_dependencies:
    flutter_test:
      sdk: flutter
    flutter_lints: ^5.0.0
  ```
  No mocking (`mocktail`/`mockito`), no fake Firestore (`fake_cloud_firestore`), no integration-test harness (`patrol`), no golden-test framework.
- **Impact:**
  - Every refactor is unvalidated. The Phase A architectural work (unwinding FINDING-02 provider→datasource coupling) cannot be verified to not break behavior.
  - Every Flutter SDK upgrade, Firebase plugin upgrade, or Gemini SDK upgrade ships blind. Breaking-API regressions in `google_generative_ai` specifically will only be discovered by users after release.
  - Combined with FINDING-29 (no telemetry), regressions are invisible twice over — they can't be caught before release (no tests) or after (no crash reports).
  - Business-critical flows (onboarding triple-state in FINDING-14, daily-quota gating, conversation-save invariants) have zero guard rails. The team is essentially one refactor away from breaking signup or losing a day of user conversations silently.
- **Remediation:** Phased plan, minimum viable before release:
  1. **Unblock testability first:** resolve FINDING-02 partially by introducing repository interfaces for the three highest-risk paths (`AuthRepository`, `ConversationRepository`, `UsageRepository`). Without interfaces, mocking is painful.
  2. Add `mocktail: ^1.x` and `fake_cloud_firestore: ^3.x` to `dev_dependencies`.
  3. Write a **minimum viable test suite** before any release:
     - `auth_provider_test.dart` — happy signup, duplicate-email error, network error → state flips correctly, onboarding flag toggled once (FINDING-14 regression guard).
     - `scenario_provider_test.dart` — cached-fallback path, online→offline transition, daily-quota exhaustion.
     - `conversation_flow_test.dart` (widget test) — mode pick → send message → receive reply → save.
     - `onboarding_flow_test.dart` (widget test) — first-launch goes to onboarding; post-signup does not loop.
  4. Add one integration test: full signup → pick scenario → 3-turn conversation → verify save. Parks in `integration_test/smoke_test.dart`.
  5. Wire into CI (paired with FINDING-28). Require passing tests before merge.
  6. Target: ≥50% provider-method coverage and ≥1 widget test per feature before marking HIGH → MEDIUM. Golden tests deferred to post-release.
- **Effort:** L (multi-day — blocked on FINDING-02 partial resolution for clean testability)
- **Status:** OPEN

**Positive findings (no action needed):**
- `flutter_test` is already in `dev_dependencies` — scaffolding present.
- `flutter_lints ^5.0.0` present; lints will flag testability red flags once analyzer runs (paired with FINDING-08).
- Feature-first structure means per-feature test folders will be trivial to map (`test/features/auth/`, `test/features/scenario/`, etc. — matches `lib/features/*` exactly).
- `ScenarioCache` (FINDING-23 positive) is already written in a testable way (no Flutter framework dependency, pure Dart + `SharedPreferences` abstraction) — good first test target.

**Category summary:** ⚠️ **NEEDS_WORK** (not 🔴 because a team *can* ship without tests and many do for MVP). However, in combination with **FINDING-28** (no CI) and **FINDING-29** (no crash reporting), it forms a complete "flying blind" triad — no pre-release safety net (tests), no deployment safety net (CI), no post-release safety net (telemetry). Any *two* of these being resolved drastically changes the shipping risk. Prioritize FINDING-29 first (visibility post-release), then FINDING-28 (automation), then FINDING-27 (confidence before merge).

---

### Category 9 — CI/CD — ⚠️ NEEDS_WORK

**Scope:** Automated analyze / test / build on PRs, automated release to internal test tracks or production stores, signing key management, build reproducibility, deployment environment configuration.

**Inputs audited:**
- Files: `.github/**` (does not exist), `.gitlab-ci.yml`, `codemagic.yaml`, `bitrise.yml`, `.circleci/**`, `fastlane/**` — all checked for existence; none present.
- Tools run: `ls -la .github/ codemagic.yaml bitrise.yml .gitlab-ci.yml .circleci/ fastlane/ 2>/dev/null`, `git ls-files | grep -E "^\.(github|gitlab-ci|circleci)|^(codemagic|bitrise|fastlane)"`.
- Docs cross-referenced: FINDING-07 (Phase B already flagged CI/CD absence as a dependency-audit gap).

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| PR validation | `flutter analyze` + `flutter test` run on every PR; status required for merge. | No CI. | `MISSING` | HIGH |
| Build matrix | Android debug/release + iOS release builds validated in CI. | No CI. | `MISSING` | HIGH |
| Release pipeline | Tag → automated build → upload to Play Internal / TestFlight. | No pipeline. All releases would be from a developer laptop. | `MISSING` | HIGH |
| Signing key management | Keys stored in CI secret manager, rotated on incidents. | No pipeline → no secret manager. Signing keys currently implied-on-disk. | `MISSING` / fragile | MEDIUM (absorbed into FINDING-28) |
| Reproducibility | Pinned Flutter/Dart version (`.fvm/` or CI env var) + `pubspec.lock` committed. | `pubspec.lock` is committed (confirmed Phase B). No Flutter-version pinning mechanism (`.fvmrc`, `.tool-versions`, `fvm_config.json` absent). | partial / `MISSING` | MEDIUM (absorbed into FINDING-28) |

**Findings:**

#### FINDING-28: No CI/CD pipeline exists
- **Category:** 9
- **Severity:** HIGH
- **Gap type:** MISSING
- **Location:** Repository root (expected locations for CI config all absent).
- **Evidence:**
  ```
  $ ls -la .github/ 2>/dev/null
  (no such directory)
  $ ls codemagic.yaml bitrise.yml .gitlab-ci.yml 2>/dev/null
  (none exist)
  $ find . -maxdepth 3 \( -name ".circleci" -o -name "fastlane" \) -type d
  (no results)
  ```
  Git remote scan + `git ls-files` produce no CI manifest. There is literally no automation anywhere in the repo.
- **Impact:**
  - Every PR merges without an automated `flutter analyze` or `flutter test` run. Lint violations (FINDING-13) or test regressions (FINDING-27) slip through if the developer forgets to run locally.
  - No automated release pipeline means every release APK/IPA is built from a developer laptop, with that laptop's Flutter version, Dart version, toolchain, and signing config. Two developers building the same commit can produce different artifacts.
  - Signing keys are implicitly on one (or more) developer machines — bus factor = 1 at best, exposure risk if a laptop is compromised.
  - No enforcement point for FINDING-13 (lint rules), FINDING-27 (tests), or FINDING-29 (crash-reporting symbol upload) even after those are added. Having rules without enforcement lets them drift.
  - Cross-references the blockers: **FINDING-24** (key rotation) becomes operationally hard without CI → harder to rotate keys frequently → larger blast radius on leak. **FINDING-29** (Crashlytics dSYM/ProGuard upload) typically runs in CI post-build.
- **Remediation:** Minimum viable CI in a single commit:
  1. Create `.github/workflows/ci.yml`:
     ```yaml
     name: CI
     on: [pull_request, push]
     jobs:
       validate:
         runs-on: ubuntu-latest
         steps:
           - uses: actions/checkout@v4
           - uses: subosito/flutter-action@v2
             with: { flutter-version: '3.24.x', channel: 'stable' }
           - run: flutter pub get
           - run: flutter analyze --no-fatal-infos
           - run: flutter test
       build-android:
         runs-on: ubuntu-latest
         needs: validate
         steps:
           - uses: actions/checkout@v4
           - uses: subosito/flutter-action@v2
             with: { flutter-version: '3.24.x', channel: 'stable' }
           - run: flutter pub get
           - run: flutter build apk --debug
       build-ios:
         runs-on: macos-latest
         needs: validate
         steps:
           - uses: actions/checkout@v4
           - uses: subosito/flutter-action@v2
             with: { flutter-version: '3.24.x', channel: 'stable' }
           - run: flutter pub get
           - run: flutter build ios --no-codesign --debug
     ```
  2. Pin Flutter version: add `.fvmrc` (or commit `fvm_config.json`) with `{ "flutterSdkVersion": "3.24.x" }` and reference it from both local docs and the workflow — one source of truth.
  3. Add a release workflow (`.github/workflows/release.yml`) triggered on `v*` tags. Uses GitHub Secrets for Android keystore (`base64`-encoded) + `KEY_PASSWORD` + iOS App Store Connect API key. Output: signed APK + IPA uploaded as release artifacts, optionally to Play Internal Track and TestFlight via `fastlane`.
  4. Enforce: require `validate` status check before merging to `master` in repo branch protection rules.
- **Effort:** M (CI skeleton is small; release pipeline + signing + store API credentials add the bulk of time — can be split into two PRs)
- **Status:** OPEN

**Positive findings (no action needed):**
- `pubspec.lock` is committed (verified Phase B). Gives CI a deterministic resolution target once CI exists.
- Feature-first + clean structure means parallelized CI jobs (per-feature analyze/test) are trivial when coverage grows.
- No custom Gradle/Xcode hacks or platform-specific build scripts — the default Flutter toolchain is all that's needed, making CI setup unusually simple.

**Category summary:** ⚠️ **NEEDS_WORK**. FINDING-28 unblocks enforcement for FINDING-13 (lints), FINDING-27 (tests), FINDING-29 (symbol upload), and FINDING-24 (key-rotation release cadence). Highest leverage of the four Phase D categories per-hour-spent: one CI commit ships every other improvement's enforcement story for free.

---

### Category 10 — UI/UX — ⚠️ NEEDS_WORK

**Scope:** Design-system consistency, accessibility (Semantics, contrast, text scale), responsive layout, loading/empty/error states, animations/transitions, keyboard handling, dark mode, localization, system-UI integration.

**Inputs audited:**
- Files: `lib/core/theme/**` (9 files, 573 LOC), `lib/app.dart` (MaterialApp wiring), `lib/l10n/**` (auto-generated + arb files), all 9 `lib/features/*/screens/*_screen.dart`, representative `lib/shared/widgets/*` (21 widgets).
- Tools run: `grep -rn "Semantics\|semanticLabel\|MediaQuery\|LayoutBuilder\|OrientationBuilder\|SafeArea\|ThemeMode\|darkTheme\|textScaler\|AppLocalizations.of\|Text\('"`, `wc -l` on screens, manual read of `lib/app.dart`, `lib/core/theme/app_theme.dart`, `lib/l10n/app_localizations.dart`.
- Docs cross-referenced: project memory "Clay design" is the intended aesthetic; `docs/business-flow/aura-coach-mobile-business-flows-v2.md` for UX flow expectations.

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| Design-system tokenization | Colors/typography/radius/spacing/shadows extracted into tokens; theme extensions used for semantic layer. | ✅ Strong — `app_colors`, `app_typography`, `app_radius`, `app_spacing`, `app_shadows`, `app_semantic_colors` (as `ThemeExtension`). Clean separation. | OK | — |
| Component library | Shared, reusable widgets for the brand-specific vocabulary (Clay). | ✅ 21 widgets in `lib/shared/widgets/` (`ClayButton`, `ClayCard`, `ClayDialog`, `ClayBadge`, `ClayPressable`, shimmer, loading, celebration, etc.). Comprehensive vocabulary. | OK | — |
| Dark mode | `darkTheme` + `themeMode: ThemeMode.system` on MaterialApp. | ❌ `MaterialApp.router(... theme: AppTheme.light)` only. No `AppTheme.dark`, no `darkTheme`, no `themeMode`. `systemOverlayStyle: SystemUiOverlayStyle.dark` bakes in "expect light background" assumption. | `MISSING` | MEDIUM |
| Localization (runtime) | `localizationsDelegates` + `supportedLocales` wired; screens use `AppLocalizations.of(context).xxx`. | ❌ `lib/l10n/app_en.arb` + `app_vi.arb` exist, `AppLocalizations` code generated. But `MaterialApp.router` in `lib/app.dart:180-189` has **no** `localizationsDelegates` or `supportedLocales`. Only 1 usage of `AppLocalizations.of(context)` across all of `lib/`. Features hardcode English strings (24 `Text('...')` literals with capitalized phrases). | `IMPLEMENTED_NOT_USED` | MEDIUM |
| Accessibility | Semantic labels on non-text controls; text-scale safe layouts; reasonable contrast. | ❌ Only 3 `Semantics(...)` wrappers in all of `lib/` (`bottom_nav_bar.dart:78`, `clay_button.dart:76`, `clay_card.dart:46`). 29 `Icon(Icons.X)` calls, most without `semanticLabel`. Custom `ClayPressable`/`ClayBadge`/`ClayDialog` have no semantics. No `MediaQuery.textScalerOf` / clamp — large accessibility text scale will overflow Clay layouts. | `MISSING` | MEDIUM |
| Responsive / tablet | Breakpoints, `LayoutBuilder` for tablet layouts, or explicit phone-only declaration. | ❌ Zero `LayoutBuilder`, zero `OrientationBuilder`, zero breakpoint constants. `ios/Runner/Info.plist` declares all orientations for both iPhone and iPad (`UISupportedInterfaceOrientations~ipad` is permissive). App will run on iPad with phone-width UI, 700-LOC screens will look broken. | `MISSING` | LOW |
| Loading/empty/error UX | Consistent pattern per feature; user can distinguish error from empty. | Partial ✅. Each screen implements its own pattern: `home_screen` uses SnackBar, `my_library_screen` uses centered error widget with icon, `conversation_history_screen:185` collapses `_hasError` into `_buildEmptyState()` (loses the distinction). No shared `AsyncStateWidget`. | `INCONSISTENT` | LOW |
| Animations / transitions | Page transitions + micro-interactions appropriate to brand. | ✅ Strong — `lib/core/theme/page_transitions.dart` + 69 animation-related call sites across screens (`AnimationController`, `Hero`, `AnimatedContainer`, `CurvedAnimation`, `Tween`). Clay-feel physical animations carried through. | OK | — |
| Keyboard handling | `resizeToAvoidBottomInset`, `unfocus` on tap outside, appropriate `textInputAction`. | Only 1 hit across `lib/` for any of those patterns (vs. ≥8 text-input screens). Auth form / conversation chat likely miss tap-outside-unfocus. | `MISSING` (partial) | LOW (rolled into FINDING-34) |
| System UI | `systemOverlayStyle` and status-bar icons match theme. | Wired in `AppBarTheme` (good for screens with AppBar) but no `AnnotatedRegion` or `SystemChrome.setSystemUIOverlayStyle` for screens without AppBar (splash, onboarding full-screen screens). | `INCONSISTENT` | LOW (rolled into FINDING-34) |

**Findings:**

#### FINDING-30: Localization infrastructure exists but is not wired into `MaterialApp` and not used in screens
- **Category:** 10
- **Severity:** MEDIUM
- **Gap type:** IMPLEMENTED_NOT_USED
- **Location:** `lib/app.dart:180-189` (MaterialApp.router), `lib/l10n/app_en.arb`, `lib/l10n/app_vi.arb`, `lib/l10n/app_localizations*.dart`, feature screens with hardcoded strings.
- **Evidence:**
  ```dart
  // lib/app.dart:180-189 — MaterialApp wiring
  child: MaterialApp.router(
    title: 'Aura Coach AI',
    theme: AppTheme.light,
    routerConfig: _router,
    debugShowCheckedModeBanner: false,
  ),
  ```
  No `localizationsDelegates`, no `supportedLocales`. Even if a user's device locale is Vietnamese, Flutter has no way to resolve translated strings.
  ```
  $ grep -rln "AppLocalizations" lib/features/
  (no results)

  $ grep -rn "Text('" lib/ --include='*.dart' | wc -l
  24
  ```
  Feature code still hardcodes strings like:
  ```dart
  // lib/features/home/screens/home_screen.dart:88
  scenarioProvider.error ?? 'Could not start session. Try again.',
  ```
- **Impact:**
  - App ships English-only regardless of device locale. `app_vi.arb` content is dead weight in the binary.
  - Future localization work requires retrofitting every feature screen — same effort as if nothing existed. Current state is worse than starting from scratch because it gives a false signal that l10n is "already wired."
  - Vietnamese-speaking users (likely a significant audience for an English-learning app — note the VI arb file suggests intent to target VN market) see all UI in English, including error messages.
- **Remediation:**
  1. Add to `MaterialApp.router`:
     ```dart
     localizationsDelegates: AppLocalizations.localizationsDelegates,
     supportedLocales: AppLocalizations.supportedLocales,
     ```
     Also add `locale` resolution if the app should persist a user-selected language (via `SharedPreferences`).
  2. Add a `l10n.yaml` at repo root (`arb-dir: lib/l10n\noutput-dir: lib/l10n\ntemplate-arb-file: app_en.arb`) so `flutter pub get` regenerates `AppLocalizations` when arb files change.
  3. Sweep all 24 hardcoded `Text('...')` plus SnackBar/AlertDialog string literals into arb entries. Feature-by-feature migration is fine; at minimum, migrate error messages and button labels before release.
  4. Populate `app_vi.arb` — today it likely contains only the seed entries.
- **Effort:** M (arb migration is mostly mechanical but touches all 9 screens)
- **Status:** OPEN

#### FINDING-31: No dark mode support
- **Category:** 10
- **Severity:** MEDIUM
- **Gap type:** MISSING
- **Location:** `lib/core/theme/app_theme.dart:8-101`, `lib/app.dart:182-187`.
- **Evidence:**
  ```dart
  // lib/core/theme/app_theme.dart
  abstract final class AppTheme {
    static ThemeData get light => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      ...
      appBarTheme: AppBarTheme(
        ...
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Assumes light BG
      ),
      ...
    );
  }
  // No `static ThemeData get dark`
  ```
  `MaterialApp.router` uses only `theme: AppTheme.light`. No `darkTheme`, no `themeMode`.
- **Impact:**
  - Users with system dark mode (now the default on most modern phones) see a bright cream-colored app — jarring and can be flagged in App Store reviews.
  - iOS 13+ / Android 10+ dark-mode expectation is essentially baseline UX in 2026; shipping without it reads as "unfinished."
  - Not a release blocker for MVP, but will be the most-requested feature post-launch.
- **Remediation:** Define `AppTheme.dark` by duplicating the light theme and swapping `AppColors.cream`/`clayWhite`/`clayBeige` for dark equivalents. The existing token structure makes this straightforward:
  - Create a `AppColors.Dark` nested class or parallel tokens.
  - Make `AppSemanticColors` produce a `.dark` variant and register both in `extensions`.
  - Wire `MaterialApp.router(theme: AppTheme.light, darkTheme: AppTheme.dark, themeMode: ThemeMode.system)`.
  - Verify `systemOverlayStyle` per `Theme.of(context).brightness` inside `AppBarTheme`, or use `AnnotatedRegion` per screen.
- **Effort:** M (color-token duplication + visual QA pass on every screen)
- **Status:** OPEN

#### FINDING-32: Accessibility coverage is minimal — 3 Semantics wrappers across the entire app
- **Category:** 10
- **Severity:** MEDIUM
- **Gap type:** MISSING
- **Location:** All `lib/features/**` screens; most `lib/shared/widgets/` except `ClayButton`/`ClayCard`/`bottom_nav_bar`.
- **Evidence:**
  ```
  $ grep -rn "Semantics(\|semanticLabel:" lib/
  lib/features/home/widgets/bottom_nav_bar.dart:78:    return Semantics(
  lib/shared/widgets/clay_button.dart:76:    return Semantics(
  lib/shared/widgets/clay_card.dart:46:    return Semantics(

  $ grep -rn "Icon(Icons\." lib/ --include='*.dart' | wc -l
  29

  $ grep -rn "textScaler\|textScaleFactor" lib/
  (no results)
  ```
  Three positive cases, 29 icons largely unlabeled, zero text-scale protection. Interactive custom widgets — `ClayPressable`, `SelectableTextWithSave`, `SelectionCheckCircle`, `ProgressDots`, `SwipeDots` — do not announce role/state to screen readers.
- **Impact:**
  - App is unusable with VoiceOver/TalkBack. Custom-widget-heavy Clay design means the default Flutter semantic tree exposes only generic container labels.
  - Users who increase system text scale (common for low-vision users and many older users) will break Clay layouts: text overflows buttons, fixed-height cards clip, conversation bubbles become unreadable. `MaterialApp.builder` does not clamp `textScaler`, so a 2.0x user setting hits layouts designed for 1.0x.
  - Accessibility compliance obligations vary by jurisdiction (EU EAA takes effect June 2025; US Section 508 for any app used by federal employees). This is a post-launch legal risk rather than a pre-release blocker, but the gap is wide enough that remediation will be a multi-sprint effort.
- **Remediation:**
  1. Add `MaterialApp.builder` to clamp extreme text scales:
     ```dart
     builder: (context, child) => MediaQuery(
       data: MediaQuery.of(context).copyWith(
         textScaler: MediaQuery.textScalerOf(context).clamp(
           minScaleFactor: 1.0, maxScaleFactor: 1.4,
         ),
       ),
       child: child!,
     ),
     ```
     and visually regression-test each screen at 1.0x / 1.2x / 1.4x.
  2. For every `Icon(Icons.X)` called as a visual cue without adjacent text, pass `semanticLabel: '...'`.
  3. Wrap every `ClayPressable` with `Semantics(button: true, label: ..., child: ...)`. Do the same for `SelectionCheckCircle` (`checked`/`inMutuallyExclusiveGroup`).
  4. Verify with Flutter's "Show Semantics Debugger" DevTools overlay.
- **Effort:** M (wide touch, shallow per site)
- **Status:** OPEN

#### FINDING-33: No responsive / tablet layout handling; large screens likely break on iPad
- **Category:** 10
- **Severity:** LOW
- **Gap type:** MISSING
- **Location:** All screens + `ios/Runner/Info.plist:73-79` (`UISupportedInterfaceOrientations~ipad` permissive), `android/app/src/main/AndroidManifest.xml` (no `android:screenOrientation` restriction).
- **Evidence:**
  ```
  $ grep -rn "LayoutBuilder\|OrientationBuilder\|isTablet\|breakpoint" lib/ --include='*.dart'
  (no results)
  ```
  Info.plist allows iPad launch; AndroidManifest imposes no orientation restriction. 700-LOC screens (`conversation_history_screen.dart` 745 LOC, `my_library_screen.dart` 717 LOC) have no breakpoint paths — they scale phone-width layouts to tablet.
- **Impact:**
  - App passes iPad smoke test but the UX is essentially "iPhone on a big screen" — cards use full viewport width, tap targets look miniature on a 12.9" iPad Pro, Chat input bar stretches edge-to-edge.
  - If product positioning is phone-first, this is fine for MVP. If tablet is a meaningful market, this becomes HIGH later.
- **Remediation:** Decide product stance first. Two options:
  - **(a) Phone-only** — restrict to iPhone in Info.plist (`UIDeviceFamily = [1]`) and set `android:resizeableActivity="false"` / `android:screenOrientation="portrait"`. Closes the gap.
  - **(b) Responsive** — add `lib/core/responsive/breakpoints.dart` (phone <600dp, tablet 600-960, desktop 960+); retrofit 3-4 highest-traffic screens with `LayoutBuilder` branching. Scope 5-8 days.
- **Effort:** XS (option a) or L (option b)
- **Status:** OPEN

#### FINDING-34: Inconsistent error/empty/loading UX across features + gaps in keyboard handling and system UI
- **Category:** 10
- **Severity:** LOW
- **Gap type:** INCONSISTENT
- **Location:** `lib/features/scenario/screens/conversation_history_screen.dart:185-186`, `lib/features/home/screens/home_screen.dart:71-99`, `lib/features/my_library/screens/my_library_screen.dart:301-319`, `lib/features/scenario/screens/scenario_chat_screen.dart:143-148`, every full-screen screen without an AppBar.
- **Evidence:**
  - `conversation_history_screen.dart:185`: `if (_hasError || _allConversations == null) { return _buildEmptyState(); }` — error and "no data" render identically. User can't tell if the server is down or they have no history.
  - `home_screen.dart:85-99`: errors shown as SnackBar (transient, dismissed on navigation).
  - `my_library_screen.dart:308-319`: errors shown as full-screen widget with icon + message (best pattern in the app).
  - `scenario_chat_screen.dart:143-148`: generic "No scenario loaded" message conflates empty + error.
  - `grep -rn "unfocus\|FocusScope" lib/ --include='*.dart'` → 1 result vs. 5+ text-input-bearing screens. Tap-outside-unfocus is not a consistent pattern.
  - No `AnnotatedRegion<SystemUiOverlayStyle>` wrappers → status-bar icons can look wrong on full-bleed screens (splash, onboarding).
- **Impact:** Each broken-state UX is low-stakes in isolation, but the inconsistency makes polish work unpredictable (every new screen re-invents the pattern). Merging error into empty is the most user-hostile version — it mis-teaches users that the app is slow/empty when it's actually broken.
- **Remediation:** Introduce a shared `AsyncStateBuilder({loading, empty, error, data})` widget under `lib/shared/widgets/` that standardizes the three states. Use `my_library_screen.dart`'s pattern (centered icon + message + retry button) as the template. Retrofit the 4 sites above.
- **Effort:** S (1 widget + 4 site refactors)
- **Status:** OPEN

**Positive findings (no action needed):**
- **Design token system is the strongest UI/UX asset in the codebase.** `lib/core/theme/app_*.dart` cleanly separates colors, typography, radius, spacing, shadows, and semantic tokens (as `ThemeExtension<AppSemanticColors>`). Changing any design constant ripples through consistently.
- **Clay component library is comprehensive.** 21 widgets in `lib/shared/widgets/` cover buttons, cards, pressables, badges, dialogs, icons, loading, celebration, and scroll-behavior. New screens compose rather than re-implement.
- **`BouncingScrollBehavior`** applied at the app level (`app.dart:180-181`) gives iOS-style bounce on both platforms — aligns with Clay's "soft, physical" feel.
- **Page transitions** (`lib/core/theme/page_transitions.dart`) include a fade and a slide-fade, used across all routes. Consistent motion language.
- **SafeArea** used 8 times — notched/dynamic-island devices are considered.
- **Loading states present in every major feature** (55 `CircularProgressIndicator`/shimmer hits) — spinners/placeholders are not forgotten.

**Category summary:** ⚠️ **NEEDS_WORK**. No release blockers *in this category*, but three MEDIUMs (l10n unused, no dark mode, accessibility gap) all meaningfully affect first-impression UX for the 2026 market. The design-token layer (positive) is actually *ahead* of the l10n/dark-mode/a11y layers — fixing them is a consistent-pattern exercise, not a design-system rewrite. Recommend FINDING-30 + FINDING-32 ship together (both require per-screen passes) and FINDING-31 can be scheduled independently.

---

### Category 15 — Platform Integration — 🔴 BLOCKING_RELEASE

**Scope:** Android/iOS build configuration, signing, Firebase wiring, app naming + icons + launch screens (cold-start UX from the platform perspective), deep links / URL schemes, flavors / environments, version management, permissions, native code.

**Inputs audited:**
- Files: `android/app/build.gradle.kts`, `android/build.gradle.kts`, `android/settings.gradle.kts`, `android/gradle.properties`, `android/app/src/main/AndroidManifest.xml` (+ debug/profile variants, already read in Phase D), `android/app/src/main/res/drawable/launch_background.xml`, `android/app/src/main/res/mipmap-*/ic_launcher.png`, `android/app/src/main/kotlin/**/MainActivity.kt`, `android/app/google-services.json`, `ios/Runner.xcodeproj/project.pbxproj`, `ios/Runner/Info.plist`, `ios/Runner/AppDelegate.swift`, `ios/Runner/Base.lproj/LaunchScreen.storyboard`, `ios/Runner/Assets.xcassets/AppIcon.appiconset/*`, `ios/Runner/Assets.xcassets/LaunchImage.imageset/*`, `ios/Runner/GoogleService-Info.plist`, `lib/firebase_options.dart`.
- Tools run: `find android ios -name "build.gradle*"`, `identify` on mipmap icons, `ls -la` on icon directories, `grep -n "applicationId\|CFBundleDisplayName\|CFBundleName\|android:label\|signingConfig"`, `find` for flavor config + dart-define xcconfig, `grep -n "minifyEnabled\|shrinkResources\|proguard"`.
- Docs cross-referenced: Phase D manifests already read; `pubspec.yaml` (`version: 1.0.0+1`, `description: AI-powered English learning app with Clay Design System.`).

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| Release signing (Android) | Upload key in `keystore.properties`, loaded via gradle, referenced in `signingConfigs { release {...} }`; Play App Signing enrolled. | **`signingConfig = signingConfigs.getByName("debug")` for release.** TODO comment still in place. | `UNSAFE` / `MISSING` | **CRITICAL** |
| App display name | User-facing name on Android launcher and iOS home screen matches the brand. | Android: `android:label="aura_coach_ai"` → user sees lowercase-underscore raw id. iOS: `CFBundleDisplayName="Aura Coach Ai"` → odd capitalization. | `INCONSISTENT` | HIGH |
| Launch screens | Branded cold-start screen on both platforms. | Android: `launch_background.xml` is the default white-background stub with a commented-out image item. iOS: `LaunchImage.imageset` contains the default Flutter launch image and `README.md` is still the Flutter-create helper text. | `MISSING` | HIGH |
| App icons | Branded icons at every required density/size. | iOS icons 1KB–11KB suggest customized art. Android mipmap icons are 442 B – 1443 B — file sizes consistent with *default* `ic_launcher.png` from `flutter create`. Visual verification needed. | MAYBE `MISSING` | MEDIUM |
| Firebase wiring | `google-services.json` + `GoogleService-Info.plist` present; `firebase_options.dart` generated; package names match. | ✅ All present. `google-services.json` `package_name: com.auracoach.aura_coach_ai` matches Android `applicationId`. `firebase_options.dart` wired in `main.dart`. | OK | — |
| Bundle ID consistency | Android applicationId and iOS bundle identifier follow same convention. | Android: `com.auracoach.aura_coach_ai` (snake_case). iOS: `com.auracoach.auraCoachAi` (camelCase). Different strings. | `INCONSISTENT` | MEDIUM |
| Flavors / environments | Dev / staging / prod separation; per-env Firebase project and applicationId suffix; dart-defines for env-specific endpoints. | None. Single applicationId, single Firebase project, single `.env`. No dart-define, no flavor, no xcconfig environment split. | `MISSING` | MEDIUM |
| Version management | `pubspec.yaml` version semantically meaningful; CI bumps on release. | `version: 1.0.0+1` — legitimate starting version. No CI (see FINDING-28) so automated bumps don't happen. | rolled into FINDING-28 | — |
| Deep links | Android `<intent-filter>` with `android.intent.action.VIEW` + `https` scheme + `android:host`; iOS Associated Domains / Universal Links. | None for product links. Only `CFBundleURLSchemes` = reversed Google Sign-In client ID (required by OAuth). | `MISSING` | LOW (post-MVP concern) |
| Release optimization | R8 / ProGuard enabled on release; Dart obfuscation via `--obfuscate --split-debug-info`; symbol upload. | No `minifyEnabled`, no `shrinkResources`, no `proguard-rules.pro`. Dart obfuscation is a build flag (handled at CI time; ties into FINDING-28). | `MISSING` | LOW |
| Native platform code | `MainActivity.kt` + `AppDelegate.swift` clean, no leaked test code. | ✅ `MainActivity.kt` is a 1-line class extending `FlutterActivity`. `AppDelegate.swift` registers the implicit engine + calls super. No custom native code. | OK | — |
| Permissions | Release manifest declares minimum necessary. | Covered in Phase D (**FINDING-26**). | — | — |

**Findings:**

#### FINDING-35: Android release build is signed with the debug keystore
- **Category:** 15
- **Severity:** **CRITICAL**
- **Gap type:** UNSAFE / MISSING
- **Location:** `android/app/build.gradle.kts:36-42`
- **Evidence:**
  ```kotlin
  // android/app/build.gradle.kts
  buildTypes {
      release {
          // TODO: Add your own signing config for the release build.
          // Signing with the debug keys for now, so `flutter run --release` works.
          signingConfig = signingConfigs.getByName("debug")
      }
  }
  ```
  The release build type is explicitly using the debug signing config — this is the `flutter create` placeholder with its TODO still intact.
- **Impact:**
  - **Google Play rejects any APK / AAB signed with a debug key** — the upload is blocked at the Play Console. You literally cannot publish the app today.
  - Even if bypassed via sideloading or alternate stores, debug-signed builds fail many Play Integrity / Play Protect checks and are flagged as "developer build" on user devices.
  - If an accidental release-signed-with-debug APK is ever distributed to users (e.g. TestFlight equivalent on Android), migrating to a proper upload key later requires Play App Signing key reset — operationally painful.
- **Remediation:**
  1. Generate an upload keystore: `keytool -genkey -v -keystore ~/keystores/aura-coach-upload.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000`.
  2. Store credentials in `android/keystore.properties` (add to `.gitignore`) — schema:
     ```
     storePassword=...
     keyPassword=...
     keyAlias=upload
     storeFile=/Users/.../keystores/aura-coach-upload.jks
     ```
  3. Update `android/app/build.gradle.kts`:
     ```kotlin
     val keystoreProperties = Properties()
     val keystorePropertiesFile = rootProject.file("keystore.properties")
     if (keystorePropertiesFile.exists()) {
         keystoreProperties.load(FileInputStream(keystorePropertiesFile))
     }
     android {
         signingConfigs {
             create("release") {
                 storeFile = file(keystoreProperties["storeFile"] as String)
                 storePassword = keystoreProperties["storePassword"] as String
                 keyAlias = keystoreProperties["keyAlias"] as String
                 keyPassword = keystoreProperties["keyPassword"] as String
             }
         }
         buildTypes {
             release { signingConfig = signingConfigs.getByName("release") }
         }
     }
     ```
  4. When moving to CI (FINDING-28), pass credentials via GitHub Secrets (base64-encoded keystore + `KEY_PASSWORD` + `STORE_PASSWORD`).
  5. Enroll in **Play App Signing** at first Play Console upload — Google will generate and hold the app-signing key; your local keystore is only the upload key. This is the standard 2026 flow and decouples signing-key compromise from app-update ability.
- **Effort:** S (keystore generation + gradle wiring in one sitting; add CI secret wiring later)
- **Status:** OPEN — **BLOCKS RELEASE**

#### FINDING-36: Android displays `aura_coach_ai` as the app name; iOS display name has off-brand capitalization
- **Category:** 15
- **Severity:** HIGH
- **Gap type:** INCONSISTENT
- **Location:** `android/app/src/main/AndroidManifest.xml:3`, `ios/Runner/Info.plist:20-21`.
- **Evidence:**
  ```xml
  <!-- android/app/src/main/AndroidManifest.xml -->
  <application
      android:label="aura_coach_ai"
      ...
  ```
  ```xml
  <!-- ios/Runner/Info.plist -->
  <key>CFBundleDisplayName</key>
  <string>Aura Coach Ai</string>
  ```
  Android launcher shows the raw project identifier (`aura_coach_ai`). iOS home screen shows `Aura Coach Ai` (note `Ai`, not `AI`).
- **Impact:**
  - Every user's first post-install interaction is seeing the wrong app name on their home screen. For an AI product, having `AI` rendered as `Ai` reads as a QA miss.
  - Marketing screenshots, press kits, and store listings will contradict what shows on the device.
  - Cross-platform referral ("tell a friend — it's called Aura Coach AI") is broken because the discoverable name differs from the intended one.
- **Remediation:**
  1. Android: change `android:label="aura_coach_ai"` → `android:label="Aura Coach AI"` in `android/app/src/main/AndroidManifest.xml:3`. Optionally move to string resource `@string/app_name` in `res/values/strings.xml` for localization support.
  2. iOS: change `CFBundleDisplayName` in `ios/Runner/Info.plist:21` from `Aura Coach Ai` → `Aura Coach AI`. Also consider updating `CFBundleName` (currently `aura_coach_ai`) though that's less visible.
  3. Verify on both device types after build.
- **Effort:** XS
- **Status:** OPEN

#### FINDING-37: Default Flutter launch screens on both platforms
- **Category:** 15
- **Severity:** HIGH
- **Gap type:** MISSING
- **Location:** `android/app/src/main/res/drawable/launch_background.xml`, `ios/Runner/Base.lproj/LaunchScreen.storyboard` + `ios/Runner/Assets.xcassets/LaunchImage.imageset/*`.
- **Evidence:**
  Android `launch_background.xml`:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <!-- Modify this file to customize your launch splash screen -->
  <layer-list xmlns:android="http://schemas.android.com/apk/res/android">
      <item android:drawable="@android:color/white" />

      <!-- You can insert your own image assets here -->
      <!-- <item>
          <bitmap
              android:gravity="center"
              android:src="@mipmap/launch_image" />
      </item> -->
  </layer-list>
  ```
  → blank white screen, template comments unmodified.
  iOS `LaunchImage.imageset/README.md` still exists verbatim from `flutter create`:
  > `# Launch Screen Assets` / `You can customize the launch screen with your own desired assets...`
  → LaunchImage is still the default Flutter launch image (a generic Flutter logo or empty asset).
- **Impact:**
  - Cold-start UX is the most visible system moment. Every launch shows either a blank white screen (Android) or default Flutter asset (iOS) before the Dart engine boots and renders the `SplashScreen`. 1–3 seconds of unbranded/off-brand experience.
  - Feels amateurish in competitive comparison — most 2026 consumer apps have animated or at least branded launch screens (leveraging iOS 14+ `UILaunchScreen` dictionary or Android 12+ splashscreen API).
- **Remediation:**
  - **Android:** use the Android 12+ `SplashScreen` API via `androidx.core:core-splashscreen` (configure in `styles.xml` with `windowSplashScreenBackground` + `windowSplashScreenAnimatedIcon`). Alternatively, simpler route: replace the white color item in `launch_background.xml` with a drawable layer containing a brand-colored background + centered logo.
  - **iOS:** replace `LaunchImage@{1,2,3}x.png` in `Assets.xcassets/LaunchImage.imageset/` with branded assets at the correct pixel dimensions (320×480, 640×960, 960×1440 approximately for the legacy LaunchImage), OR migrate to the modern `UILaunchScreen` Info.plist dictionary approach (background color + image asset name). Delete the `README.md` after customizing.
  - Use `flutter_native_splash` package to generate both platforms' assets from a single source image.
- **Effort:** S (tool-driven generation + visual QA)
- **Status:** OPEN

#### FINDING-38: Android launcher icons are likely still the default Flutter `ic_launcher.png`
- **Category:** 15
- **Severity:** MEDIUM
- **Gap type:** MISSING (suspected)
- **Location:** `android/app/src/main/res/mipmap-{m,h,xh,xxh,xxxh}dpi/ic_launcher.png`
- **Evidence:** File sizes:
  ```
  mdpi     48x48    442 B
  hdpi              544 B
  xhdpi             721 B
  xxhdpi           1031 B
  xxxhdpi 192x192  1443 B
  ```
  These sizes match the default `flutter create` icons almost exactly. By contrast, iOS `Icon-App-1024x1024@1x.png` is 10,932 B which is consistent with a custom branded icon. Visual verification is the definitive check (open `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` in an image viewer).
- **Impact:**
  - If confirmed, Android users install the app and see a generic Flutter-logo icon on their home screen — same mistake as FINDING-36 but visually, not textually.
  - No Android adaptive-icon (`ic_launcher_background.xml` / `ic_launcher_foreground.xml`) files exist at all, so even if `ic_launcher.png` is customized, modern Android launchers using adaptive icons will fall back to a legacy shape.
- **Remediation:**
  1. Verify visually that `ic_launcher.png` is branded. If not, generate brand icons.
  2. Use `flutter_launcher_icons` package with a source 1024×1024 PNG to generate all densities + Android adaptive icon (foreground layer + background color) + iOS sizes in one command. Config lives in `pubspec.yaml`.
  3. Add `res/mipmap-anydpi-v26/ic_launcher.xml` with `<adaptive-icon>` referencing `drawable/ic_launcher_foreground` + `color/ic_launcher_background` for Android 8+ adaptive-icon compatibility.
- **Effort:** S
- **Status:** OPEN (needs visual verification to confirm)

#### FINDING-39: No flavors / environment separation — single Firebase project, single applicationId
- **Category:** 15
- **Severity:** MEDIUM
- **Gap type:** MISSING
- **Location:** `android/app/build.gradle.kts` (no `productFlavors { ... }` block), `ios/Flutter/*.xcconfig` (no per-env xcconfig), `lib/firebase_options.dart` (single environment).
- **Evidence:** `grep -n "productFlavors\|flavorDimensions" android/app/build.gradle.kts` → no match. `find . -name "*.env.*" -o -name "Dart-Define*.xcconfig"` → no match. `lib/firebase_options.dart` exposes one `DefaultFirebaseOptions.currentPlatform` object — no dev/staging variant.
- **Impact:**
  - All QA, internal testing, and exploratory builds hit production Firestore, production auth, production Gemini quota. There's no safe place to test destructive features (account deletion, conversation-wipe) or test migrations without risking real user data.
  - Analytics (once FINDING-29 resolved) will pool dev + QA + real-user events into one stream, making launch metrics noisy.
  - On-call incident response is harder: you can't A/B a fix in a staging env before rolling it out.
  - Common operational pain once the user base is non-trivial.
- **Remediation:** Introduce three flavors: `dev`, `staging`, `prod`.
  - **Android:** add `productFlavors { dev {...}; staging {...}; prod {...} }` with `applicationIdSuffix = ".dev"` / `.staging` in `android/app/build.gradle.kts`. Each flavor gets its own `google-services.json` via `flutterfire configure --project=<env-project>`.
  - **iOS:** create three xcconfigs (`Debug-Dev.xcconfig`, etc.) + three schemes. Per-scheme `PRODUCT_BUNDLE_IDENTIFIER` suffix + per-scheme `GoogleService-Info.plist` via a run-script phase.
  - **Dart:** load a per-env endpoint/feature-flag map via `--dart-define=FLAVOR=prod` and expose via a single `AppEnv` singleton. Supersedes `.env` reads at bootstrap.
  - Plays well with FINDING-28 (CI) — per-branch CI can build the matching flavor automatically.
- **Effort:** L (flavor scaffolding + Firebase-project creation + CI updates)
- **Status:** OPEN

#### FINDING-40: Android applicationId and iOS bundle identifier use inconsistent casing conventions
- **Category:** 15
- **Severity:** MEDIUM
- **Gap type:** INCONSISTENT
- **Location:** `android/app/build.gradle.kts:27` (`com.auracoach.aura_coach_ai`), `ios/Runner.xcodeproj/project.pbxproj` (`com.auracoach.auraCoachAi`).
- **Evidence:**
  ```
  Android:  com.auracoach.aura_coach_ai
  iOS:      com.auracoach.auraCoachAi
  ```
  Two different identifiers. Both legitimate per their respective platforms' rules, but they are *different strings*.
- **Impact:**
  - Cross-platform tooling that keys off the bundle identifier (deep-link routing, marketing attribution — AppsFlyer/Adjust, some analytics providers, React Native code sharing if ever added) requires per-platform configuration rather than a single `appId`.
  - Confusing for any future cross-platform work: Firebase Remote Config user property matching, App Check, App Attest — all must be configured twice with different IDs.
  - Minor but easy to fix at this stage. Becomes expensive once the app is published (changing Android applicationId means a fresh Play Store listing; changing iOS bundle ID means a fresh App Store record).
- **Remediation:** Normalize to one convention — recommended: `com.auracoach.auraCoachAi` on both sides (matches iOS convention; Android allows any valid Java-identifier-safe string). Change `applicationId` in `android/app/build.gradle.kts:27` and `namespace` at line 12 to match. **Do this before any production release** — afterward, changing Android applicationId forces a new Play Store listing.
- **Effort:** XS (config change + rebuild)
- **Status:** OPEN

#### FINDING-41: No R8 / ProGuard shrinking; Dart obfuscation not a build-script concern yet
- **Category:** 15
- **Severity:** LOW
- **Gap type:** MISSING
- **Location:** `android/app/build.gradle.kts` (no `minifyEnabled`/`shrinkResources` in release block), absence of `android/app/proguard-rules.pro`.
- **Evidence:** `grep -n "minifyEnabled\|shrinkResources\|proguard" android/app/build.gradle.kts` → no match. No `proguard-rules.pro` in `android/app/`.
- **Impact:** Release APK ships with unshrunk Kotlin code and unused Android resources. Negligible for this app (minimal Kotlin — just a 1-line `MainActivity`), but APK size is larger than necessary and any future native integration adds to the problem. Dart code is compiled AOT by Flutter and is separately obfuscated via `flutter build apk --obfuscate --split-debug-info=<path>` — this is a build-script concern (CI / FINDING-28), not a gradle concern.
- **Remediation:** Add to release block in `android/app/build.gradle.kts`:
  ```kotlin
  release {
      isMinifyEnabled = true
      isShrinkResources = true
      proguardFiles(
          getDefaultProguardFile("proguard-android-optimize.txt"),
          "proguard-rules.pro"
      )
      signingConfig = signingConfigs.getByName("release")
  }
  ```
  Create empty `android/app/proguard-rules.pro` and add Firebase/Gemini/Provider keeper rules if stripping breaks runtime reflection. Set Dart obfuscation as a CI flag: `flutter build apk --release --obfuscate --split-debug-info=build/symbols`. Upload symbols to Crashlytics (FINDING-29) for symbolication.
- **Effort:** XS
- **Status:** OPEN

**Positive findings (no action needed):**
- **Firebase wiring is solid.** `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) both present and reference the same project (`aura-coach-ai`, project number `649025183049`). `firebase_options.dart` is auto-generated via `flutterfire configure`, single source of truth, wired in `lib/main.dart` bootstrap.
- **Android `package_name` in `google-services.json` matches the Android `applicationId`** (`com.auracoach.aura_coach_ai`). This is a common misconfiguration pitfall that was avoided here.
- **Modern Android toolchain:** Gradle 8, Android Gradle Plugin 8.11.1, Kotlin 2.2.20, Java 17 target. All current for April 2026.
- **Native platform code is clean.** `MainActivity.kt` is a 1-line class; `AppDelegate.swift` correctly uses the newer `FlutterImplicitEngineDelegate` path. No custom native code to audit — the surface is minimal.
- **iOS icons appear branded** — `Icon-App-1024x1024@1x.png` is 10,932 B which is consistent with real artwork (vs. the 442-1443 B Android mipmaps which look default). All required iOS icon sizes are present in `AppIcon.appiconset`.
- **Bundle identifier reverse-DNS is clean** (`com.auracoach.*` — not the `com.example.*` default). Domain ownership aligns.
- **`pubspec.yaml`** description is real (`"AI-powered English learning app with Clay Design System."`) — not the `flutter create` boilerplate. Version `1.0.0+1` is a reasonable starting point.
- **No custom native code surface** means no iOS/Android code review scope beyond config — the risk envelope is small.

**Category summary:** 🔴 **BLOCKING_RELEASE**. **FINDING-35 (debug signing) is a hard Play-Store blocker** — in the current state, you cannot upload the APK. After that, FINDING-36 + FINDING-37 together fix the "looks like a Flutter demo app" cold-start impression. FINDING-39 (flavors) is tempting to defer but the cost rises sharply post-launch. Strong positives on Firebase wiring and clean native code surface offset the config-level gaps.

---

## 9. Checkpoint 3 — Final Verdict & Remediation Roadmap

### 9.1 Final verdict

🔴 **`BLOCKING_RELEASE`** — **3 CRITICAL + 7 HIGH findings** must be addressed before shipping. This is not a borderline call. Two of the blockers are operational ones (debug signing, API-key bundle) where the alternative is literally "can't publish" or "publish a key". The third (zero observability) is the one you'd regret inside the first week of any non-trivial userbase.

The encouraging counter-signal: the **product-shaped** parts of the codebase — architecture *intent*, design-system tokens, Clay component library, scenario offline fallback, Firestore security rules, modern native toolchain, retry/backoff on Gemini — are solid. The blocker-dense parts are **release plumbing** (signing, secrets pipeline, telemetry, CI, branding polish, tests). Plumbing is fixable in weeks, not months. Nothing found in this audit requires a rewrite.

### 9.2 Totals — final

| Severity | Count | % |
|---|---|---|
| CRITICAL | 3 | 7% |
| HIGH | 7 | 17% |
| MEDIUM | 19 | 46% |
| LOW | 12 | 29% |
| **Total** | **41** | 100% |

### 9.3 Release Blockers — final list

| # | Finding | Category | Severity | Min fix summary |
|---|---------|----------|----------|-----------------|
| 1 | FINDING-24 | 6 Security | CRITICAL | Move Gemini calls behind Cloud Function; rotate key; remove `.env` from assets. |
| 2 | FINDING-29 | 11 Logging | CRITICAL | Add Crashlytics + Analytics; wire `runZonedGuarded` + `FlutterError.onError`; retrofit 10 empty catches from FINDING-12. |
| 3 | FINDING-35 | 15 Platform | CRITICAL | Generate upload keystore; wire gradle signing config; enroll Play App Signing. |

### 9.4 Prioritized remediation roadmap

**Tier 0 — Pre-release blockers (MUST fix before any public build).** Order is suggested; 0a and 0c can parallelize.

| Order | Finding(s) | Scope | Effort | Rationale |
|-------|-----------|-------|--------|-----------|
| 0a | FINDING-29 | Crashlytics + Analytics wiring + retrofit 10 empty catches (FINDING-12) | M (~2 days) | Visibility first — if 0b or 0c regresses, you'll see it. Also collapses FINDING-12/14/15/19 severity chain. |
| 0b | FINDING-24 | Cloud Function proxy for Gemini; remove `.env` from assets; rotate key | M (~2–3 days) | Close the extraction vector. Non-reversible — every day shipped is another day the key could leak. |
| 0c | FINDING-35 + FINDING-36 + FINDING-37 | Release keystore wiring + fix app name + branded launch screens | S (~1 day combined) | Without 0c you literally can't upload; 36/37 fix the "looks like a demo" first-install impression. Cheap to do while 0a/0b are in flight. |

**Tier 1 — Ship-adjacent HIGHs (fix before or immediately after first release).**

| Order | Finding(s) | Scope | Effort | Rationale |
|-------|-----------|-------|--------|-----------|
| 1a | FINDING-28 | Minimum CI (`ci.yml` with analyze + test + build) | M (~1 day) | Enforces everything else; upload Crashlytics symbols post-build; blocks bad merges. |
| 1b | FINDING-27 | Minimum test suite (auth + scenario + onboarding + one integration smoke) | L (~3–5 days) | Blocked on 1c for clean testability. |
| 1c | FINDING-01 + FINDING-02 (partial) | Introduce `AuthRepository` / `ConversationRepository` / `UsageRepository` interfaces; migrate the 3 highest-risk providers | M (~2–3 days) | Unblocks 1b. Does not require full domain layer. |
| 1d | FINDING-12 (remaining) | Finish retrofitting any empty catches not covered by 0a | S | Tail end of silent-error chain. |

**Tier 2 — Next-release MEDIUMs (ship in v1.1 or v1.2).**

Logical pairs/trios to bundle:
- **Backgrounding + offline triad:** FINDING-16 + FINDING-21 + FINDING-22. Ship together (see Cross-Cutting #4).
- **Onboarding state unification:** FINDING-03 + FINDING-14 + FINDING-15. Resolve state-of-truth first, offline re-onboarding symptom auto-reduces.
- **Fire-and-forget writes:** FINDING-19. Once FINDING-29 is live, you'll have telemetry to judge whether the Firestore SDK's default retry is sufficient.
- **Documentation pass:** FINDING-09 (README) + FINDING-10 (ARCHITECTURE.md) + FINDING-25 (`.env.example`). Natural single-PR bundle.
- **Platform polish:** FINDING-26 (release manifest permissions) + FINDING-38 (icons) + FINDING-40 (bundle ID normalization). **Do FINDING-40 before the v1.0 store submission** — cost rises sharply after publication.
- **Environment separation:** FINDING-39 (flavors). Ideally before v1.1, definitely before opening to external beta.
- **Code quality:** FINDING-05 (file size refactors) + FINDING-06 (unused deps) + FINDING-18 (dead Lottie widget). Tech-debt PR.
- **UX polish:** FINDING-30 (l10n wire-up) + FINDING-31 (dark mode) + FINDING-32 (accessibility). Three independent MEDIUMs — schedule across 2–3 sprints.

**Tier 3 — Polish / backlog LOWs.**

- FINDING-04 (app.dart SRP), FINDING-08 (deferred `pub outdated`), FINDING-11 (`.DS_Store` cleanup), FINDING-13 (lint strictness), FINDING-17 (`Selector` adoption), FINDING-20 (retry tuning), FINDING-23 (expand offline cache), FINDING-33 (tablet layout), FINDING-34 (state UX consistency), FINDING-41 (R8/ProGuard). Ship as capacity allows.

### 9.5 Go / No-Go release checklist

**Required (all three must be "Done" before submitting to Play Store / App Store):**
- [ ] **FINDING-24 resolved** — Gemini calls go through backend proxy; `.env` removed from `pubspec.yaml` assets; key rotated in Google AI Studio.
- [ ] **FINDING-29 resolved** — Crashlytics + Analytics live in release build; tested by manually throwing in a non-critical code path and confirming crash appears in Crashlytics console within 15 minutes.
- [ ] **FINDING-35 resolved** — release APK/AAB signed with upload keystore; Play App Signing enrolled; build uploadable to Play Console.

**Strongly recommended (don't ship v1.0 without):**
- [ ] FINDING-36 (app name corrected on both platforms)
- [ ] FINDING-37 (launch screens branded — or at minimum not default Flutter)
- [ ] FINDING-28 (minimum CI green on main)
- [ ] FINDING-40 (bundle ID normalized — **must happen before first store upload**)

**Verification gate — re-run locally on a clean checkout before submitting:**
- [ ] `flutter analyze --no-fatal-infos` → 0 errors, 0 warnings
- [ ] `flutter test` → all tests pass (even if minimal)
- [ ] `flutter build apk --release --obfuscate --split-debug-info=build/symbols` → succeeds, produces signed APK
- [ ] `flutter build ipa --release --obfuscate --split-debug-info=build/symbols` → succeeds
- [ ] Install release APK on a real Android device → launcher shows "Aura Coach AI" + branded icon; cold-start shows branded launch screen; sign up, start a conversation, force-close, reopen, see history.
- [ ] Verify no Gemini API key string appears in `unzip app-release.apk flutter_assets/` output.
- [ ] Trigger a non-fatal error intentionally → confirm it lands in Crashlytics + Analytics console.

### 9.6 Cross-cutting themes — final synthesis

The audit surfaced **41 findings**, but they clustered into just **7 systemic themes**:

1. **Architecture coupling → blocks testing.** (FINDING-01, 02 → 27)
2. **Silent-error chain → blocks observability.** (FINDING-12 → 14, 15, 19 → 29)
3. **Missing safety-net triad.** (FINDING-27 tests + FINDING-28 CI + FINDING-29 telemetry)
4. **Backgrounding + offline + write-queue unity.** (FINDING-16 + 21 + 22)
5. **Dead-code artifacts.** (FINDING-06 + 18)
6. **Security posture bimodality.** Strong where the team thought about it (Firestore rules, token storage), weak where the default worked (client-side AI key, debug signing, release manifest). (FINDING-24, 26, 35)
7. **Release-plumbing gap.** Branding, signing, flavors, store-readiness artifacts all underdone while product code is mature. (FINDING-35, 36, 37, 38, 39, 40, 41)

**The most important observation across the audit:** *product logic is ahead of release plumbing*. This is the opposite of most failed launches (where release mechanics work fine but product is broken). It means the fix is linear, well-scoped, and doesn't risk regressing the hard-won product work. Fix the three CRITICAL blockers and Tier 1 safety net, and this codebase is shippable.

---

---

## 5. Cross-Cutting Concerns

**Final — updated through Phase E (all 16 categories):**

1. **Data-layer coupling pervades the feature tree.** FINDING-01 + FINDING-02 together affect all 5 feature providers and **directly block FINDING-27 (testing)** — unit-testing a `ChangeNotifier` that imports `firebase_auth` and `cloud_firestore` without interface abstraction is impossibly painful. Treat architecture + testing as one workstream. Recommended first move: introduce `AuthRepository`, `ConversationRepository`, `UsageRepository` interfaces; migrate providers to depend on those; tests follow.
2. **Absence of CI/CD infrastructure — confirmed as FINDING-28.** First surfaced in FINDING-07 (Phase B dependency audit), re-surfaces as the enforcement gap for FINDING-13 (lints), FINDING-27 (tests), FINDING-29 (Crashlytics symbol upload), and FINDING-35 (release signing — automated `keystore.properties` injection needs a CI secret store). One CI manifest unblocks automation for all of them.
3. **Silent-error chain is fully mapped.** FINDING-12 (Cat 2 — code-quality root cause) → FINDING-14 (Cat 12 — state drift) → FINDING-15 (Cat 13 — offline re-onboarding) → FINDING-19 (Cat 5 — fire-and-forget Firestore drops) → **FINDING-29 (Cat 11 — no observability prong)** → FINDING-34 (Cat 10 — collapses errors into empty-state UI, e.g. `conversation_history_screen.dart:185` `if (_hasError || _allConversations == null)` branch). **Remediation order:** FINDING-29 → FINDING-13 → FINDING-12 → FINDING-14 → FINDING-15/19/34 auto-reduce.
4. **Backgrounding + offline + write-queue are one story, not three.** FINDING-16 (no `AppLifecycleState`), FINDING-21 (no connectivity detection), and FINDING-22 (no write-replay queue) together form the "conversation disappeared" failure mode. All three must ship together for the story to be coherent: pause → flush, offline → cache, reconnect → drain.
5. **Dead-code artifacts in two packages.** FINDING-06 (`sign_in_with_apple` declared but unused) and FINDING-18 (`lottie` imported wrapper but never consumed) are structurally identical. Pre-release cleanup should tackle them together.
6. **The "flying blind" triad.** FINDING-27 (no tests) + FINDING-28 (no CI) + FINDING-29 (no telemetry) = no safety net before, during, or after release. Ordering that maximizes leverage: FINDING-29 first (~1 day, makes every other bug discoverable and is half a blocker itself) → FINDING-28 (~1 day, enforcement point for lints + tests + dSYM upload) → FINDING-27 (multi-day; blocked on partial FINDING-02).
7. **Security posture is bimodal, not uniformly bad.** `firestore.rules` (strong), Firebase Auth token storage (strong), .env git hygiene (strong), iOS `Info.plist` minimality (strong) demonstrate security-aware engineering. The failure is specifically client-side AI-key handling (FINDING-24) and release-signing defaults (FINDING-35) — patterns Google's own docs warn against. Fix is well-scoped: a single backend proxy + a keystore don't require re-architecting anything.
8. **Release-plumbing gap (synthesized from Phase E).** Branding (FINDING-36, FINDING-37, FINDING-38), signing (FINDING-35), flavors/env separation (FINDING-39), bundle-ID normalization (FINDING-40), and shrinking (FINDING-41) are all underdone while product code is mature. This is the **opposite** of most failed launches — product is ahead of release mechanics, not behind. Everything in this cluster is S-to-M effort and can be bundled into ~2 "release polish" PRs. **FINDING-40 (bundle-ID casing) must be fixed *before* first store upload** — cost of changing after publication is very high on both platforms.
9. **Localization is wired but unused (Phase E surface).** FINDING-30 shows the full i18n toolchain (`.arb` files, generated `AppLocalizations`, `pubspec.yaml: generate: true`) is in place but `MaterialApp.router` is missing `localizationsDelegates`/`supportedLocales` and only 1 screen actually calls `AppLocalizations.of(context)`. Vietnamese users see English. The cost to unlock VN is ~1 day of mechanical replacement once the MaterialApp wiring is done — disproportionate value for the effort.

**Final observation across the audit:** *product logic is ahead of release plumbing*. This is the opposite of most failed launches (where release mechanics work fine but product is broken). It means the fix path is linear and well-scoped, and doesn't risk regressing hard-won product work. Fix the three CRITICAL blockers (Tier 0) and the Tier 1 safety-net + branding bundle, and this codebase is shippable — see **Section 9.4 Prioritized remediation roadmap** for the sequenced plan and **Section 9.5 Go/No-Go release checklist** for the verification gate.

---

## 6. Appendix A — Tooling Commands Used

Commands executed in the audit sandbox (all shell grep/find; no `flutter`/`dart` available):

```bash
# Structure & sizes
find lib -type f -name "*.dart" | wc -l
find lib -name "*.dart" -exec wc -l {} + | sort -rn | head -20
find lib -maxdepth 3 -type d | sort

# Layer coupling
grep -rn "import.*'\.\./\.\./\.\./data/" lib/features --include="*.dart"
grep -rln "extends ChangeNotifier\|with ChangeNotifier" lib --include="*.dart"
grep -n "ChangeNotifierProvider\|MultiProvider\|Provider<" lib/main.dart lib/app.dart

# Deps usage
for pkg in firebase_core firebase_auth cloud_firestore google_sign_in sign_in_with_apple provider go_router shared_preferences cached_network_image google_fonts uuid intl google_generative_ai flutter_dotenv flutter_tts shimmer lottie; do
  count=$(grep -rh "^import 'package:$pkg" lib --include="*.dart" 2>/dev/null | wc -l)
  echo "$pkg: $count files"
done

# Git state
git rev-parse HEAD
git status --short
git ls-files | grep -E "^\.env$"

# Docs presence
find . -maxdepth 3 -iname "CLAUDE.md" -o -iname "CONTRIBUTING*" -o -iname "ARCHITECTURE*"

# Phase D — Security / Observability / Testing / CI scans
grep -rn "dotenv\|API_KEY\|apiKey" lib/
grep -rn "crashlytics\|sentry\|firebase_analytics" pubspec.yaml lib/
grep -rn "FlutterError.onError\|runZonedGuarded\|ErrorWidget.builder" lib/
grep -rn "speech_to_text\|microphone\|RECORD_AUDIO\|NSMicrophone" lib/ pubspec.yaml
find test integration_test -type f 2>/dev/null
ls .github/ codemagic.yaml bitrise.yml .gitlab-ci.yml .circleci/ fastlane/ 2>/dev/null
cat firestore.rules
cat android/app/src/main/AndroidManifest.xml android/app/src/debug/AndroidManifest.xml ios/Runner/Info.plist
```

**Commands NOT run (unavailable in sandbox, deferred to user local):**

```bash
flutter analyze --no-fatal-infos
flutter pub outdated --show-all --mode=null-safety
flutter pub deps --style=tree
flutter test --coverage
dart fix --dry-run
```

---

## 7. Appendix B — Out-of-Scope

Explicitly NOT covered by this audit:

1. Runtime penetration testing — only static code review.
2. Load / stress testing — no perf benchmarks run.
3. Native Android/iOS code beyond config files (`android/app/build.gradle`, `ios/Runner/Info.plist`, `AndroidManifest.xml`). Custom Swift/Kotlin code (if any) not deep-audited.
4. Backend Firestore Cloud Functions and services outside this repo. `firestore.rules` was audited in Category 6 Security (Phase D) — positive finding, no issues.
5. Runtime accessibility audit with real screen readers — only code-level `Semantics` coverage evaluated.
6. Localization string completeness — only i18n infrastructure audited; individual ARB strings not lint-checked.
7. Device-farm testing across physical devices.
8. Golden tests, visual regression, snapshot tests — only Testing category #7 checks presence/absence of test infrastructure.
9. Third-party service SLAs (Firebase, Google AI Studio, Cloudinary).

---

## 8. Appendix C — Glossary

### Severity (pre-release lens)

| Level | Meaning |
|-------|---------|
| `CRITICAL` | Ship blocker. Examples: secret in repo, no crash reporting, auth token in SharedPreferences, missing error handling on payment/auth API, business-logic bug corrupting user data. |
| `HIGH` | Ship possible but incident likely within first weeks. Examples: dispose leak, no retry/timeout on network, permissive Firestore rules, missing offline fallback for core flow. |
| `MEDIUM` | Tech debt to address next release. Examples: widget rebuild hotspot, naming inconsistency, deps >1 major behind. |
| `LOW` | Polish. Examples: dead code, redundant comments, minor folder restructure. |

### Gap type

| Value | Meaning |
|-------|---------|
| `MISSING` | Feature, safety net, or infra does not exist |
| `IMPLEMENTED_NOT_USED` | Code exists but has no callers |
| `INCONSISTENT` | Same concern implemented multiple ways |
| `ANTI_PATTERN` | Wrong pattern used (e.g. `setState` after `dispose`) |
| `LEAK` | Resource not released |
| `UNSAFE` | Security or privacy concern |
| `OUTDATED` | Dep / API retired or deprecated |
| `UNCOVERED` | Missing test coverage on critical flow |

### Status emoji (per-category)

| Emoji | Meaning |
|-------|---------|
| `✅ OK` | No findings, or only LOW |
| `⚠️ NEEDS_WORK` | ≥1 MEDIUM or HIGH, 0 CRITICAL |
| `🔴 BLOCKING_RELEASE` | ≥1 CRITICAL |
| `➖ N/A` | Category doesn't apply to this project |

### Effort

| Value | Guideline |
|-------|-----------|
| `XS` | <1 hour |
| `S` | 1–4 hours |
| `M` | 4–16 hours (≈1/2 day – 2 days) |
| `L` | >16 hours (multi-day) |
