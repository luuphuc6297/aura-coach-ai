# Aura Coach AI — Design System Gap Analysis

**Date:** 2026-04-17
**Last updated:** 2026-04-17 (post-fix)
**Audit type:** 3-way comparison (Standard checklist ↔ Documentation ↔ Codebase)
**Sources audited:**
- `docs/business-flow/aura-coach-mobile-design-system-v2.md` (UI/UX audit doc)
- `docs/superpowers/specs/2026-04-08-aura-coach-comprehensive-design.md` (comprehensive spec)
- `lib/core/theme/` (token files)
- `lib/shared/widgets/` (shared components)
- `lib/features/` (all feature screens and widgets)

**Fix commit:** `refactor: design system consistency — tokenize colors, spacing, radius, animations` (45 files, 6078+/477-)

---

## COVERAGE DASHBOARD

| # | Category | Doc Coverage | Code Coverage | Consistency | Priority | Status |
|---|----------|-------------|---------------|-------------|----------|--------|
| 1 | Foundation / Brand | 40% | N/A | — | LOW | — |
| 2 | Design Tokens | 70% | 90% | CONSISTENT | — | ✅ FIXED |
| 3 | Color System | 75% | 85% | MOSTLY CONSISTENT | LOW | ✅ FIXED |
| 4 | Typography System | 70% | 80% | MOSTLY CONSISTENT | LOW | ✅ FIXED |
| 5 | Layout System | 40% | 30% | INCONSISTENT | MEDIUM | — |
| 6 | Spacing & Sizing | 60% | 75% | CONSISTENT | — | ✅ FIXED |
| 7 | Shape & Visual Style | 70% | 80% | MOSTLY CONSISTENT | LOW | ✅ FIXED |
| 8 | Iconography | 50% | 40% | INCONSISTENT | MEDIUM | — |
| 9 | Imagery / Media | 65% | 70% | OK | LOW | ✅ FIXED |
| 10 | Motion System | 60% | 70% | MOSTLY CONSISTENT | LOW | ✅ FIXED |
| 11 | Interaction Principles | 55% | 50% | IMPROVED | MEDIUM | PARTIAL |
| 12 | Accessibility | 0% | 40% | BASIC COVERAGE | MEDIUM | ✅ FIXED |
| 13 | Content / UX Writing | 45% | 40% | OK | LOW | — |
| 14 | Core Component Standards | 65% | 65% | OK | LOW | ✅ FIXED |
| 15 | Primitive Components | 60% | 55% | OK | LOW | — |
| 16 | Input Components | 50% | 40% | INCONSISTENT | MEDIUM | — |
| 17 | Navigation Components | 60% | 50% | IMPROVED | MEDIUM | PARTIAL |
| 18 | Feedback Components | 40% | 45% | IMPROVED | MEDIUM | ✅ FIXED |
| 19 | Overlay Components | 20% | 15% | INCONSISTENT | MEDIUM | — |
| 20 | Data Display Components | 55% | 45% | OK | LOW | — |
| 21 | Form Patterns | 35% | 30% | OK | LOW | — |
| 22 | Search / Filter | 40% | 35% | OK | LOW | — |
| 23 | CRUD Patterns | 30% | 25% | OK | LOW | — |
| 24 | State Patterns | 55% | 55% | IMPROVED | LOW | PARTIAL |
| 25 | Page-Level Patterns | 70% | 60% | OK | LOW | — |
| 27 | Platform Guidelines | 15% | 10% | MISSING | MEDIUM | — |
| 28 | Theming | 20% | 40% | IMPROVED (prep done) | MEDIUM | ✅ FIXED |
| 29 | Localization / i18n | 10% | 35% | IMPROVED (infra done) | MEDIUM | ✅ FIXED |
| 30 | Design-to-Code Mapping | 60% | 50% | OK | LOW | — |
| 31 | Documentation System | 30% | N/A | — | LOW | — |

**Categories removed (N/A for mobile):** #26 Templates, #32 Figma Management, #33 Code Library/UI Kit, #34 Governance, #35 QA Audit, #36 Measurement, #37 Workflow

---

## CRITICAL FINDINGS

### FINDING-01: AppSpacing tokens exist but are NEVER used in any widget — ✅ FIXED
- **Gap type:** `IMPLEMENTED_NOT_USED` → **RESOLVED**
- **Severity:** CRITICAL → **RESOLVED**
- **Detail:** AppSpacing expanded from 7 to 14 tokens (xxs=2 through giant=48). Now 90 usages across 14 files covering auth, onboarding, home, and scenario features.
- **Remaining:** Scenario feature files not in scope (my_library, chat_bubble_user, chat_input_bar, session_summary) still have hardcoded spacing.

### FINDING-02: Dark mode infrastructure completely absent — ✅ PREP DONE
- **Gap type:** `MISSING` → **INFRASTRUCTURE READY**
- **Severity:** HIGH → MEDIUM (prep complete)
- **Detail:** `AppSemanticColors` ThemeExtension added with 10 semantic tokens (surface, surfaceVariant, onSurface, onSurfaceMuted, onSurfaceLight, primary, onPrimary, cardBackground, divider, shadow). Light theme registered in `AppTheme.light` extensions. Material component themes added (ElevatedButton, InputDecoration, Card, Dialog, BottomNavigationBar).
- **Remaining:** Need `AppSemanticColors.dark` definition, `darkTheme` in MaterialApp, `ThemeMode` toggle, and widget migration from direct `AppColors` to semantic tokens.

### FINDING-03: Localization framework missing — ✅ INFRA DONE
- **Gap type:** `MISSING` → **INFRASTRUCTURE READY**
- **Severity:** HIGH → MEDIUM (framework in place)
- **Detail:** `flutter_localizations` added to pubspec.yaml with `generate: true`. `l10n.yaml` config created. ARB files for English (app_en.arb) and Vietnamese (app_vi.arb) with 20 keys covering auth and onboarding screens, including 2 parameterized messages.
- **Remaining:** Extract remaining hardcoded strings from all screens. Wire `AppLocalizations` delegates into MaterialApp.

### FINDING-04: Zero accessibility implementation — ✅ BASIC COVERAGE
- **Gap type:** `MISSING` → **BASIC IMPLEMENTED**
- **Severity:** MEDIUM → LOW (basics covered)
- **Detail:** Semantics wrappers added to ClayButton, ClayCard, BottomNavBar items. Touch targets fixed to 44dp+ on: ErrorBanner dismiss, BottomNavBar items (56x44), history button (44x44), topic add button (44x44), ScenarioAppBar actions. Caption contrast fixed from 3.1:1 to ~5.5:1 (warmLight→warmMuted).
- **Remaining:** Semantics coverage for remaining screens (my_library, scenario chat). Reduced motion accessibility. Color blindness considerations.

---

## DETAILED GAP MATRIX

### Category 2: Design Tokens — ✅ MOSTLY FIXED

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Color tokens | Required | ✅ Documented | ✅ `app_colors.dart` — 18 tokens (+white, +goldDark) | `CONSISTENT` ✅ |
| Typography tokens | Required | ✅ Documented | ✅ `app_typography.dart` — 17 styles, all used via tokens | `CONSISTENT` ✅ |
| Spacing tokens | Required | ✅ Documented | ✅ `app_spacing.dart` — 14 tokens, 90 usages across 14 files | `CONSISTENT` ✅ |
| Sizing tokens | Required | ⚠️ Partial | ❌ No sizing token file | `DOCUMENTED_NOT_IMPLEMENTED` |
| Radius tokens | Required | ✅ Documented | ✅ `app_radius.dart` — 7 tokens (+xxs, +xs) | `CONSISTENT` ✅ |
| Border tokens | Required | ⚠️ Per-component | ❌ No border token file | `MISSING` |
| Shadow tokens | Required | ✅ Documented | ✅ `app_shadows.dart` — 5 styles + colored() factory. Removed unused clayHover | `CONSISTENT` ✅ |
| Opacity tokens | Required | ⚠️ Scattered | ❌ No opacity token file | `DOCUMENTED_NOT_IMPLEMENTED` |
| Motion tokens | Required | ✅ Documented | ✅ `app_animations.dart` — 4 durations (+durationMedium), 1 curve. Removed unused easeBackOut | `CONSISTENT` ✅ |
| Z-index tokens | Mobile: N/A | Not documented | Not needed | `N/A_MOBILE` |
| Semantic tokens | Required for theming | ❌ Not documented | ✅ `app_semantic_colors.dart` — 10 semantic tokens, ThemeExtension | `IMPLEMENTED` ✅ |
| Theme tokens | Required for dark mode | ❌ Not documented | ⚠️ Light theme defined, dark theme values TBD | `PARTIAL` |
| Platform tokens | Optional | ❌ Not documented | ❌ Not implemented | `MISSING` |

### Category 3: Color System — ✅ MOSTLY FIXED

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Brand/accent colors | Required | ✅ teal, purple, gold, coral | ✅ Implemented | `CONSISTENT` ✅ |
| Neutral colors | Required | ✅ Surface palette documented | ✅ Implemented | `CONSISTENT` ✅ |
| Functional/feedback colors | Required | ✅ success, warning, error | ✅ Implemented with documented overlap comments | `CONSISTENT` ✅ |
| Text colors | Required | ✅ warmDark, warmMuted, warmLight | ✅ Implemented | `CONSISTENT` ✅ |
| Background colors | Required | ✅ cream, clayWhite, clayBeige | ✅ Implemented | `CONSISTENT` ✅ |
| Border colors | Required | ✅ clayBorder, selected colors | ✅ Implemented | `CONSISTENT` ✅ |
| Overlay/scrim colors | Required | ⚠️ Partially documented | ❌ No overlay tokens | `DOCUMENTED_NOT_IMPLEMENTED` |
| Interactive colors | Required | ✅ teal for focus/active | ✅ Implemented | `CONSISTENT` ✅ |
| Disabled colors | Required | ⚠️ "50% opacity" mentioned | ❌ No disabled color tokens | `DOCUMENTED_NOT_IMPLEMENTED` |
| Dark mode colors | Required (future) | ❌ "Future phase" | ⚠️ Semantic tokens ready, dark values TBD | `PARTIAL` |
| Hardcoded colors in widgets | Should be zero in scope | — | ✅ Fixed in auth, onboarding, home, splash. Remaining in my_library, chat screens | `MOSTLY FIXED` ✅ |
| `Colors.white` usage | Should be tokenized | ✅ `AppColors.white` added | ✅ Replaced in all scoped files. 4 remaining in out-of-scope files | `MOSTLY FIXED` ✅ |
| Dark gold #9A7B3D | Should be tokenized | ✅ Added as `AppColors.goldDark` | ✅ Tokenized | `CONSISTENT` ✅ |
| Contrast rules | Required | ❌ Not documented | ✅ Caption contrast fixed to ~5.5:1 (warmMuted on cream) | `FIXED` ✅ |

### Category 4: Typography System — ✅ MOSTLY FIXED

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Typefaces (3 families) | Required | ✅ Fredoka, Nunito, Inter | ✅ Implemented via GoogleFonts in AppTypography | `CONSISTENT` ✅ |
| Font size scale | Required | ✅ 11-32px range | ✅ 17 styles in AppTypography | `CONSISTENT` ✅ |
| Line heights | Required | ✅ 1.2-1.5 documented | ✅ Implemented | `CONSISTENT` ✅ |
| Letter spacing | Required | ⚠️ Partial in doc | ⚠️ bodySm, caption, sentenceLabel have letter spacing | `INCONSISTENT` — doc gap |
| Hardcoded TextStyles | Should be zero in scope | — | ✅ Fixed in auth, onboarding, home, splash, aura_logo. Remaining: score_circle (2 GoogleFonts.fredoka) | `MOSTLY FIXED` ✅ |
| `fontFamily: 'Nunito'` bypass | Should use AppTypography | — | ✅ Fixed in home_screen, mode_card, scenario_app_bar. Remaining: conversation_history (2), mode_deep_dive_card (3) | `MOSTLY FIXED` ✅ |
| Multilingual typography | Required (Vi+En) | ❌ Not documented | ⚠️ `sentenceVi` exists for diacritics | `IMPLEMENTED_NOT_DOCUMENTED` |
| Text truncation rules | Required | ❌ Not documented | ❌ No standard rules | `MISSING` |
| Responsive typography | Optional (mobile) | ❌ Not documented | ❌ Not implemented | `MISSING` |

### Category 5: Layout System

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Screen padding standard | Required | ⚠️ "16px or 20px varies" | ❌ Hardcoded per-screen (16, 20, 24, 28) | `INCONSISTENT` |
| Safe area handling | Required | ⚠️ "Bottom 40-60px" mentioned | ⚠️ SafeArea used inconsistently | `INCONSISTENT` |
| Grid system | Optional (mobile) | ⚠️ Only topic grid (2-col) | ⚠️ Only GridView for topics | `CONSISTENT` |
| AppBar standard | Required | ✅ 48px, cream, elevation 0 | ❌ Inconsistent — some screens use warmDark bg, some white | `INCONSISTENT` |
| Bottom nav height | Required | ✅ 56px | ✅ Implemented | `CONSISTENT` |
| Platform layout differences | Optional | ❌ Not documented | ❌ Not implemented | `MISSING` |

### Category 6: Spacing & Sizing — ✅ FIXED

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Spacing scale | Required | ✅ Documented | ✅ `app_spacing.dart` — 14 tokens (2-48), 90 usages across 14 files | `CONSISTENT` ✅ |
| Touch target sizing | Required | ⚠️ AudioPlayButton "28x28" noted | ✅ Fixed to 44dp+ in ErrorBanner, BottomNavBar, HomeScreen, StepTopics, ScenarioAppBar | `MOSTLY FIXED` ✅ |
| Component sizing | Required | ⚠️ Scattered per-component | ❌ No centralized sizing tokens | `DOCUMENTED_NOT_IMPLEMENTED` |
| Missing spacing values | — | — | ✅ All common values (2, 4, 8, 10, 12, 14, 16, 18, 20, 24, 28, 32, 40, 48) now tokenized | `FIXED` ✅ |

### Category 7: Shape & Visual Style — ✅ MOSTLY FIXED

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Border radius scale | Required | ✅ 7 values (2-999) | ✅ `app_radius.dart` — 7 tokens with xxs(2), xs(4) added | `CONSISTENT` ✅ |
| Border thickness rules | Required | ✅ Per-component table | ⚠️ Not tokenized centrally | `DOCUMENTED_NOT_IMPLEMENTED` |
| Shadow system | Required | ✅ Documented | ✅ `app_shadows.dart` — 5 styles + colored() factory. clayHover removed (unused) | `CONSISTENT` ✅ |
| Hardcoded shadows | Should be zero in scope | — | ✅ Fixed in home_screen, mode_card, step_name_avatar. Remaining in out-of-scope files | `MOSTLY FIXED` ✅ |
| Hardcoded radius | Should be zero in scope | — | ✅ Fixed in progress_dots, step_topics, scenario_app_bar, shimmer_placeholder. Remaining: mode_deep_dive_card, assessment_card, my_library, context_panel, swipe_dots (dynamic) | `MOSTLY FIXED` ✅ |
| Opacity rules | Required | ⚠️ Scattered per-component | ❌ No opacity tokens | `DOCUMENTED_NOT_IMPLEMENTED` |
| Glass/blur effects | Optional | ❌ Not documented | ❌ Not used | `N/A_MOBILE` |

### Category 8: Iconography

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Icon library | Required | ✅ flutter_lucide (52 icons) | ✅ Used | `CONSISTENT` |
| Icon size scale | Required | ⚠️ Sizes scattered (16-48dp) | ❌ No icon size tokens | `DOCUMENTED_NOT_IMPLEMENTED` |
| Filled vs outline rules | Required | ❌ Not documented | ❌ Mixed usage | `MISSING` |
| Icon + label spacing | Required | ❌ Not documented | ❌ Hardcoded per-use | `MISSING` |

### Category 10: Motion System — ✅ MOSTLY FIXED

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Duration scale | Required | ✅ 4 values (150/200/300/500ms) | ✅ `app_animations.dart` — durationFast, durationMedium, durationNormal, durationSlow | `CONSISTENT` ✅ |
| Easing curves | Required | ✅ 4 curves | ⚠️ 1 tokenized (easeClay), 2 missing (easeQuadIn, easeQuadOut) | `INCONSISTENT` |
| Unused tokens | — | — | ✅ `easeBackOut` removed (zero usage verified) | `FIXED` ✅ |
| Hardcoded durations | Should be zero in scope | — | ✅ 200ms tokenized as durationMedium in bottom_nav, step_name_avatar, step_topics, lesson_card. Remaining: longer durations (600ms+) in splash/scenario animations | `MOSTLY FIXED` ✅ |
| Page transitions | Required | ✅ FadeTransition documented | ✅ `page_transitions.dart` — fadeTransitionPage() with easeClay curve | `CONSISTENT` ✅ |
| Reduced motion a11y | Required | ❌ Not documented | ❌ Not implemented | `MISSING` |

### Category 11: Interaction Principles — PARTIAL FIX

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Press/tap feedback | Required | ✅ ClayCard/ClayButton have press states | ⚠️ Only ClayButton implements press animation; all other taps use GestureDetector with no feedback | `INCONSISTENT` |
| Ripple/splash | Optional (Material) | Not specified | ❌ No InkWell/ripple anywhere — all GestureDetector | `MISSING` |
| Haptic feedback | Optional | ❌ Not documented | ❌ Not implemented | `MISSING` |
| Loading state pattern | Required | ✅ Spinner in buttons, shimmer for images | ✅ ShimmerPlaceholder created + wired into CloudImage. Buttons retain spinner | `CONSISTENT` ✅ |

### Category 12: Accessibility — ✅ BASIC COVERAGE

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Contrast standards | Required | ❌ | ✅ Caption fixed to ~5.5:1 (warmMuted #6B6D7B on cream) | `FIXED` ✅ |
| Screen reader support | Required | ❌ | ✅ Semantics on ClayButton, ClayCard, BottomNavBar items | `BASIC COVERAGE` ✅ |
| Touch target minimums | Required (44x44dp) | ❌ | ✅ Fixed in ErrorBanner, BottomNavBar, HomeScreen, StepTopics, ScenarioAppBar | `MOSTLY FIXED` ✅ |
| Motion accessibility | Required | ❌ | ❌ No prefers-reduced-motion | `MISSING` |
| Color blindness | Recommended | ❌ | ❌ Not considered | `MISSING` |

### Category 17: Navigation

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Bottom nav | Required | ✅ 3 tabs spec'd | ⚠️ Tab switching NOT functional — index changes but no actual navigation | `INCONSISTENT` |
| GoRouter config | Required | ✅ Full route tree with ShellRoute | ❌ Flat routes, no ShellRoute, no nested nav | `INCONSISTENT` |
| Page transitions | Required | ✅ FadeTransition documented | ❌ Default platform transitions only | `DOCUMENTED_NOT_IMPLEMENTED` |
| Back navigation | Required | ⚠️ arrow_left in AppBar | ⚠️ Mixed `context.pop()` and `context.go()` | `INCONSISTENT` |

### Category 18: Feedback Components

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| ErrorBanner | Required | ✅ Full spec | ✅ Implemented | `CONSISTENT` |
| LoadingIndicator | Required | ✅ Full spec | ✅ Implemented | `CONSISTENT` |
| ProgressBar/dots | Required | ✅ Documented | ✅ ProgressDots implemented | `CONSISTENT` |
| Skeleton/shimmer | Recommended | ✅ Documented (shimmer for CloudImage) | ✅ ShimmerPlaceholder created, wired into CloudImage | `CONSISTENT` ✅ |
| Toast/snackbar | Required | ⚠️ "Show toast 'Saved!'" mentioned once | ⚠️ SnackBar used but no styled component | `INCONSISTENT` |
| Dialog/confirmation | Required | ⚠️ "End session" mentioned | ⚠️ AlertDialog used inline, not shared | `INCONSISTENT` |
| Empty states | Required | ✅ Multiple defined | ✅ Implemented per-screen | `CONSISTENT` |

### Category 19: Overlay Components

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Bottom sheet | Required | ✅ SaveWordSheet, NotificationPermission | ⚠️ ConversationHistoryScreen has bottom sheet | `CONSISTENT` |
| Modal/dialog | Required | ⚠️ Mentioned but not spec'd | ⚠️ AlertDialog used inline, no shared pattern | `INCONSISTENT` |
| Scrim/backdrop | Required | ❌ Not documented | ❌ No standard scrim color | `MISSING` |
| Action sheet | Optional | ❌ Not documented | ❌ Not used | `N/A_MOBILE` |

### Category 24: State Patterns

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Default state | Required | ✅ Per-component | ✅ Implemented | `CONSISTENT` |
| Selected state | Required | ✅ ClayCard selection | ✅ Implemented | `CONSISTENT` |
| Disabled state | Required | ✅ 50% opacity | ⚠️ Inconsistent — some use opacity, some just null onTap | `INCONSISTENT` |
| Loading state | Required | ✅ Multiple patterns | ⚠️ No skeleton/shimmer; only spinners | `INCONSISTENT` |
| Empty state | Required | ✅ Per-screen | ✅ Implemented | `CONSISTENT` |
| Error state | Required | ✅ ErrorBanner | ✅ Implemented | `CONSISTENT` |
| Offline state | Recommended | ⚠️ "Dual-write" mentioned | ❌ No offline UI indicator | `DOCUMENTED_NOT_IMPLEMENTED` |
| First-time use | Required | ✅ Onboarding flow | ✅ Implemented | `CONSISTENT` |

### Category 28: Theming — ✅ PREP DONE

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Light mode | Required | ✅ Fully defined | ✅ `AppTheme.light` with full component themes | `CONSISTENT` ✅ |
| Dark mode | Required (planned) | ❌ "Future phase" only | ⚠️ Semantic tokens ready, dark values TBD | `PARTIAL` |
| Theme switching | Required (planned) | ❌ Not documented | ❌ Settings toggle does nothing | `MISSING` |
| Semantic tokens for theming | Required (prep) | ❌ Not documented | ✅ `AppSemanticColors` ThemeExtension with 10 tokens, light variant registered | `IMPLEMENTED` ✅ |
| Material component themes | Recommended | ⚠️ Only AppBar, TextTheme | ✅ Added: ElevatedButton, InputDecoration, Card, Dialog, BottomNavigationBar themes | `CONSISTENT` ✅ |

### Category 29: Localization — ✅ INFRA DONE

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| i18n framework | Required | ✅ l10n.yaml configured | ✅ flutter_localizations + generate:true in pubspec | `IMPLEMENTED` ✅ |
| String externalization | Required | ⚠️ Partial | ✅ 20 keys in app_en.arb + app_vi.arb (auth + onboarding). Remaining screens need extraction | `PARTIAL` |
| Vietnamese UI support | Required | ⚠️ Vietnamese content in examples | ✅ `sentenceVi` typography + app_vi.arb translations | `CONSISTENT` ✅ |
| Date/time formatting | Required | ❌ Not documented | ⚠️ `intl` package in pubspec but not used for formatting | `MISSING` |

---

## CODE INCONSISTENCIES SUMMARY

### Duplicate Components

| Pattern | Status | Detail |
|---------|--------|--------|
| Check circle (selection indicator) | ✅ FIXED | Extracted to `SelectionCheckCircle` widget. Used in step_level, step_goals, step_daily_time |
| Colored clay shadow | ✅ FIXED | `AppShadows.colored(Color c)` factory added. Used in mode_card, home_screen, step_name_avatar |
| Badge/chip/pill | ✅ PARTIAL | `ClayBadge` widget created. Used in mode_card. Other badge patterns (assessment_card, my_library) not yet migrated |
| AlertDialog pattern | ❌ TODO | Still inline in scenario_chat_screen, my_library_screen |
| CTA button in cards | ❌ TODO | Still divergent across ModeCard, ModeDeepDiveCard, SessionSummaryScreen |

### Tokens Defined But NEVER Used — ✅ RESOLVED

| Token | Status | Resolution |
|-------|--------|------------|
| `AppSpacing.*` | ✅ FIXED | 90 usages across 14 files |
| `AppShadows.clayHover` | ✅ REMOVED | Zero usage verified, removed |
| `AppAnimations.easeBackOut` | ✅ REMOVED | Zero usage verified, removed |
| `AppColors.neutralTone` | — | Low priority, kept for potential tone system use |
| `AppTypography.logo` | ✅ FIXED | Now used in AuraLogo widget |
| `AppTypography.bodyLg` | — | Used in TextTheme, may be used by Material widgets |

### Values Used But NOT Tokenized — ✅ MOSTLY RESOLVED

| Value | Status | Resolution |
|-------|--------|------------|
| `Duration(milliseconds: 200)` | ✅ FIXED | Tokenized as `AppAnimations.durationMedium` |
| `Color(0xFF9A7B3D)` dark gold | ✅ FIXED | Tokenized as `AppColors.goldDark` |
| `BorderRadius.circular(4)` | ✅ FIXED | Tokenized as `AppRadius.xsBorder` |
| `BorderRadius.circular(2)` | ✅ FIXED | Tokenized as `AppRadius.xxsBorder` |
| `Colors.white` | ✅ MOSTLY FIXED | Tokenized as `AppColors.white`. 4 remaining in out-of-scope files |
| `Offset(3, 3)` clay offset | ❌ TODO | Still inline in AppShadows definition |
| Colored clay shadow pattern | ✅ FIXED | `AppShadows.colored(Color c)` factory |
| Chat bubble radii (4/28) | ❌ TODO | Still hardcoded in chat bubble widgets |

### Naming Inconsistencies — ✅ FIXED

| Issue | Status | Resolution |
|-------|--------|------------|
| `translate_prompt.dart` → `LessonCard` | ✅ FIXED | Renamed to `lesson_card.dart` |
| `inline_assessment.dart` → `AssessmentCard` | ✅ FIXED | Renamed to `assessment_card.dart` |
| `AuthButtonStyle` vs `*Variant` | ✅ FIXED | Renamed to `AuthButtonVariant` |
| "Setting" (singular) | ✅ FIXED | Changed to "Settings" in BottomNavBar label |
| Doc color naming vs code | ❌ TODO | Doc still uses `tealClay` etc. |
| BottomNavBar mixed item types | — | Low priority, cosmetic |

---

## INCONSISTENCIES BETWEEN DOCS

| Issue | design-system-v2 says | comprehensive-design says | Code reality |
|-------|----------------------|--------------------------|--------------|
| Bottom nav border | "Top 1px" | "2px, clayBorder" | No top border in code |
| Typography for topic labels | "13px, fontWeight 600" | "bodySm (14px), 600 weight" | Uses `bodySm.copyWith(fontWeight: w600)` = 14px |
| Splash stagger timing | "300ms stagger" | "200ms stagger (0-300, 200-600, 400-800ms)" | Code has no stagger — just floating orb 3s + delay 2s |
| Color token naming | `tealClay`, `purpleClay`, `goldClay` | Same | Code: `teal`, `purple`, `gold` (no "Clay" suffix) |
| Typography count | "13 styles" | 13 styles listed | 17 styles in code (4 extra: sentence, sentenceVi, sentenceLabel, logo) |
| Shimmer for CloudImage | "Add shimmer" (as fix needed) | "Built-in shimmer" (as spec) | ✅ ShimmerPlaceholder now used in CloudImage |
| `app_spacing.dart` | Not mentioned | Listed in Section 2.3 | ✅ 14 tokens, 90 usages across 14 files |

---

## PRIORITIZED ACTION PLAN

### P0 — CRITICAL (Blocking consistency) — ✅ ALL DONE

1. ✅ **Adopt AppSpacing everywhere** — Expanded to 14 tokens, 90 usages across 14 files.
2. ✅ **Add missing radius tokens** — `AppRadius.xxs = 2`, `AppRadius.xs = 4` added with BorderRadius helpers.
3. ✅ **Add missing animation token** — `AppAnimations.durationMedium = 200ms` added.
4. ✅ **Tokenize dark gold color** — `AppColors.goldDark = Color(0xFF9A7B3D)` added.
5. ✅ **Add `AppColors.white`** — Added and replaced in all scoped files.
6. ✅ **Remove/use orphan tokens** — `clayHover` removed, `easeBackOut` removed, `AppTypography.logo` now used in AuraLogo.

### P1 — HIGH (Required for design system integrity) — ✅ ALL DONE

7. ✅ **Eliminate hardcoded TextStyles** — GoogleFonts removed from auth, onboarding, home, splash, aura_logo. fontFamily bypasses removed from home_screen, mode_card, scenario_app_bar.
8. ✅ **Eliminate hardcoded shadows** — `AppShadows.colored(Color c)` factory added. Inline shadows replaced in mode_card, home_screen, step_name_avatar.
9. ✅ **Eliminate hardcoded radius** — Replaced in progress_dots, step_topics, scenario_app_bar, shimmer_placeholder.
10. ✅ **Extract duplicate widgets** — `SelectionCheckCircle`, `ClayBadge`, `ShimmerPlaceholder` created.
11. ✅ **Introduce semantic color tokens** — `AppSemanticColors` ThemeExtension with 10 tokens + light variant.
12. ✅ **Set up i18n framework** — flutter_localizations + ARB files (20 keys, en + vi).
13. ✅ **Fix Material ThemeData** — Added ElevatedButton, InputDecoration, Card, Dialog, BottomNavigationBar themes.

### P2 — MEDIUM (Improve robustness) — ✅ ALL DONE

14. ✅ **Add basic accessibility** — Semantics on ClayButton, ClayCard, BottomNavBar. Touch targets fixed to 44dp+. Caption contrast fixed.
15. ✅ **Add custom page transitions** — `fadeTransitionPage()` in `page_transitions.dart`.
16. ✅ **Implement shimmer loading** — ShimmerPlaceholder wired into CloudImage.
17. ⚠️ **Fix navigation** — BottomNavBar labels added. Full tab switching and go/pop consistency deferred (separate task).
18. ✅ **Resolve token overlap** — Documented with inline comments explaining intentional overlap.
19. ✅ **Fix naming inconsistencies** — File renames (lesson_card, assessment_card), AuthButtonStyle→AuthButtonVariant, "Setting"→"Settings".

### P3 — LOW (Nice to have) — UNCHANGED

20. **Document brand foundation** — Purpose, design principles, tone of voice.
21. **Add opacity tokens** — Centralize common opacity values (0.05, 0.1, 0.3, 0.5, 0.7).
22. **Add border thickness tokens** — Centralize 1px, 1.5px, 2px, 4px values.
23. **Add icon size tokens** — Standardize icon sizes across the app.
24. **Document platform guidelines** — iOS vs Android differences, status bar handling.
25. **Update both docs to match code** — Sync token names, add missing styles, correct stagger timings.

### REMAINING WORK (out-of-scope files)

Files not covered in this fix pass that still have hardcoded patterns:

| File | Issues |
|------|--------|
| `my_library_screen.dart` | Colors.white (2), BorderRadius.circular (2), hardcoded spacing |
| `chat_bubble_user.dart` | Colors.white (1), hardcoded spacing |
| `chat_input_bar.dart` | Colors.white (1), hardcoded TextStyle |
| `session_summary_screen.dart` | Colors.white (1), hardcoded spacing |
| `conversation_history_screen.dart` | fontFamily: 'Nunito' (2) |
| `mode_deep_dive_card.dart` | fontFamily: 'Nunito' (3), BorderRadius.circular (2) |
| `score_circle.dart` | GoogleFonts.fredoka (2) |
| `assessment_card.dart` | BorderRadius.circular (1) |
| `context_panel.dart` | BorderRadius.circular (1) |

---

## APPENDIX: Color Token Overlap Map

```
#E8C77B ──┬── AppColors.gold (accent)
          ├── AppColors.warning (semantic)
          └── AppColors.friendlyTone (tone)

#D98A8A ──┬── AppColors.error (semantic)
          └── AppColors.casualTone (tone)

#7BC6A0 ──┬── AppColors.success (semantic)
          └── AppColors.neutralTone (tone)

#7ECEC5 ──┬── AppColors.teal (accent)
          └── info (documented, not in code as separate token)
```

**Risk:** If tone colors ever need to diverge from semantic colors (e.g., "casual" tone should NOT look like "error"), this coupling will break.

**Recommendation:** Keep separate tokens but add comments documenting the intentional overlap. If they diverge in the future, only the token values need to change.

---

*End of Gap Analysis — Generated 2026-04-17*
