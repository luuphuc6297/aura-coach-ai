# Aura Coach Mobile — Design System v2 (UI/UX Audit & Fixes)

**Version:** 2.0  
**Date:** 2026-04-04  
**Focus:** Critical UI/UX bugs found during audit + corrected specifications

---

## ⚠️ CRITICAL UI/UX ISSUES FOUND IN AUDIT

This document lists every UI/UX bug found in the current codebase and provides the corrected specification for each.

---

## 1. APP ICON & LOGO — "AURA C🔮ACH" Brand Identity

### 1.1 Current Problem

- The app icon is the **default Flutter icon** — not branded
- The "AURA COACH" text on splash/auth screens is plain text
- The Aura Orb icon should replace the letter "O" in "C**O**ACH" (or both "O"s in "AURA C**O**ACH")
- `AuraLogo` widget only renders the orb image — does NOT include the text logo

### 1.2 Corrected Specification

**App Launcher Icon:**
- Must be a custom icon featuring the Aura Orb on cream background
- Use `flutter_launcher_icons` package to generate all iOS/Android sizes
- iOS: 1024×1024 source → generated for all @1x/@2x/@3x sizes
- Android: Adaptive icon with Aura Orb foreground + cream background

**Text Logo Widget (`AuraLogo`):**
- Renders "AURA C" + [Aura Orb inline image] + "ACH" as a single Row
- The Orb should be sized to match the text line height (e.g., 24dp for 24px font)
- Font: Fredoka 700, letter-spacing: 2px, color: warmDark
- Used on: Splash, Auth, Home AppBar (smaller), Profile sheet

```dart
// CORRECTED AuraLogo implementation
class AuraLogo extends StatelessWidget {
  final double fontSize;
  const AuraLogo({this.fontSize = 24, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orbSize = fontSize * 1.2; // Slightly larger than font
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('AURA C', style: GoogleFonts.fredoka(
          fontSize: fontSize, fontWeight: FontWeight.w700,
          color: AppColors.warmDark, letterSpacing: 2,
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: CloudImage(
            url: CloudinaryAssets.auraOrbChat,
            size: orbSize,
            fit: BoxFit.contain,
          ),
        ),
        Text('ACH', style: GoogleFonts.fredoka(
          fontSize: fontSize, fontWeight: FontWeight.w700,
          color: AppColors.warmDark, letterSpacing: 2,
        )),
      ],
    );
  }
}
```

**Splash Screen Logo:**
- Large Aura Orb (96dp) ABOVE the text logo
- Text logo below with `fontSize: 28`
- Smooth fade-in animation (300ms stagger: orb first, then text)

---

## 2. BORDERS — System-Wide Border Fix

### 2.1 Current Problem (CRITICAL)

The app has **DOUBLE and TRIPLE borders everywhere** due to nested decoration conflicts:

**Problem 1 — ClayCard double border:**
```dart
// ClayCard already has Border.all(color: clayBorder, width: 2)
// BUT ModeCard wraps child in ANOTHER Container with its own border:
Container(
  decoration: BoxDecoration(
    border: Border.all(color: accentColor.withOpacity(0.3), width: 1), // ← EXTRA BORDER
  ),
  child: Column(...)
)
```
Result: Mode cards on Home screen have 2 visible borders (beige outer + colored inner).

**Problem 2 — Onboarding triple border on level cards:**
```dart
ClayCard(                    // ← Border 1: clayBorder 2px
  child: Container(
    decoration: BoxDecoration(
      border: isSelected
        ? Border.all(color: tealClay, width: 2)   // ← Border 2: teal selection
        : null,
    ),
    child: Row(...)
  ),
)
```
Result: Selected level cards have 2 borders. But ClayCard already provides the card border.

**Problem 3 — Onboarding topic cards double border:**
```dart
ClayCard(                    // ← Border 1: clayBorder 2px
  child: Container(
    decoration: BoxDecoration(
      border: isSelected
        ? Border.all(color: tealClay, width: 2)   // ← Border 2: teal selection
        : null,
      color: isSelected ? tealClay.withOpacity(0.1) : null,
    ),
    child: Column(...)
  ),
)
```

### 2.2 Corrected Specification

**Rule: ONE border per component. Selection state changes the EXISTING border, not adds a new one.**

**ClayCard — Updated API:**
```dart
class ClayCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color borderColor;       // Default: clayBorder
  final bool isSelected;         // NEW — controls border highlight
  final Color selectedBorderColor; // NEW — default: tealClay
  final EdgeInsetsGeometry padding;
  final bool interactive;
  // ...
}
```

When `isSelected = true`:
- Border color changes from `clayBorder` to `selectedBorderColor` (tealClay)
- Background gets subtle tint: `selectedBorderColor.withOpacity(0.05)`
- No additional Container borders needed

**ModeCard — Remove inner border entirely:**
```dart
// BEFORE (WRONG):
Container(
  decoration: BoxDecoration(
    border: Border.all(color: accentColor.withOpacity(0.3), width: 1), // DELETE THIS
  ),
  child: Column(...)
)

// AFTER (CORRECT):
// Just the content directly inside ClayCard, no extra Container decoration
ClayCard(
  borderColor: accentColor.withOpacity(0.3), // Use ClayCard's own borderColor prop
  child: Column(
    children: [
      // icon, title, description...
    ],
  ),
)
```

**Onboarding Level Cards — Use ClayCard's `isSelected`:**
```dart
ClayCard(
  isSelected: _selectedLevel == level['name'],
  selectedBorderColor: AppColors.tealClay,
  onTap: () => setState(() => _selectedLevel = level['name']!),
  child: Row(
    // icon, level name, CEFR label — NO Container wrapper with border
  ),
)
```

**Onboarding Topic Cards — Same pattern:**
```dart
ClayCard(
  isSelected: _selectedTopics.contains(topic),
  selectedBorderColor: AppColors.tealClay,
  onTap: () => _toggleTopic(topic),
  child: Column(
    children: [
      Text(topic.fluentEmoji, style: TextStyle(fontSize: 32)), // SHOW THE EMOJI
      SizedBox(height: 8),
      Text(topic.label),
    ],
  ),
)
```

### 2.3 Global Border Rules

| Component | Border Width | Default Color | Selected Color | Radius |
|-----------|-------------|---------------|----------------|--------|
| ClayCard (standard) | 2px | `clayBorder` (#E8DFD3) | — | lg (20px) |
| ClayCard (selected) | 2px | `tealClay` (#7ECEC5) | tealClay | lg (20px) |
| ClayCard (interactive hover) | 2px | `clayBorder` | — | lg (20px) |
| TextField | 1px | `clayBorder` | `tealClay` (focused) | md (12px) |
| Chat Bubble (AI) | Left 4px tealClay only | — | — | asymmetric |
| Chat Bubble (User) | none | — | — | asymmetric |
| Bottom Nav | Top 1px | `clayBorder` | — | none |
| Buttons (primary) | none | — | — | lg (20px) |
| Buttons (secondary) | 2px | `purpleClay` | — | lg (20px) |
| Buttons (outlined) | 1.5px | `clayBorder` | — | lg (20px) |

---

## 3. TOPIC ICONS NOT RENDERING

### 3.1 Current Problem

In `onboarding_screen.dart` Step 2 (topic selection grid), each topic card shows:
- A checkmark/circle icon (selection indicator)
- The topic label text

But the **topic emoji is NEVER rendered**. The `TopicItem.fluentEmoji` field (e.g., "✈️", "💼", "🏠") is defined in `topic_constants.dart` but completely ignored in the UI.

### 3.2 Corrected Specification

Each topic card MUST show:
1. **Topic emoji** — Large (32dp), centered, from `topic.fluentEmoji`
2. **Topic label** — Below emoji, 13px, fontWeight 600
3. **Selection indicator** — Small checkmark badge in top-right corner (not replacing the emoji)

```dart
// CORRECTED Topic Card
ClayCard(
  isSelected: isSelected,
  selectedBorderColor: topic.accentColor,
  onTap: () => _toggleTopic(topic),
  padding: EdgeInsets.all(12),
  child: Stack(
    children: [
      // Selection badge (top-right corner)
      if (isSelected)
        Positioned(
          top: 0, right: 0,
          child: Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: topic.accentColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 12, color: Colors.white),
          ),
        ),
      // Main content
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(topic.fluentEmoji,
            style: TextStyle(fontSize: 32),  // ← THE MISSING EMOJI
          ),
          SizedBox(height: 8),
          Text(topic.label,
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? topic.accentColor : AppColors.warmDark,
            ),
          ),
        ],
      ),
    ],
  ),
)
```

---

## 4. AUTH SCREEN — ALL BUTTONS LOADING BUG

### 4.1 Current Problem

In `auth_screen.dart`, ALL 3 auth buttons share the same `authProvider.isLoading` boolean:

```dart
_AuthButton(
  isLoading: authProvider.isLoading,  // ← Same for ALL buttons
  onPressed: authProvider.isLoading ? null : () => authProvider.signInWithGoogle(),
),
_AuthButton(
  isLoading: authProvider.isLoading,  // ← Same bool = ALL show spinner
  onPressed: authProvider.isLoading ? null : () => authProvider.signInWithApple(),
),
_AuthButton(
  isLoading: authProvider.isLoading,  // ← Same bool = ALL show spinner
  onPressed: authProvider.isLoading ? null : () => authProvider.continueAsGuest(),
),
```

When user taps ANY button, ALL 3 buttons show a loading spinner simultaneously.

### 4.2 Corrected Specification

**AuthProvider changes:**
```dart
enum AuthMethod { google, apple, guest }

class AuthProvider extends ChangeNotifier {
  AuthMethod? _loadingMethod;  // null = nothing loading
  
  bool isMethodLoading(AuthMethod method) => _loadingMethod == method;
  bool get isAnyLoading => _loadingMethod != null;
}
```

**Auth Screen changes:**
```dart
_AuthButton(
  label: 'Continue with Google',
  icon: Icons.g_mobiledata,  // Or Google logo asset
  isLoading: authProvider.isMethodLoading(AuthMethod.google),
  onPressed: authProvider.isAnyLoading
    ? null
    : () => authProvider.signInWithGoogle(),
),
_AuthButton(
  label: 'Continue with Apple',
  icon: Icons.apple,
  isLoading: authProvider.isMethodLoading(AuthMethod.apple),
  onPressed: authProvider.isAnyLoading
    ? null
    : () => authProvider.signInWithApple(),
),
_AuthButton(
  label: 'Try as Guest',
  isLoading: authProvider.isMethodLoading(AuthMethod.guest),
  onPressed: authProvider.isAnyLoading
    ? null
    : () => authProvider.continueAsGuest(),
),
```

Result: Only the tapped button shows a spinner. Other buttons are disabled (greyed) but don't show spinners.

---

## 5. UI/UX SMOOTHNESS ISSUES

### 5.1 Missing Page Transitions

**Current:** GoRouter uses default Material page transitions (slide from right on iOS, fade on Android). No custom clay-themed transitions.

**Fix — Add custom page transitions:**
```dart
GoRoute(
  path: '/home/scenario/:lessonId',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: ChatRoleplayScreen(lessonId: state.pathParameters['lessonId']!),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
    transitionDuration: AppAnimations.durationNormal,
  ),
),
```

### 5.2 ClayCard `interactive` Not Used

**Current:** `ModeCard` wraps content in `ClayCard` but does NOT pass `interactive: true`. This means mode cards have no press animation (scale down + shadow reduce) even though `ClayCard` supports it.

**Fix:**
```dart
// In ModeCard:
ClayCard(
  interactive: true,  // ← ADD THIS
  onTap: onTap,
  child: ...
)
```

### 5.3 ClayButton Never Used

**Current:** A well-implemented `ClayButton` widget exists in `shared/widgets/clay_button.dart` with 5 variants (primary, secondary, danger, ghost, pill), proper shadow animations, and loading states. But it's NEVER used anywhere in the app:
- `auth_screen.dart` uses custom `_AuthButton` (Material + InkWell)
- `onboarding_screen.dart` uses standard `ElevatedButton` / `OutlinedButton`
- `chat_roleplay_screen.dart` uses `ElevatedButton.icon`
- `home_screen.dart` has no buttons

**Fix:** Replace all button implementations with `ClayButton`:
```dart
// Auth screen:
ClayButton(
  text: 'Continue with Google',
  icon: Icons.g_mobiledata,
  variant: ClayButtonVariant.primary,
  isFullWidth: true,
  isLoading: authProvider.isMethodLoading(AuthMethod.google),
  onTap: authProvider.isAnyLoading ? null : () => authProvider.signInWithGoogle(),
)

// Onboarding:
ClayButton(
  text: 'Next',
  variant: ClayButtonVariant.primary,
  isFullWidth: true,
  onTap: _handleNext,
)
```

### 5.4 No Loading Skeletons for Images

**Current:** `CloudImage` shows a `CircularProgressIndicator` while loading. This is jarring, especially on the home screen where 4 mode card icons load simultaneously.

**Fix — Add shimmer/skeleton loading:**
```dart
// In CloudImage placeholder:
Container(
  decoration: BoxDecoration(
    color: AppColors.clayBeige,
    borderRadius: AppRadius.mdBorder,
  ),
  child: ShimmerEffect(  // Custom shimmer widget
    baseColor: AppColors.clayBeige,
    highlightColor: AppColors.clayWhite,
  ),
)
```

### 5.5 Splash Screen — No Animation

**Current:** Splash screen shows static orb + text + spinner. No entrance animation.

**Fix — Add staggered fade-in:**
```dart
// Stagger: Orb fades in (0-400ms), text fades in (200-600ms), subtitle (400-800ms)
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _orbOpacity;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _orbOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5)),
    );
    _textOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.75)),
    );
    _controller.forward();
  }
}
```

### 5.6 Bottom Nav — No Active Tab Animation

**Current:** Tab changes instantly. No scale/bounce animation on the active icon.

**Fix:**
```dart
AnimatedScale(
  duration: AppAnimations.durationFast,
  scale: isSelected ? 1.15 : 1.0,
  curve: AppAnimations.easeClay,
  child: CloudImage(url: imageUrl, size: 28),
)
```

### 5.7 Missing Hero Animations

**Current:** No hero animations between screens. Navigating from Home → Chat has no visual continuity.

**Fix:** Wrap mode card icon in `Hero` widget:
```dart
// In ModeCard:
Hero(
  tag: 'mode-icon-$title',
  child: CloudImage(url: iconUrl, size: 48),
)

// In ChatRoleplayScreen AppBar:
Hero(
  tag: 'mode-icon-Scenario Coach',
  child: CloudImage(url: CloudinaryAssets.modeScenarioCoach, size: 28),
)
```

---

## 6. COLOR & TYPOGRAPHY TOKENS (Unchanged — Verified Correct)

### 6.1 Colors ✅

All color tokens in `app_colors.dart` are correct and match the spec:
- Surface: cream `#FFF8F0`, clayWhite `#FEFCF9`, clayBeige `#F5EDE3`, clayBorder `#E8DFD3`
- Text: warmDark `#2D3047`, warmMuted `#6B6D7B`, warmLight `#9B9DAB`
- Accent: tealClay `#7ECEC5`, purpleClay `#A78BCA`, goldClay `#E8C77B`
- Semantic: success `#7BC6A0`, warning `#E8C77B`, error `#D98A8A`

### 6.2 Typography ✅

Font stack correctly implemented:
- Fredoka 700 — Logo only
- Nunito 600/700/800 — Headings (display, h1, h2, h3)
- Inter 400/500/600/700 — Body, data, captions, labels, buttons

### 6.3 Shadows ✅

Clay shadow (3px 3px 0px) and variants correctly defined.

### 6.4 Spacing ✅

4px base unit correctly implemented.

### 6.5 Radius ✅

sm(8), md(12), lg(20), xl(28), full(999) correctly defined.

---

## 7. DEPRECATED API USAGE

### 7.1 `withOpacity()` → `withValues()`

**Current (deprecated in newer Flutter):**
```dart
color: AppColors.warmDark.withOpacity(0.06)
color: accentColor.withOpacity(0.3)
color: ClayTheme.tealClay.withOpacity(0.1)
```

**Fix:**
```dart
color: AppColors.warmDark.withValues(alpha: 0.06)
color: accentColor.withValues(alpha: 0.3)
color: ClayTheme.tealClay.withValues(alpha: 0.1)
```

Files affected: `app_shadows.dart`, `mode_card.dart`, `onboarding_screen.dart`, `chat_roleplay_screen.dart`, `clay_theme.dart`, and others.

---

## 8. SUMMARY — Complete Fix Checklist

| # | Issue | Severity | Files Affected |
|---|-------|----------|----------------|
| 1 | App icon = default Flutter icon | 🔴 CRITICAL | `pubspec.yaml` + new launcher icon asset |
| 2 | Logo text missing Aura Orb in "O" | 🔴 CRITICAL | `shared/widgets/aura_logo.dart` |
| 3 | Double/triple borders everywhere | 🔴 CRITICAL | `clay_card.dart`, `mode_card.dart`, `onboarding_screen.dart` |
| 4 | Topic emoji icons not rendered | 🔴 CRITICAL | `onboarding_screen.dart` step 2 |
| 5 | All 3 auth buttons loading simultaneously | 🔴 CRITICAL | `auth_provider.dart`, `auth_screen.dart` |
| 6 | ClayButton exists but never used | 🟡 HIGH | `auth_screen.dart`, `onboarding_screen.dart`, `chat_roleplay_screen.dart` |
| 7 | ModeCard not interactive (no press animation) | 🟡 HIGH | `home_screen.dart` → `mode_card.dart` |
| 8 | No page transitions | 🟡 MEDIUM | `app.dart` (GoRouter config) |
| 9 | No splash animation | 🟡 MEDIUM | `splash_screen.dart` |
| 10 | No loading skeletons for images | 🟡 MEDIUM | `cloud_image.dart` |
| 11 | No hero animations | 🟢 LOW | `mode_card.dart`, chat screens |
| 12 | No bottom nav active animation | 🟢 LOW | `bottom_nav.dart` |
| 13 | `withOpacity()` deprecated | 🟢 LOW | 8+ files |

---

## 9. NEWLY DISCOVERED — DUPLICATE COMPONENTS

### 9.1 3 DUPLICATE ChatBubble Implementations

The app has THREE different chat bubble widgets with incompatible APIs:

| File | Lines | Used by | Design System? |
|------|-------|---------|---------------|
| `shared/widgets/chat_bubble.dart` | 92 | Nothing (dead code) | ✅ Uses AppColors, AppTypography, sender label, accentColor |
| `roleplay/widgets/chat_bubble.dart` | 70 | `chat_roleplay_screen.dart` | ❌ Hardcoded ClayTheme, no sender label |
| `translator/_buildMessageBubble()` | inline | `tone_translator_screen.dart` | ❌ Inline method, different styling |

**Fix:** Delete feature-specific bubbles. Use `shared/widgets/chat_bubble.dart` everywhere.

### 9.2 2 DUPLICATE AssessmentCard Implementations

| File | Lines | Features | Used by |
|------|-------|----------|---------|
| `shared/widgets/assessment_card.dart` | 458 | RadarScore, ToneVariations, Grammar/Vocab analysis, AudioPlayer, ClayButton footer | Nothing (dead code) |
| `roleplay/widgets/assessment_card.dart` | 117 | score int, feedback string, suggestions — simplified | `chat_roleplay_screen.dart`, `chat_story_screen.dart` |

**Impact:** The FULL 458-line assessment card is unused. The feature screens use the simplified 117-line version that lacks RadarScore, grammar analysis, and tone variations — the key differentiating features of the app.

**Fix:** Delete `roleplay/widgets/assessment_card.dart`. Wire `shared/widgets/assessment_card.dart` with real `AssessmentResult` data from AI evaluation.

---

## 10. NEWLY DISCOVERED — NAVIGATION BUGS

### 10.1 Chat Screens Display Inside Bottom Nav Shell

**Current:** Routes like `/home/scenario/:lessonId` and `/home/story/:storyId` are NESTED inside the `ShellRoute` → `BottomNavScaffold`. The bottom nav bar is visible during full-screen chat sessions, wasting 56dp of screen height.

**Fix:** Move chat routes OUTSIDE the ShellRoute:
```dart
GoRouter(
  routes: [
    GoRoute(path: '/splash', ...),
    GoRoute(path: '/auth', ...),
    GoRoute(path: '/onboarding', ...),
    // Full-screen routes (NO bottom nav)
    GoRoute(path: '/chat/roleplay/:lessonId', builder: ...),
    GoRoute(path: '/chat/story/:storyId', builder: ...),
    GoRoute(path: '/chat/translator', builder: ...),
    GoRoute(path: '/vocab/word/:itemId', builder: ...),
    GoRoute(path: '/vocab/mind-map/:mapId', builder: ...),
    GoRoute(path: '/vocab/flashcards', builder: ...),
    // Shell route (WITH bottom nav)
    ShellRoute(
      builder: (_, __, child) => BottomNavScaffold(child: child, ...),
      routes: [
        GoRoute(path: '/home', builder: ...),
        GoRoute(path: '/user', builder: ...),
        GoRoute(path: '/setting', builder: ...),
      ],
    ),
  ],
)
```

### 10.2 Conversation History Has No Entry Point

Route `/home/conversation-history` exists but Home screen has NO button to navigate there. Feature is unreachable.

**Fix:** Add a "History" button to HomeScreen AppBar or add it as a link in the profile.

### 10.3 Router Doesn't React to Auth State Changes

**Current:** `redirect` reads AuthProvider with `listen: false` (line 48 of `app.dart`). If user signs out while on a protected screen, the router does NOT re-evaluate → user is stuck.

**Fix:**
```dart
GoRouter(
  refreshListenable: authProvider,  // ← Re-evaluates redirect on auth changes
  ...
)
```

---

## 11. NEWLY DISCOVERED — PROFILE & SETTINGS BUGS

### 11.1 Profile Screen — All Data Hardcoded

| Data | Current | Should be |
|------|---------|-----------|
| Badge text | `'Intermediate Learner'` | Read from `user_profiles.proficiency_level` |
| Roleplay usage | `25%` | Read from `usage` collection |
| Story usage | `45%` | Read from `usage` collection |
| Translator usage | `15%` | Read from `usage` collection |
| Avatar | First letter of name | Cloudinary avatar from profile |

### 11.2 Settings Screen — Multiple Issues

| Bug | Detail |
|-----|--------|
| Email shows `user@example.com` | Should read `authProvider.currentUser?.email` |
| Password field exists | Irrelevant — app uses Google/Apple SSO, no password-based auth |
| Dark Mode toggle does nothing | `_darkModeEnabled` local state, but no `darkTheme` in MaterialApp |
| Switch color = `warmDark` | Should be `tealClay` to match ClayTheme's switchTheme |
| Subscription shows `Free Plan` | Hardcoded, not from user tier |
| All `onTap: () {}` callbacks | No-op, no navigation implemented |

### 11.3 Inconsistent AppBar Styling

Settings uses `warmDark` background, History uses `Colors.white` with elevation `1`. All other screens use feature-specific accent colors with elevation `0`.

**Fix:** Standardize pattern: feature accent color + `elevation: 0` + white title text for all screens. Or use cream background for History/Profile since they aren't feature-specific.

### 11.4 Profile "Upgrade to Pro" Button Does Nothing

`onPressed: () {}` — no navigation to a paywall/subscription screen. No paywall screen exists at all.

---

## 12. COMPLETE FIX CHECKLIST — Updated

| # | Issue | Severity | Files Affected |
|---|-------|----------|----------------|
| 1 | App icon = default Flutter icon | 🔴 CRITICAL | `pubspec.yaml` + new launcher icon |
| 2 | Logo text missing Aura Orb in "O" | 🔴 CRITICAL | `aura_logo.dart` |
| 3 | Double/triple borders everywhere | 🔴 CRITICAL | `clay_card.dart`, `mode_card.dart`, `onboarding_screen.dart`, `tone_card.dart`, `assessment_card.dart`, `word_analysis_screen.dart`, `vocab_hub_screen.dart` |
| 4 | Topic emoji icons not rendered | 🔴 CRITICAL | `onboarding_screen.dart` |
| 5 | All 3 auth buttons loading simultaneously | 🔴 CRITICAL | `auth_provider.dart`, `auth_screen.dart` |
| 6 | ClayButton never used | 🟡 HIGH | 7+ screen files |
| 7 | ModeCard no press animation | 🟡 HIGH | `mode_card.dart` |
| 8 | 3 duplicate ChatBubble widgets | 🟡 HIGH | 3 files → consolidate to 1 |
| 9 | 2 duplicate AssessmentCard (full one unused) | 🟡 HIGH | 2 files → use shared version |
| 10 | Chat screens show inside bottom nav | 🟡 HIGH | `app.dart` routing |
| 11 | Router doesn't react to auth state | 🟡 HIGH | `app.dart` |
| 12 | Profile data entirely hardcoded | 🟡 MEDIUM | `profile_screen.dart` |
| 13 | Settings email/password/dark mode broken | 🟡 MEDIUM | `settings_screen.dart` |
| 14 | Conversation history unreachable | 🟡 MEDIUM | `home_screen.dart` |
| 15 | AppBar styling inconsistent | 🟡 MEDIUM | `settings_screen.dart`, `conversation_history_screen.dart` |
| 16 | No page transitions | 🟡 MEDIUM | `app.dart` |
| 17 | No splash animation | 🟡 MEDIUM | `splash_screen.dart` |
| 18 | Flashcard scale not 3D flip | 🟢 LOW | `flashcards_screen.dart` |
| 19 | No hero animations | 🟢 LOW | `mode_card.dart`, chat screens |
| 20 | No bottom nav active animation | 🟢 LOW | `bottom_nav.dart` |
| 21 | `withOpacity()` deprecated | 🟢 LOW | 20+ files |

---

*End of Design System v2 — Revision 2 (Complete Audit)*
