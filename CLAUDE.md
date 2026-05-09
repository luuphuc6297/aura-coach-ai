# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Aura Coach AI — an AI-powered English learning Flutter app. Uses Firebase (auth + Firestore), Google Gemini for AI features, RevenueCat for subscriptions, and a custom "Clay Design System" for theming.

**SDK:** Dart >=3.2.0 <4.0.0, Flutter 3.29.0

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (requires .env file with API keys)
flutter run

# Format code (CI enforces this)
dart format .

# Static analysis
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Run tests with coverage
flutter test --coverage

# Regenerate localization files after editing lib/l10n/app_*.arb
flutter gen-l10n
```

A `.env` file is required at the project root (loaded via flutter_dotenv in main.dart). CI creates an empty placeholder.

## Architecture

**Feature-first organization** under `lib/features/`. Each feature has its own `providers/`, `screens/`, `widgets/`, and `models/` subdirectories.

### Layers

- **`lib/core/`** — Shared infrastructure: theme (Clay Design System), constants, services (TTS, notifications), utils
- **`lib/data/`** — Data layer: `datasources/` (Firebase, local/SharedPreferences), `repositories/` (e.g. StoryRepository with 3-layer fallback: Firestore -> cache -> bundled assets), `gemini/` (Gemini API service), `cache/`, `prompts/` (feature-specific prompt templates)
- **`lib/domain/`** — Entity models (UserProfile, etc.)
- **`lib/features/`** — Feature modules (auth, scenario, story, vocab_hub, grammar, ai_agent, subscription, etc.)
- **`lib/shared/`** — Reusable widgets (clay_button, clay_card, etc.) and custom painters (icon_registry)
- **`lib/l10n/`** — Localization (English + Vietnamese). ARB files are the source; Dart files are generated

### State Management

Provider + ChangeNotifier throughout. All providers are instantiated in `app.dart` and exposed via `MultiProvider`. Core datasources (FirebaseDatasource, GeminiService, LocalDatasource) are exposed as `Provider.value`.

### Routing

GoRouter configured in `app.dart` with auth guards (redirect unauthenticated -> `/auth`, no onboarding -> `/onboarding`). Page transitions use `fadeTransitionPage` (for go() replacements) and `slideFadeTransitionPage` (for push() navigation), defined in `core/theme/page_transitions.dart`.

### AI Integration

Gemini API calls go through `data/gemini/gemini_service.dart`. Feature-specific prompt templates live in `data/prompts/`. The service includes retry logic for transient failures and structured JSON response schemas.

### Subscription

RevenueCat SDK is configured early in `main()` (before Provider lifecycle). `SubscriptionProvider` syncs Firebase UID with RevenueCat appUserID. Entitlement: "Aura Coach Pro".

## Conventions

- Linting: `package:flutter_lints/flutter.yaml` + `prefer_const_constructors`, `prefer_const_declarations`, `avoid_print`
- i18n: Two locales (en, vi). Edit `lib/l10n/app_en.arb` / `app_vi.arb`, then run `flutter gen-l10n`
- Theme: Light/dark modes via `AppTheme.light` / `AppTheme.dark` in `core/theme/app_theme.dart`. Primary color is teal. Use semantic tokens from `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`
- Auth provider import is aliased: `import '...auth_provider.dart' as app;` to avoid collision with Firebase's AuthProvider
