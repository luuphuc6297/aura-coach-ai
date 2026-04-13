# Phase 1: Authentication & Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete auth flow (Google/Apple/Guest) and 5-step onboarding that stores user profile to Firestore, then lands on the Home screen.

**Architecture:** Feature-first Clean Architecture with Provider (ChangeNotifier) for state management. Firebase Auth handles authentication, Cloud Firestore stores user profiles. GoRouter v17+ manages navigation with auth-based redirects. SharedPreferences caches onboarding completion status locally.

**Tech Stack:** Flutter 3.x, Dart ≥3.2, Firebase Auth, Cloud Firestore, Google Sign-In, Sign in with Apple, Provider, GoRouter v17, SharedPreferences, cached_network_image, Google Fonts (Fredoka/Nunito/Inter), Cloudinary CDN for 3D clay assets.

---

## File Structure

### New Files (Phase 1)

```
lib/
├── main.dart                                    — App entry point, Firebase init
├── app.dart                                     — MultiProvider + GoRouter config
├── core/
│   ├── constants/
│   │   ├── cloudinary_assets.dart               — All Cloudinary CDN URLs
│   │   ├── topic_constants.dart                 — 16 topics with emoji URLs + IDs
│   │   └── onboarding_constants.dart            — Learning goals, daily time options
│   ├── theme/
│   │   ├── app_colors.dart                      — Color palette (cream, teal, purple, gold, etc.)
│   │   ├── app_typography.dart                  — Text styles (display, h1-h3, body, label, caption)
│   │   ├── app_shadows.dart                     — Clay shadows (depth, hover, pressed, soft, card)
│   │   ├── app_radius.dart                      — Border radii (sm, md, lg, xl, full)
│   │   ├── app_spacing.dart                     — 4px-based spacing scale (xs–xxxl)
│   │   ├── app_theme.dart                       — ThemeData combining all tokens
│   │   └── app_animations.dart                  — Duration + curve constants
│   └── utils/
│       └── error_handler.dart                   — Firebase error → user-friendly message
├── shared/
│   └── widgets/
│       ├── clay_card.dart                       — Main container (border, radius, shadow, selection)
│       ├── clay_button.dart                     — 5 variants: primary, secondary, danger, ghost, pill
│       ├── cloud_image.dart                     — CachedNetworkImage wrapper for Cloudinary
│       ├── loading_indicator.dart               — Teal circular progress
│       ├── error_banner.dart                    — Error message card
│       ├── progress_dots.dart                   — Onboarding step indicator (5 dots)
│       └── aura_logo.dart                       — "AURA C[orb]ACH.AI" logo widget
├── domain/
│   └── entities/
│       └── user_profile.dart                    — UserProfile entity (name, avatar, level, topics, goals, dailyMinutes)
├── data/
│   ├── datasources/
│   │   ├── firebase_datasource.dart             — Firestore CRUD for user profiles
│   │   └── local_datasource.dart                — SharedPreferences (onboarding flag, cached user)
│   └── repositories/
│       └── auth_repository_impl.dart            — Auth + profile persistence
├── features/
│   ├── splash/
│   │   └── screens/splash_screen.dart           — Brand intro (2-3s), session check → redirect
│   ├── auth/
│   │   ├── screens/auth_screen.dart             — Google/Apple/Guest sign-in
│   │   ├── providers/auth_provider.dart         — Auth state + method-level loading
│   │   └── widgets/auth_button.dart             — Social sign-in button (icon + text + loading)
│   ├── onboarding/
│   │   ├── screens/onboarding_screen.dart       — PageView controller for 5 steps
│   │   ├── providers/onboarding_provider.dart   — Step state, selections, Firestore save
│   │   └── widgets/
│   │       ├── step_name_avatar.dart            — Step 1: Name input + avatar grid
│   │       ├── step_level.dart                  — Step 2: Beginner/Intermediate/Advanced
│   │       ├── step_goals.dart                  — Step 3: Learning goals multi-select
│   │       ├── step_daily_time.dart             — Step 4: 5/15/30/60 minutes
│   │       └── step_topics.dart                 — Step 5: 16 topic chips + custom input
│   └── home/
│       ├── screens/home_screen.dart             — Mode carousel (4 modes) + bottom nav
│       ├── providers/home_provider.dart          — User profile loader
│       └── widgets/
│           ├── mode_card.dart                   — Full-height swipeable mode card
│           └── bottom_nav_bar.dart              — 3-tab bottom navigation
├── assets/
│   └── fonts/                                   — (empty — using google_fonts package)
├── pubspec.yaml
├── ios/Runner/Info.plist                         — URL schemes for Google Sign-In
├── android/app/build.gradle                      — minSdk, Firebase config
└── firestore.rules                               — Security rules
```

---

## Task Breakdown

### Task 1: Flutter Project Scaffold + Dependencies

**Files:**
- Create: `pubspec.yaml` (modify generated)
- Create: `lib/main.dart`
- Create: `analysis_options.yaml` (modify generated)

- [ ] **Step 1: Create Flutter project**

```bash
cd /sessions/fervent-confident-ptolemy/mnt/aura-coach-ai
flutter create --org com.auracoach --project-name aura_coach_ai .
```

Expected: Flutter project created with default files.

- [ ] **Step 2: Update pubspec.yaml with all Phase 1 dependencies**

Replace the `dependencies` and `dev_dependencies` sections in `pubspec.yaml`:

```yaml
name: aura_coach_ai
description: AI-powered English learning app with Clay Design System.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.5.1
  cloud_firestore: ^5.6.0
  google_sign_in: ^6.2.2
  sign_in_with_apple: ^6.1.4

  # State Management
  provider: ^6.4.0

  # Navigation
  go_router: ^17.0.0

  # Local Storage
  shared_preferences: ^2.3.0

  # Images & Network
  cached_network_image: ^3.4.1

  # Fonts
  google_fonts: ^7.0.0

  # Utils
  uuid: ^4.1.0
  intl: ^0.20.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
```

- [ ] **Step 3: Install dependencies**

```bash
flutter pub get
```

Expected: All packages resolve and download.

- [ ] **Step 4: Create directory structure**

```bash
mkdir -p lib/core/constants lib/core/theme lib/core/utils
mkdir -p lib/shared/widgets
mkdir -p lib/domain/entities
mkdir -p lib/data/datasources lib/data/repositories
mkdir -p lib/features/splash/screens
mkdir -p lib/features/auth/screens lib/features/auth/providers lib/features/auth/widgets
mkdir -p lib/features/onboarding/screens lib/features/onboarding/providers lib/features/onboarding/widgets
mkdir -p lib/features/home/screens lib/features/home/providers lib/features/home/widgets
```

- [ ] **Step 5: Commit scaffold**

```bash
git add -A
git commit -m "chore: scaffold Flutter project with Phase 1 dependencies and directory structure"
```

---

### Task 2: Design Tokens — Colors, Typography, Shadows, Radius, Animations

**Files:**
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_typography.dart`
- Create: `lib/core/theme/app_shadows.dart`
- Create: `lib/core/theme/app_radius.dart`
- Create: `lib/core/theme/app_spacing.dart`
- Create: `lib/core/theme/app_animations.dart`
- Create: `lib/core/theme/app_theme.dart`

- [ ] **Step 1: Create app_colors.dart**

```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Surface
  static const cream = Color(0xFFFFF8F0);
  static const clayWhite = Color(0xFFFEFCF9);
  static const clayBeige = Color(0xFFF5EDE3);
  static const clayBorder = Color(0xFFE8DFD3);
  static const clayShadow = Color(0xFFD4C9BB);

  // Text
  static const warmDark = Color(0xFF2D3047);
  static const warmMuted = Color(0xFF6B6D7B);
  static const warmLight = Color(0xFF9B9DAB);

  // Accent
  static const teal = Color(0xFF7ECEC5);
  static const purple = Color(0xFFA78BCA);
  static const gold = Color(0xFFE8C77B);

  // Semantic
  static const success = Color(0xFF7BC6A0);
  static const warning = Color(0xFFE8C77B);
  static const error = Color(0xFFD98A8A);

  // Tone Colors
  static const formalTone = Color(0xFF6366F1);
  static const neutralTone = Color(0xFF7BC6A0);
  static const friendlyTone = Color(0xFFE8C77B);
  static const casualTone = Color(0xFFD98A8A);
}
```

- [ ] **Step 2: Create app_typography.dart**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static TextStyle get displayLg => GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.warmDark,
        height: 1.2,
      );

  static TextStyle get displayMd => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.2,
      );

  static TextStyle get h1 => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.3,
      );

  static TextStyle get h2 => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.3,
      );

  static TextStyle get h3 => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.warmDark,
        height: 1.4,
      );

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.warmDark,
        height: 1.5,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.warmDark,
        height: 1.5,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.warmDark,
        height: 1.5,
      );

  static TextStyle get labelLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.4,
      );

  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.warmMuted,
        height: 1.4,
      );

  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.warmMuted,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.warmLight,
        height: 1.4,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get logo => GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      );
}
```

- [ ] **Step 3: Create app_shadows.dart**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppShadows {
  static const clay = [
    BoxShadow(color: AppColors.clayShadow, offset: Offset(3, 3)),
  ];

  static const clayHover = [
    BoxShadow(color: AppColors.clayShadow, offset: Offset(5, 5)),
  ];

  static const clayPressed = [
    BoxShadow(color: AppColors.clayShadow, offset: Offset(1, 1)),
  ];

  static const soft = [
    BoxShadow(
      color: Color(0x0F2D3047),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  static const card = [
    BoxShadow(
      color: Color(0x0A2D3047),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static const lifted = [
    BoxShadow(
      color: Color(0x1A2D3047),
      offset: Offset(0, 6),
      blurRadius: 20,
    ),
    BoxShadow(color: AppColors.clayShadow, offset: Offset(3, 3)),
  ];
}
```

- [ ] **Step 4: Create app_radius.dart**

```dart
import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 28;
  static const double full = 999;

  static final smBorder = BorderRadius.circular(sm);
  static final mdBorder = BorderRadius.circular(md);
  static final lgBorder = BorderRadius.circular(lg);
  static final xlBorder = BorderRadius.circular(xl);
  static final fullBorder = BorderRadius.circular(full);
}
```

- [ ] **Step 5: Create app_spacing.dart**

```dart
import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}
```

- [ ] **Step 6: Create app_animations.dart**

```dart
abstract final class AppAnimations {
  static const durationFast = Duration(milliseconds: 150);
  static const durationNormal = Duration(milliseconds: 300);
  static const durationSlow = Duration(milliseconds: 500);

  static const easeClay = Curves.easeInOut;
  static const easeBackOut = Curves.easeOutBack;
}
```

- [ ] **Step 7: Create app_theme.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: const ColorScheme.light(
          primary: AppColors.teal,
          secondary: AppColors.purple,
          tertiary: AppColors.gold,
          surface: AppColors.cream,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSurface: AppColors.warmDark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.cream,
          foregroundColor: AppColors.warmDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AppTypography.h3,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLg,
          displayMedium: AppTypography.displayMd,
          headlineLarge: AppTypography.h1,
          headlineMedium: AppTypography.h2,
          headlineSmall: AppTypography.h3,
          bodyLarge: AppTypography.bodyLg,
          bodyMedium: AppTypography.bodyMd,
          bodySmall: AppTypography.bodySm,
          labelLarge: AppTypography.labelLg,
          labelMedium: AppTypography.labelMd,
          labelSmall: AppTypography.labelSm,
        ),
      );
}
```

- [ ] **Step 8: Commit design tokens**

```bash
git add lib/core/theme/
git commit -m "feat: add Clay Design System tokens (colors, typography, shadows, radius, animations, theme)"
```

---

### Task 3: Constants — Cloudinary Assets, Topics, Onboarding Options

**Files:**
- Create: `lib/core/constants/cloudinary_assets.dart`
- Create: `lib/core/constants/topic_constants.dart`
- Create: `lib/core/constants/onboarding_constants.dart`

- [ ] **Step 1: Create cloudinary_assets.dart**

```dart
abstract final class CloudinaryAssets {
  static const _base = 'https://res.cloudinary.com/dgx0fr20a/image/upload';

  // Aura Orb
  static const auraOrb = '$_base/w_120,h_120,c_fill,q_90/v1774779556/aura-coach-assets/aura-orbs-icons_1ff981_b7df4e.webp';
  static const auraOrbLarge = '$_base/w_360,h_360,c_fill,q_90/v1774779556/aura-coach-assets/aura-orbs-icons_1ff981_b7df4e.webp';

  // AI Chatbot
  static const chatbot = '$_base/w_120,h_120,c_fill,q_85/v1774765004/aura-coach-assets/avatars/chat-bot-avatar_tranformed.webp';

  // Navigation
  static const navHome = '$_base/w_84,h_84,c_fill,q_85/v1774765585/aura-coach-assets/navigation-bar/home-icon_f164a9.webp';
  static const navSettings = '$_base/w_84,h_84,c_fill,q_85/v1774780351/aura-coach-assets/navigation-bar/setting-icon_42d237_cac3a9.webp';

  // Level Icons
  static const levelBeginner = '$_base/w_192,h_192,c_fill,q_90/v1774765488/aura-coach-assets/level-icons/beginner-level_8b946e.webp';
  static const levelIntermediate = '$_base/w_192,h_192,c_fill,q_90/v1774765510/aura-coach-assets/level-icons/intermediate-level_332f3d.webp';
  static const levelAdvanced = '$_base/w_192,h_192,c_fill,q_90/v1774766290/aura-coach-assets/level-icons/advanced-level_75b99f.webp';

  // Mode Icons
  static const modeScenarioCoach = '$_base/w_216,h_216,c_fill,q_90/v1774765701/aura-coach-assets/mode-icons/trophy-icon_770c25.webp';
  static const modeStory = '$_base/w_216,h_216,c_fill,q_90/v1774779261/aura-coach-assets/mode-icons/national-park-icons_628f11.webp';
  static const modeTranslator = '$_base/w_216,h_216,c_fill,q_90/v1774766467/aura-coach-assets/mode-icons/tone-translator_327cd6.webp';
  static const modeVocabHub = '$_base/w_216,h_216,c_fill,q_90/v1774779311/aura-coach-assets/mode-icons/ringed-planet-icons_bbcaa8.webp';

  // User Avatars
  static const avatarCat = '$_base/w_240,h_240,c_fill,q_90/v1774780151/aura-coach-assets/avatars/cat-avatar_83a6ce_d702ea.webp';
  static const avatarRabbit = '$_base/w_240,h_240,c_fill,q_90/v1774766456/aura-coach-assets/avatars/rabbit-avatar_004e97.webp';
  static const avatarPenguin = '$_base/w_240,h_240,c_fill,q_90/v1774766444/aura-coach-assets/avatars/penguin-avatar_c3d46f.webp';
  static const avatarFox = '$_base/w_240,h_240,c_fill,q_90/v1774780247/aura-coach-assets/avatars/fox-avatar_677f5f.webp';
  static const avatarOwl = '$_base/w_240,h_240,c_fill,q_90/v1774765533/aura-coach-assets/avatars/owl-avatar_ddeb3c.webp';
}

class AvatarOption {
  final String id;
  final String label;
  final String url;

  const AvatarOption({required this.id, required this.label, required this.url});
}

const List<AvatarOption> avatarOptions = [
  AvatarOption(id: 'cat', label: 'Cat', url: CloudinaryAssets.avatarCat),
  AvatarOption(id: 'rabbit', label: 'Bunny', url: CloudinaryAssets.avatarRabbit),
  AvatarOption(id: 'penguin', label: 'Penguin', url: CloudinaryAssets.avatarPenguin),
  AvatarOption(id: 'fox', label: 'Fox', url: CloudinaryAssets.avatarFox),
  AvatarOption(id: 'owl', label: 'Owl', url: CloudinaryAssets.avatarOwl),
];
```

- [ ] **Step 2: Create topic_constants.dart**

```dart
const _fluentBase = 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis';

class TopicOption {
  final String id;
  final String label;
  final String emojiUrl;

  const TopicOption({required this.id, required this.label, required this.emojiUrl});
}

const List<TopicOption> topicOptions = [
  TopicOption(id: 'travel', label: 'Travel', emojiUrl: '$_fluentBase/Travel%20and%20places/Airplane.png'),
  TopicOption(id: 'business', label: 'Business', emojiUrl: '$_fluentBase/Objects/Briefcase.png'),
  TopicOption(id: 'social', label: 'Social', emojiUrl: '$_fluentBase/Food/Clinking%20Glasses.png'),
  TopicOption(id: 'daily_life', label: 'Daily Life', emojiUrl: '$_fluentBase/Travel%20and%20places/House.png'),
  TopicOption(id: 'technology', label: 'Technology', emojiUrl: '$_fluentBase/Objects/Laptop.png'),
  TopicOption(id: 'education', label: 'Education', emojiUrl: '$_fluentBase/Objects/Graduation%20Cap.png'),
  TopicOption(id: 'food', label: 'Food', emojiUrl: '$_fluentBase/Food/Steaming%20Bowl.png'),
  TopicOption(id: 'healthcare', label: 'Healthcare', emojiUrl: '$_fluentBase/Travel%20and%20places/Hospital.png'),
  TopicOption(id: 'shopping', label: 'Shopping', emojiUrl: '$_fluentBase/Objects/Shopping%20Bags.png'),
  TopicOption(id: 'entertainment', label: 'Entertainment', emojiUrl: '$_fluentBase/Objects/Clapper%20Board.png'),
  TopicOption(id: 'sports', label: 'Sports', emojiUrl: '$_fluentBase/Activities/Soccer%20Ball.png'),
  TopicOption(id: 'nature', label: 'Nature', emojiUrl: '$_fluentBase/Animals/Herb.png'),
  TopicOption(id: 'finance', label: 'Finance', emojiUrl: '$_fluentBase/Objects/Money%20Bag.png'),
  TopicOption(id: 'relationships', label: 'Relationships', emojiUrl: '$_fluentBase/Smilies/Red%20Heart.png'),
  TopicOption(id: 'law', label: 'Law', emojiUrl: '$_fluentBase/Objects/Balance%20Scale.png'),
  TopicOption(id: 'real_estate', label: 'Real Estate', emojiUrl: '$_fluentBase/Objects/Key.png'),
];
```

- [ ] **Step 3: Create onboarding_constants.dart**

```dart
const _fluentBase = 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis';

class LearningGoal {
  final String id;
  final String label;
  final String description;
  final String emoji;

  const LearningGoal({
    required this.id,
    required this.label,
    required this.description,
    required this.emoji,
  });
}

const List<LearningGoal> learningGoals = [
  LearningGoal(id: 'career', label: 'Career growth', description: 'Speak confidently at work', emoji: '💼'),
  LearningGoal(id: 'travel', label: 'Travel abroad', description: 'Navigate new countries easily', emoji: '✈️'),
  LearningGoal(id: 'exam', label: 'Exam preparation', description: 'IELTS, TOEFL, Cambridge', emoji: '🎓'),
  LearningGoal(id: 'daily', label: 'Daily communication', description: 'Chat with friends & online', emoji: '🌍'),
  LearningGoal(id: 'self', label: 'Self improvement', description: 'Personal growth & learning', emoji: '🧠'),
];

class DailyTimeOption {
  final int minutes;
  final String label;
  final String description;
  final String emojiUrl;

  const DailyTimeOption({
    required this.minutes,
    required this.label,
    required this.description,
    required this.emojiUrl,
  });
}

const List<DailyTimeOption> dailyTimeOptions = [
  DailyTimeOption(minutes: 5, label: '5 minutes', description: 'Casual • Easy start', emojiUrl: '$_fluentBase/Animals/Seedling.png'),
  DailyTimeOption(minutes: 15, label: '15 minutes', description: 'Regular • Recommended', emojiUrl: '$_fluentBase/Travel%20and%20places/Fire.png'),
  DailyTimeOption(minutes: 30, label: '30 minutes', description: 'Intensive • Fast progress', emojiUrl: '$_fluentBase/Travel%20and%20places/High%20Voltage.png'),
  DailyTimeOption(minutes: 60, label: '60 minutes', description: 'Serious • Maximum results', emojiUrl: '$_fluentBase/Travel%20and%20places/Rocket.png'),
];

enum ProficiencyLevel {
  beginner('beginner', 'Beginner', 'A1 / A2', 'Basic phrases & simple sentences'),
  intermediate('intermediate', 'Intermediate', 'B1 / B2', 'Everyday conversations & complex topics'),
  advanced('advanced', 'Advanced', 'C1 / C2', 'Complex discussions & near-native fluency');

  final String id;
  final String label;
  final String cefr;
  final String description;

  const ProficiencyLevel(this.id, this.label, this.cefr, this.description);
}
```

- [ ] **Step 4: Commit constants**

```bash
git add lib/core/constants/
git commit -m "feat: add Cloudinary assets, topic constants, and onboarding option constants"
```

---

### Task 4: Core Utility — Error Handler

**Files:**
- Create: `lib/core/utils/error_handler.dart`

- [ ] **Step 1: Create error_handler.dart**

```dart
import 'package:firebase_auth/firebase_auth.dart';

String friendlyAuthError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
        return 'No account found. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/utils/
git commit -m "feat: add Firebase auth error handler with user-friendly messages"
```

---

### Task 5: Domain Entity — UserProfile

**Files:**
- Create: `lib/domain/entities/user_profile.dart`

- [ ] **Step 1: Create user_profile.dart**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String avatarId;
  final String avatarUrl;
  final String proficiencyLevel;
  final List<String> selectedGoals;
  final int dailyMinutes;
  final List<String> selectedTopics;
  final String tier;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.avatarId,
    required this.avatarUrl,
    required this.proficiencyLevel,
    required this.selectedGoals,
    required this.dailyMinutes,
    required this.selectedTopics,
    this.tier = 'free',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? '',
      avatarId: data['avatarId'] ?? 'fox',
      avatarUrl: data['avatarUrl'] ?? '',
      proficiencyLevel: data['proficiencyLevel'] ?? 'intermediate',
      selectedGoals: List<String>.from(data['selectedGoals'] ?? []),
      dailyMinutes: data['dailyMinutes'] ?? 15,
      selectedTopics: List<String>.from(data['selectedTopics'] ?? []),
      tier: data['tier'] ?? 'free',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'avatarId': avatarId,
        'avatarUrl': avatarUrl,
        'proficiencyLevel': proficiencyLevel,
        'selectedGoals': selectedGoals,
        'dailyMinutes': dailyMinutes,
        'selectedTopics': selectedTopics,
        'tier': tier,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/domain/
git commit -m "feat: add UserProfile entity with Firestore serialization"
```

---

### Task 6: Data Layer — Firebase Datasource + Local Datasource

**Files:**
- Create: `lib/data/datasources/firebase_datasource.dart`
- Create: `lib/data/datasources/local_datasource.dart`

- [ ] **Step 1: Create firebase_datasource.dart**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

class FirebaseDatasource {
  final FirebaseFirestore _db;

  FirebaseDatasource({required FirebaseFirestore db}) : _db = db;

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(
          profile.toFirestore(),
          SetOptions(merge: true),
        );
  }

  Future<bool> hasCompletedOnboarding(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    return data != null &&
        (data['name'] as String?)?.isNotEmpty == true &&
        (data['selectedTopics'] as List?)?.isNotEmpty == true;
  }
}
```

- [ ] **Step 2: Create local_datasource.dart**

```dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalDatasource {
  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyCachedUid = 'cached_uid';

  final SharedPreferences _prefs;

  LocalDatasource({required SharedPreferences prefs}) : _prefs = prefs;

  bool get isOnboardingComplete => _prefs.getBool(_keyOnboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }

  String? get cachedUid => _prefs.getString(_keyCachedUid);

  Future<void> setCachedUid(String uid) async {
    await _prefs.setString(_keyCachedUid, uid);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/data/datasources/
git commit -m "feat: add Firebase and local datasources for user profile CRUD"
```

---

### Task 7: Shared Widgets — ClayCard, ClayButton, CloudImage, LoadingIndicator, ErrorBanner, ProgressDots, AuraLogo

**Files:**
- Create: `lib/shared/widgets/clay_card.dart`
- Create: `lib/shared/widgets/clay_button.dart`
- Create: `lib/shared/widgets/cloud_image.dart`
- Create: `lib/shared/widgets/loading_indicator.dart`
- Create: `lib/shared/widgets/error_banner.dart`
- Create: `lib/shared/widgets/progress_dots.dart`
- Create: `lib/shared/widgets/aura_logo.dart`

- [ ] **Step 1: Create clay_card.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_animations.dart';

class ClayCard extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final Color selectedBorderColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;

  const ClayCard({
    super.key,
    required this.child,
    this.isSelected = false,
    this.selectedBorderColor = AppColors.teal,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.durationFast,
        curve: AppAnimations.easeClay,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.clayWhite,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: isSelected ? selectedBorderColor : AppColors.clayBorder,
            width: 2,
          ),
          boxShadow: boxShadow ?? (isSelected ? AppShadows.clay : AppShadows.card),
        ),
        child: child,
      ),
    );
  }
}
```

- [ ] **Step 2: Create clay_button.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_animations.dart';

enum ClayButtonVariant { primary, secondary, danger, ghost, pill }

class ClayButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final ClayButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;

  const ClayButton({
    super.key,
    required this.text,
    this.onTap,
    this.variant = ClayButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _isPressed = false;

  Color get _bg {
    if (widget.onTap == null) return AppColors.clayBeige;
    switch (widget.variant) {
      case ClayButtonVariant.primary:
        return AppColors.teal;
      case ClayButtonVariant.secondary:
        return AppColors.clayWhite;
      case ClayButtonVariant.danger:
        return AppColors.error;
      case ClayButtonVariant.ghost:
        return Colors.transparent;
      case ClayButtonVariant.pill:
        return AppColors.teal;
    }
  }

  Color get _fg {
    if (widget.onTap == null) return AppColors.warmLight;
    switch (widget.variant) {
      case ClayButtonVariant.primary:
      case ClayButtonVariant.danger:
      case ClayButtonVariant.pill:
        return Colors.white;
      case ClayButtonVariant.secondary:
        return AppColors.warmDark;
      case ClayButtonVariant.ghost:
        return AppColors.warmMuted;
    }
  }

  List<BoxShadow> get _shadow {
    if (widget.onTap == null || widget.variant == ClayButtonVariant.ghost) {
      return [];
    }
    if (_isPressed) return AppShadows.clayPressed;
    return AppShadows.clay;
  }

  Border? get _border {
    if (widget.variant == ClayButtonVariant.secondary) {
      return Border.all(color: AppColors.clayBorder, width: 2);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onTap,
      child: AnimatedContainer(
        duration: AppAnimations.durationFast,
        curve: AppAnimations.easeClay,
        width: widget.isFullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: widget.variant == ClayButtonVariant.pill ? 24 : 20,
          vertical: widget.variant == ClayButtonVariant.pill ? 10 : 14,
        ),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: widget.variant == ClayButtonVariant.pill
              ? AppRadius.fullBorder
              : AppRadius.lgBorder,
          border: _border,
          boxShadow: _shadow,
        ),
        child: AnimatedOpacity(
          duration: AppAnimations.durationFast,
          opacity: widget.onTap == null ? 0.5 : 1.0,
          child: Row(
            mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(_fg),
                  ),
                ),
              ] else ...[
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.text,
                  style: AppTypography.button.copyWith(color: _fg),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Create cloud_image.dart**

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';

class CloudImage extends StatelessWidget {
  final String url;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CloudImage({
    super.key,
    required this.url,
    this.size = 64,
    this.fit = BoxFit.contain,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: fit,
      placeholder: (_, __) => SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColors.teal),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => SizedBox(
        width: size,
        height: size,
        child: const Icon(Icons.broken_image, color: AppColors.warmLight),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
```

- [ ] **Step 4: Create loading_indicator.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;

  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.color = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
```

- [ ] **Step 5: Create error_banner.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(color: AppColors.error),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close, color: AppColors.error, size: 18),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Create progress_dots.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_animations.dart';

class ProgressDots extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const ProgressDots({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          final isActive = index == currentStep;
          final isDone = index < currentStep;
          return AnimatedContainer(
            duration: AppAnimations.durationNormal,
            curve: AppAnimations.easeClay,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: (isActive || isDone) ? AppColors.teal : AppColors.clayBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
```

- [ ] **Step 7: Create aura_logo.dart**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/cloudinary_assets.dart';
import 'cloud_image.dart';

class AuraLogo extends StatelessWidget {
  final double fontSize;

  const AuraLogo({super.key, this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    final orbSize = fontSize * 1.5;
    final style = GoogleFonts.fredoka(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.5,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('AURA', style: style.copyWith(color: AppColors.teal)),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('C', style: style.copyWith(color: AppColors.teal)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: CloudImage(url: CloudinaryAssets.auraOrbLarge, size: orbSize),
            ),
            Text('ACH', style: style.copyWith(color: AppColors.teal)),
            Text('.AI', style: style.copyWith(color: AppColors.warmDark, letterSpacing: 0)),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 8: Commit all shared widgets**

```bash
git add lib/shared/widgets/
git commit -m "feat: add shared widgets (ClayCard, ClayButton, CloudImage, LoadingIndicator, ErrorBanner, ProgressDots, AuraLogo)"
```

---

### Task 8: Auth Provider

**Files:**
- Create: `lib/features/auth/providers/auth_provider.dart`

- [ ] **Step 1: Create auth_provider.dart**

```dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/datasources/local_datasource.dart';
import '../../../core/utils/error_handler.dart';

enum AuthMethod { google, apple, guest }

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseDatasource _firebaseDatasource;
  final LocalDatasource _localDatasource;

  AuthMethod? _loadingMethod;
  String? _errorMessage;
  bool _hasCompletedOnboarding = false;

  AuthProvider({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required FirebaseDatasource firebaseDatasource,
    required LocalDatasource localDatasource,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        _firebaseDatasource = firebaseDatasource,
        _localDatasource = localDatasource;

  User? get currentUser => _auth.currentUser;
  AuthStatus get status {
    if (currentUser == null) return AuthStatus.unauthenticated;
    return AuthStatus.authenticated;
  }

  AuthMethod? get loadingMethod => _loadingMethod;
  bool isMethodLoading(AuthMethod method) => _loadingMethod == method;
  bool get isAnyLoading => _loadingMethod != null;
  String? get errorMessage => _errorMessage;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  Future<void> initialize() async {
    _hasCompletedOnboarding = _localDatasource.isOnboardingComplete;
    if (currentUser != null && !_hasCompletedOnboarding) {
      _hasCompletedOnboarding =
          await _firebaseDatasource.hasCompletedOnboarding(currentUser!.uid);
      if (_hasCompletedOnboarding) {
        await _localDatasource.setOnboardingComplete(true);
      }
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _loadingMethod = AuthMethod.google;
    _errorMessage = null;
    notifyListeners();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _loadingMethod = null;
        notifyListeners();
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      await _auth.signInWithCredential(credential);
      await _checkOnboarding();
    } catch (e) {
      _errorMessage = friendlyAuthError(e);
    }
    _loadingMethod = null;
    notifyListeners();
  }

  Future<void> signInWithApple() async {
    _loadingMethod = AuthMethod.apple;
    _errorMessage = null;
    notifyListeners();
    try {
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      await _auth.signInWithProvider(appleProvider);
      await _checkOnboarding();
    } catch (e) {
      _errorMessage = friendlyAuthError(e);
    }
    _loadingMethod = null;
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    _loadingMethod = AuthMethod.guest;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInAnonymously();
      await _checkOnboarding();
    } catch (e) {
      _errorMessage = friendlyAuthError(e);
    }
    _loadingMethod = null;
    notifyListeners();
  }

  Future<void> _checkOnboarding() async {
    if (currentUser == null) return;
    _hasCompletedOnboarding =
        await _firebaseDatasource.hasCompletedOnboarding(currentUser!.uid);
    if (_hasCompletedOnboarding) {
      await _localDatasource.setOnboardingComplete(true);
      await _localDatasource.setCachedUid(currentUser!.uid);
    }
  }

  void markOnboardingComplete() {
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await _localDatasource.clearAll();
    _hasCompletedOnboarding = false;
    notifyListeners();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/providers/
git commit -m "feat: add AuthProvider with Google/Apple/Guest sign-in and method-level loading"
```

---

### Task 9: Auth Screen + Auth Button Widget

**Files:**
- Create: `lib/features/auth/screens/auth_screen.dart`
- Create: `lib/features/auth/widgets/auth_button.dart`

- [ ] **Step 1: Create auth_button.dart**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isPrimary;

  const AuthButton({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
    this.isLoading = false,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isPrimary ? AppColors.clayWhite : AppColors.clayBeige;
    final fg = AppColors.warmDark;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedOpacity(
        duration: AppAnimations.durationFast,
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: AppColors.clayBorder, width: 2),
            boxShadow: AppShadows.clay,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(fg),
                  ),
                )
              else ...[
                icon,
                const SizedBox(width: 12),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create auth_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../../../shared/widgets/aura_logo.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  const AuraLogo(fontSize: 38),
                  const SizedBox(height: 12),
                  Text(
                    'Your personal AI English coach.\nLearn naturally, speak confidently.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),

                  // Google
                  AuthButton(
                    text: 'Continue with Google',
                    icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                    isLoading: auth.isMethodLoading(AuthMethod.google),
                    onTap: auth.isAnyLoading
                        ? null
                        : () => auth.signInWithGoogle(),
                  ),
                  const SizedBox(height: 12),

                  // Apple
                  AuthButton(
                    text: 'Continue with Apple',
                    icon: const Icon(Icons.apple, size: 22),
                    isLoading: auth.isMethodLoading(AuthMethod.apple),
                    onTap: auth.isAnyLoading
                        ? null
                        : () => auth.signInWithApple(),
                  ),
                  const SizedBox(height: 12),

                  // Guest
                  AuthButton(
                    text: 'Try as Guest',
                    icon: const Icon(Icons.person_outline, size: 22, color: AppColors.warmMuted),
                    isPrimary: false,
                    isLoading: auth.isMethodLoading(AuthMethod.guest),
                    onTap: auth.isAnyLoading
                        ? null
                        : () => auth.continueAsGuest(),
                  ),

                  if (auth.errorMessage != null) ...[
                    const SizedBox(height: 20),
                    ErrorBanner(
                      message: auth.errorMessage!,
                      onDismiss: auth.clearError,
                    ),
                  ],

                  const SizedBox(height: 60),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/
git commit -m "feat: add AuthScreen with Google/Apple/Guest buttons and error handling"
```

---

### Task 10: Splash Screen

**Files:**
- Create: `lib/features/splash/screens/splash_screen.dart`

- [ ] **Step 1: Create splash_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/aura_logo.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../auth/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _orbFade;
  late Animation<double> _textFade;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _orbFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeOut)),
    );

    _controller.forward();
    _initAndRedirect();
  }

  Future<void> _initAndRedirect() async {
    final auth = context.read<AuthProvider>();
    await auth.initialize();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (auth.status == AuthStatus.unauthenticated) {
      context.go('/auth');
    } else if (!auth.hasCompletedOnboarding) {
      context.go('/onboarding');
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _orbFade,
              child: const CloudImage(
                url: CloudinaryAssets.auraOrbLarge,
                size: 96,
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _textFade,
              child: const AuraLogo(fontSize: 28),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _taglineFade,
              child: Text(
                'Master English Naturally',
                style: AppTypography.bodySm.copyWith(color: AppColors.warmMuted),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: FadeTransition(
            opacity: _taglineFade,
            child: const Center(child: LoadingIndicator(size: 24)),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/splash/
git commit -m "feat: add SplashScreen with staggered fade animations and auth redirect"
```

---

### Task 11: Onboarding Provider

**Files:**
- Create: `lib/features/onboarding/providers/onboarding_provider.dart`

- [ ] **Step 1: Create onboarding_provider.dart**

```dart
import 'package:flutter/foundation.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/datasources/local_datasource.dart';
import '../../../domain/entities/user_profile.dart';

class OnboardingProvider extends ChangeNotifier {
  final FirebaseDatasource _firebaseDatasource;
  final LocalDatasource _localDatasource;

  int _currentStep = 0;
  String _name = '';
  String _selectedAvatarId = 'fox';
  String _selectedAvatarUrl = CloudinaryAssets.avatarFox;
  String _proficiencyLevel = '';
  final Set<String> _selectedGoals = {};
  int _dailyMinutes = 15;
  final Set<String> _selectedTopics = {};
  bool _isSaving = false;
  String? _errorMessage;

  OnboardingProvider({
    required FirebaseDatasource firebaseDatasource,
    required LocalDatasource localDatasource,
  })  : _firebaseDatasource = firebaseDatasource,
        _localDatasource = localDatasource;

  // Getters
  int get currentStep => _currentStep;
  String get name => _name;
  String get selectedAvatarId => _selectedAvatarId;
  String get selectedAvatarUrl => _selectedAvatarUrl;
  String get proficiencyLevel => _proficiencyLevel;
  Set<String> get selectedGoals => _selectedGoals;
  int get dailyMinutes => _dailyMinutes;
  Set<String> get selectedTopics => _selectedTopics;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  static const int totalSteps = 5;

  bool get canProceed {
    switch (_currentStep) {
      case 0:
        return _name.trim().isNotEmpty;
      case 1:
        return _proficiencyLevel.isNotEmpty;
      case 2:
        return _selectedGoals.isNotEmpty;
      case 3:
        return true; // daily time always has default
      case 4:
        return _selectedTopics.isNotEmpty;
      default:
        return false;
    }
  }

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void selectAvatar(String id, String url) {
    _selectedAvatarId = id;
    _selectedAvatarUrl = url;
    notifyListeners();
  }

  void setProficiencyLevel(String level) {
    _proficiencyLevel = level;
    notifyListeners();
  }

  void toggleGoal(String goalId) {
    if (_selectedGoals.contains(goalId)) {
      _selectedGoals.remove(goalId);
    } else {
      _selectedGoals.add(goalId);
    }
    notifyListeners();
  }

  void setDailyMinutes(int minutes) {
    _dailyMinutes = minutes;
    notifyListeners();
  }

  void toggleTopic(String topicId) {
    if (_selectedTopics.contains(topicId)) {
      _selectedTopics.remove(topicId);
    } else {
      _selectedTopics.add(topicId);
    }
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < totalSteps - 1 && canProceed) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(String uid) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final profile = UserProfile(
        uid: uid,
        name: _name.trim(),
        avatarId: _selectedAvatarId,
        avatarUrl: _selectedAvatarUrl,
        proficiencyLevel: _proficiencyLevel,
        selectedGoals: _selectedGoals.toList(),
        dailyMinutes: _dailyMinutes,
        selectedTopics: _selectedTopics.toList(),
      );
      await _firebaseDatasource.saveUserProfile(profile);
      await _localDatasource.setOnboardingComplete(true);
      await _localDatasource.setCachedUid(uid);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save profile. Please try again.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/onboarding/providers/
git commit -m "feat: add OnboardingProvider with 5-step state management and Firestore save"
```

---

### Task 12: Onboarding Step Widgets (5 steps)

**Files:**
- Create: `lib/features/onboarding/widgets/step_name_avatar.dart`
- Create: `lib/features/onboarding/widgets/step_level.dart`
- Create: `lib/features/onboarding/widgets/step_goals.dart`
- Create: `lib/features/onboarding/widgets/step_daily_time.dart`
- Create: `lib/features/onboarding/widgets/step_topics.dart`

- [ ] **Step 1: Create step_name_avatar.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../shared/widgets/cloud_image.dart';

class StepNameAvatar extends StatelessWidget {
  const StepNameAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CloudImage(
              url: CloudinaryAssets.auraOrbLarge,
              size: 100,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'What should we call you?',
            style: AppTypography.displayMd.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a name and choose your avatar',
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.clayBeige,
              borderRadius: AppRadius.lgBorder,
              border: Border.all(color: AppColors.teal, width: 2),
            ),
            child: TextField(
              onChanged: provider.setName,
              style: AppTypography.bodyMd,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.warmLight),
                border: InputBorder.none,
                icon: const Icon(Icons.edit, size: 18, color: AppColors.warmMuted),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'CHOOSE YOUR BUDDY',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.warmLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: avatarOptions.map((avatar) {
              final isSelected = provider.selectedAvatarId == avatar.id;
              return GestureDetector(
                onTap: () => provider.selectAvatar(avatar.id, avatar.url),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.teal : AppColors.clayBorder,
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: isSelected ? AppShadows.clay : AppShadows.card,
                  ),
                  child: ClipOval(
                    child: CloudImage(url: avatar.url, size: 56),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create step_level.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../../shared/widgets/cloud_image.dart';

class StepLevel extends StatelessWidget {
  const StepLevel({super.key});

  String _iconUrl(ProficiencyLevel level) {
    switch (level) {
      case ProficiencyLevel.beginner:
        return CloudinaryAssets.levelBeginner;
      case ProficiencyLevel.intermediate:
        return CloudinaryAssets.levelIntermediate;
      case ProficiencyLevel.advanced:
        return CloudinaryAssets.levelAdvanced;
    }
  }

  Color _cefrColor(ProficiencyLevel level) {
    switch (level) {
      case ProficiencyLevel.beginner:
        return AppColors.success;
      case ProficiencyLevel.intermediate:
        return AppColors.gold;
      case ProficiencyLevel.advanced:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your English level?",
            style: AppTypography.displayMd.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll personalize lessons just for you",
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
          ),
          const SizedBox(height: 28),
          ...ProficiencyLevel.values.map((level) {
            final isSelected = provider.proficiencyLevel == level.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClayCard(
                isSelected: isSelected,
                padding: const EdgeInsets.all(18),
                onTap: () => provider.setProficiencyLevel(level.id),
                child: Row(
                  children: [
                    CloudImage(url: _iconUrl(level), size: 72),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(level.label, style: AppTypography.labelLg.copyWith(fontSize: 17)),
                          const SizedBox(height: 2),
                          Text(
                            level.cefr,
                            style: AppTypography.labelSm.copyWith(
                              color: _cefrColor(level),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            level.description,
                            style: AppTypography.bodySm.copyWith(color: AppColors.warmMuted),
                          ),
                        ],
                      ),
                    ),
                    _CheckCircle(isSelected: isSelected),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool isSelected;
  const _CheckCircle({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.teal : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.teal : AppColors.clayBorder,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}
```

- [ ] **Step 3: Create step_goals.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_card.dart';

class StepGoals extends StatelessWidget {
  const StepGoals({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are your goals?',
            style: AppTypography.displayMd.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that apply',
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
          ),
          const SizedBox(height: 24),
          ...learningGoals.map((goal) {
            final isSelected = provider.selectedGoals.contains(goal.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClayCard(
                isSelected: isSelected,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                onTap: () => provider.toggleGoal(goal.id),
                child: Row(
                  children: [
                    Text(goal.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(goal.label, style: AppTypography.labelLg.copyWith(fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(
                            goal.description,
                            style: AppTypography.bodySm.copyWith(color: AppColors.warmMuted),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.teal : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppColors.teal : AppColors.clayBorder,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Create step_daily_time.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../../shared/widgets/cloud_image.dart';

class StepDailyTime extends StatelessWidget {
  const StepDailyTime({super.key});

  static const _bgColors = [
    Color(0x267BC6A0),
    Color(0x267ECEC5),
    Color(0x26E8C77B),
    Color(0x26A78BCA),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CloudImage(
              url: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Alarm%20Clock.png',
              size: 80,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'How much time daily?',
              style: AppTypography.displayMd.copyWith(fontSize: 26),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "We'll build the right plan for you",
              style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(dailyTimeOptions.length, (i) {
            final option = dailyTimeOptions[i];
            final isSelected = provider.dailyMinutes == option.minutes;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClayCard(
                isSelected: isSelected,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                onTap: () => provider.setDailyMinutes(option.minutes),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _bgColors[i],
                        borderRadius: AppRadius.mdBorder,
                      ),
                      child: Center(
                        child: CloudImage(url: option.emojiUrl, size: 32),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(option.label, style: AppTypography.labelLg.copyWith(fontSize: 17)),
                          const SizedBox(height: 2),
                          Text(
                            option.description,
                            style: AppTypography.bodySm.copyWith(color: AppColors.warmMuted),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.teal : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppColors.teal : AppColors.clayBorder,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Create step_topics.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/topic_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../shared/widgets/cloud_image.dart';

class StepTopics extends StatelessWidget {
  const StepTopics({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick your interests',
            style: AppTypography.displayMd.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll tailor scenarios to what matters to you",
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: topicOptions.map((topic) {
              final isSelected = provider.selectedTopics.contains(topic.id);
              return GestureDetector(
                onTap: () => provider.toggleTopic(topic.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.teal.withValues(alpha: 0.1) : AppColors.clayWhite,
                    borderRadius: AppRadius.fullBorder,
                    border: Border.all(
                      color: isSelected ? AppColors.teal : AppColors.clayBorder,
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow: isSelected ? AppShadows.clay : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CloudImage(url: topic.emojiUrl, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        topic.label,
                        style: AppTypography.labelMd.copyWith(
                          color: isSelected ? AppColors.teal : AppColors.warmDark,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Center(
            child: RichText(
              text: TextSpan(
                text: 'Selected: ',
                style: AppTypography.caption,
                children: [
                  TextSpan(
                    text: '${provider.selectedTopics.length} topics',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Commit all onboarding step widgets**

```bash
git add lib/features/onboarding/widgets/
git commit -m "feat: add 5 onboarding step widgets (name/avatar, level, goals, daily time, topics)"
```

---

### Task 13: Onboarding Screen (PageView Controller)

**Files:**
- Create: `lib/features/onboarding/screens/onboarding_screen.dart`

- [ ] **Step 1: Create onboarding_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/step_name_avatar.dart';
import '../widgets/step_level.dart';
import '../widgets/step_goals.dart';
import '../widgets/step_daily_time.dart';
import '../widgets/step_topics.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/progress_dots.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(
        firebaseDatasource: context.read(),
        localDatasource: context.read(),
      ),
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Consumer<OnboardingProvider>(
            builder: (context, provider, _) {
              return Column(
                children: [
                  ProgressDots(
                    totalSteps: OnboardingProvider.totalSteps,
                    currentStep: provider.currentStep,
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        StepNameAvatar(),
                        StepLevel(),
                        StepGoals(),
                        StepDailyTime(),
                        StepTopics(),
                      ],
                    ),
                  ),
                  if (provider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ErrorBanner(message: provider.errorMessage!),
                    ),
                  _BottomButtons(
                    provider: provider,
                    pageController: _pageController,
                    onAnimateToPage: _animateToPage,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BottomButtons extends StatelessWidget {
  final OnboardingProvider provider;
  final PageController pageController;
  final void Function(int) onAnimateToPage;

  const _BottomButtons({
    required this.provider,
    required this.pageController,
    required this.onAnimateToPage,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = provider.currentStep == OnboardingProvider.totalSteps - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
      child: Column(
        children: [
          ClayButton(
            text: isLastStep ? "Let's go! 🚀" : 'Continue',
            isLoading: provider.isSaving,
            onTap: provider.canProceed
                ? () async {
                    if (isLastStep) {
                      final auth = context.read<AuthProvider>();
                      final uid = auth.currentUser?.uid;
                      if (uid == null) return;
                      final success = await provider.saveProfile(uid);
                      if (success && context.mounted) {
                        auth.markOnboardingComplete();
                        context.go('/home');
                      }
                    } else {
                      provider.nextStep();
                      onAnimateToPage(provider.currentStep);
                    }
                  }
                : null,
          ),
          if (provider.currentStep > 0) ...[
            const SizedBox(height: 8),
            ClayButton(
              text: '← Back',
              variant: ClayButtonVariant.secondary,
              onTap: () {
                provider.previousStep();
                onAnimateToPage(provider.currentStep);
              },
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/onboarding/screens/
git commit -m "feat: add OnboardingScreen with PageView, step navigation, and Firestore save"
```

---

### Task 14: Home Screen (Placeholder with Mode Cards)

**Files:**
- Create: `lib/features/home/screens/home_screen.dart`
- Create: `lib/features/home/providers/home_provider.dart`
- Create: `lib/features/home/widgets/mode_card.dart`
- Create: `lib/features/home/widgets/bottom_nav_bar.dart`

- [ ] **Step 1: Create home_provider.dart**

```dart
import 'package:flutter/foundation.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../domain/entities/user_profile.dart';

class HomeProvider extends ChangeNotifier {
  final FirebaseDatasource _firebaseDatasource;

  UserProfile? _userProfile;
  bool _isLoading = false;

  HomeProvider({required FirebaseDatasource firebaseDatasource})
      : _firebaseDatasource = firebaseDatasource;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile(String uid) async {
    _isLoading = true;
    notifyListeners();
    _userProfile = await _firebaseDatasource.getUserProfile(uid);
    _isLoading = false;
    notifyListeners();
  }
}
```

- [ ] **Step 2: Create mode_card.dart**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../shared/widgets/cloud_image.dart';

class ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconUrl;
  final Color accentColor;
  final String badgeText;
  final String ctaText;
  final String quotaText;
  final List<String> tags;
  final int index;
  final int totalModes;
  final VoidCallback? onTap;

  const ModeCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.accentColor,
    required this.badgeText,
    required this.ctaText,
    required this.quotaText,
    required this.tags,
    required this.index,
    required this.totalModes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.cream, accentColor.withValues(alpha: 0.08)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.fullBorder,
            ),
            child: Text(
              badgeText,
              style: AppTypography.caption.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 2),
            ),
            child: Center(child: CloudImage(url: iconUrl, size: 80)),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppTypography.h1, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.fullBorder,
                ),
                child: Text(
                  tag,
                  style: AppTypography.labelSm.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: AppRadius.lgBorder,
                boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.4), offset: const Offset(3, 3))],
              ),
              child: Text(ctaText, style: AppTypography.button),
            ),
          ),
          const SizedBox(height: 8),
          Text(quotaText, style: AppTypography.caption),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalModes, (i) {
              return Container(
                width: i == index ? 8 : 6,
                height: i == index ? 8 : 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == index ? accentColor : AppColors.clayBorder,
                ),
              );
            }),
          ),
          if (index == 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Swipe for more modes',
                style: AppTypography.caption.copyWith(fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Create bottom_nav_bar.dart**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../core/constants/cloudinary_assets.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: const Border(top: BorderSide(color: AppColors.clayBorder, width: 2)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              imageUrl: CloudinaryAssets.navHome,
              label: 'Home',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.person,
              label: 'Profile',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              imageUrl: CloudinaryAssets.navSettings,
              label: 'Settings',
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String? imageUrl;
  final IconData? icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    this.imageUrl,
    this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageUrl != null)
            Opacity(
              opacity: isActive ? 1.0 : 0.45,
              child: CloudImage(url: imageUrl!, size: 24),
            )
          else
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.teal : AppColors.warmLight,
            ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              color: isActive ? AppColors.teal : AppColors.warmLight,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Create home_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/mode_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/aura_logo.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        context.read<HomeProvider>().loadProfile(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: PageView(
                scrollDirection: Axis.vertical,
                children: [
                  ModeCard(
                    title: 'Scenario Coach',
                    description: 'Practice real-life situations with AI roleplay. Get instant feedback on grammar, vocabulary & tone.',
                    iconUrl: CloudinaryAssets.modeScenarioCoach,
                    accentColor: AppColors.teal,
                    badgeText: 'MOST POPULAR',
                    ctaText: 'Start Practice →',
                    quotaText: '5 free sessions / day',
                    tags: ['🎯 Roleplay', '💬 4 Tones'],
                    index: 0,
                    totalModes: 4,
                  ),
                  ModeCard(
                    title: 'Story Mode',
                    description: 'Learn through interactive stories. You\'re the main character — your choices shape the narrative.',
                    iconUrl: CloudinaryAssets.modeStory,
                    accentColor: AppColors.purple,
                    badgeText: 'INTERACTIVE',
                    ctaText: 'Begin Story →',
                    quotaText: '3 free stories / day',
                    tags: ['📖 Narrative', '🎭 Choices'],
                    index: 1,
                    totalModes: 4,
                  ),
                  ModeCard(
                    title: 'Tone Translator',
                    description: 'Master the art of tone. See how one sentence sounds formal, friendly, casual & neutral.',
                    iconUrl: CloudinaryAssets.modeTranslator,
                    accentColor: AppColors.gold,
                    badgeText: 'UNIQUE',
                    ctaText: 'Translate Now →',
                    quotaText: '10 free translations / day',
                    tags: ['🎭 4 Tones', '🔊 TTS'],
                    index: 2,
                    totalModes: 4,
                  ),
                  ModeCard(
                    title: 'Vocab Hub',
                    description: 'Deep-dive into any word. Get analysis, mind maps, examples & spaced repetition flashcards.',
                    iconUrl: CloudinaryAssets.modeVocabHub,
                    accentColor: AppColors.purple,
                    badgeText: 'BUILD SKILLS',
                    ctaText: 'Explore Words →',
                    quotaText: 'Unlimited',
                    tags: ['🧠 Mind Map', '📝 Quiz'],
                    index: 3,
                    totalModes: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final profile = homeProvider.userProfile;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          const AuraLogo(fontSize: 12),
          const Spacer(),
          if (profile != null) ...[
            Text(
              'Hi, ${profile.name}',
              style: AppTypography.labelMd.copyWith(color: AppColors.warmDark),
            ),
            const SizedBox(width: 10),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.teal, width: 2),
              ),
              child: ClipOval(
                child: CloudImage(url: profile.avatarUrl, size: 32),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/
git commit -m "feat: add HomeScreen with mode carousel, bottom nav, and user profile top bar"
```

---

### Task 15: App Entry Point — main.dart + app.dart (GoRouter + MultiProvider)

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/app.dart`

- [ ] **Step 1: Create main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  runApp(AuraCoachApp(prefs: prefs));
}
```

- [ ] **Step 2: Create app.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/firebase_datasource.dart';
import 'data/datasources/local_datasource.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/home_provider.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/home/screens/home_screen.dart';

class AuraCoachApp extends StatelessWidget {
  final SharedPreferences prefs;

  const AuraCoachApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final googleSignIn = GoogleSignIn();
    final firebaseDatasource = FirebaseDatasource(db: firestore);
    final localDatasource = LocalDatasource(prefs: prefs);

    return MultiProvider(
      providers: [
        Provider<FirebaseDatasource>.value(value: firebaseDatasource),
        Provider<LocalDatasource>.value(value: localDatasource),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            auth: firebaseAuth,
            googleSignIn: googleSignIn,
            firebaseDatasource: firebaseDatasource,
            localDatasource: localDatasource,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(firebaseDatasource: firebaseDatasource),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = context.watch<AuthProvider>();
          final router = GoRouter(
            refreshListenable: authProvider,
            initialLocation: '/splash',
            redirect: (context, state) {
              final path = state.uri.path;

              // Allow splash to always render (it does its own redirect)
              if (path == '/splash') return null;

              final isLoggedIn = authProvider.currentUser != null;
              final onboardingDone = authProvider.hasCompletedOnboarding;

              if (!isLoggedIn) return '/auth';
              if (!onboardingDone && !path.startsWith('/onboarding')) {
                return '/onboarding';
              }
              if (onboardingDone && (path == '/auth' || path.startsWith('/onboarding'))) {
                return '/home';
              }
              return null;
            },
            routes: [
              GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
              GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
              GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
              GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            ],
          );

          return MaterialApp.router(
            title: 'Aura Coach AI',
            theme: AppTheme.light,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart lib/app.dart
git commit -m "feat: add app entry point with MultiProvider, GoRouter auth redirects, and Firebase init"
```

---

### Task 16: Firebase Configuration

**Files:**
- Modify: Various platform-specific files

- [ ] **Step 1: Configure Firebase (requires Firebase project to be set up)**

Note: This step requires a Firebase project. The developer must:

1. Go to https://console.firebase.google.com
2. Create project "aura-coach-ai"
3. Enable Authentication → Google, Apple, Anonymous providers
4. Enable Cloud Firestore (production mode)
5. Run FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=aura-coach-ai
```

This generates `lib/firebase_options.dart`.

- [ ] **Step 2: Deploy Firestore security rules**

Create `firestore.rules` in project root:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /conversations/{convId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /savedItems/{itemId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /mindMaps/{mapId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /usage/{date} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

- [ ] **Step 3: iOS configuration for Google Sign-In**

Add to `ios/Runner/Info.plist` inside the `<dict>` block:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Replace with REVERSED_CLIENT_ID from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

- [ ] **Step 4: Set iOS minimum deployment target**

In `ios/Podfile`, ensure:
```ruby
platform :ios, '14.0'
```

- [ ] **Step 5: Set Android minSdk**

In `android/app/build.gradle`, ensure:
```gradle
minSdk = 23
```

- [ ] **Step 6: Commit Firebase configuration**

```bash
git add firestore.rules lib/firebase_options.dart ios/ android/
git commit -m "chore: add Firebase configuration, Firestore rules, and platform settings"
```

---

### Task 17: Build Verification

- [ ] **Step 1: Run Flutter analyze**

```bash
flutter analyze
```

Expected: No errors (warnings acceptable for now).

- [ ] **Step 2: Attempt build (iOS simulator or Android)**

```bash
flutter build ios --simulator --no-codesign
```

Or for Android:
```bash
flutter build apk --debug
```

Expected: Build succeeds.

- [ ] **Step 3: Run on device/simulator**

```bash
flutter run
```

Expected: App launches, shows Splash → Auth screen. Google/Apple sign-in works (if Firebase configured). Onboarding 5 steps flow through. Profile saves to Firestore. Lands on Home screen with mode cards.

- [ ] **Step 4: Verify Firestore data**

After completing onboarding, check Firebase Console → Firestore → `users/{uid}` document has all fields:
- name, avatarId, avatarUrl, proficiencyLevel, selectedGoals, dailyMinutes, selectedTopics, tier, createdAt, updatedAt

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "chore: Phase 1 complete — auth, onboarding (5 steps), Firestore profile, home screen"
```

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | Flutter scaffold + dependencies | pubspec.yaml, main.dart |
| 2 | Design tokens (colors, typography, shadows, radius, spacing, animations, theme) | 7 files in core/theme/ |
| 3 | Constants (Cloudinary, topics, onboarding options) | 3 files in core/constants/ |
| 4 | Error handler utility | 1 file in core/utils/ |
| 5 | UserProfile entity | 1 file in domain/entities/ |
| 6 | Firebase + Local datasources | 2 files in data/datasources/ |
| 7 | Shared widgets (ClayCard, ClayButton, CloudImage, etc.) | 7 files in shared/widgets/ |
| 8 | AuthProvider | 1 file |
| 9 | AuthScreen + AuthButton | 2 files |
| 10 | SplashScreen | 1 file |
| 11 | OnboardingProvider | 1 file |
| 12 | 5 Onboarding step widgets | 5 files |
| 13 | OnboardingScreen (PageView) | 1 file |
| 14 | HomeScreen + ModeCard + BottomNav | 4 files |
| 15 | main.dart + app.dart (GoRouter + MultiProvider) | 2 files |
| 16 | Firebase configuration + Firestore rules | Platform files |
| 17 | Build verification + Firestore data check | — |

**Total: 38 new files, 17 tasks, ~1,850 lines of Dart code**
