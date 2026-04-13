# Aura Coach Mobile — Asset Registry (Production)

> **Cloud:** Cloudinary `dgx0fr20a` · **Folder:** `aura-coach-assets/` · **Format:** WebP
> **Related:** [`business-flows.md`](./aura-coach-mobile-business-flows.md) · [`design-system.md`](./aura-coach-mobile-design-system.md) · [`wireframes.jsx`](./aura-coach-mobile-wireframes.jsx)

---

## Table of Contents

1. [Clay 3D Icons (Cloudinary)](#1-clay-3d-icons-cloudinary)
   - 1.1 App Mascot / Brand Icon
   - 1.2 Mode Card Icons
   - 1.3 Level Icons (CEFR)
   - 1.4 User Default Avatars
   - 1.5 Navigation Icons
   - 1.6 Logo
2. [Topic Icons (16 Topics — Onboarding)](#2-topic-icons-16-topics--onboarding)
3. [UI Icons (Lucide → Flutter)](#3-ui-icons-lucide--flutter)
4. [Dimension Specs Summary](#4-dimension-specs-summary)
5. [Flutter Implementation](#5-flutter-implementation)
   - 5.1 Dependencies
   - 5.2 CloudinaryAssets Constants
   - 5.3 Topic Constants
   - 5.4 CloudImage Widget
6. [Gap Analysis](#6-gap-analysis)

---

## 1. Clay 3D Icons (Cloudinary)

All clay 3D icons are hosted on Cloudinary with WebP format and on-the-fly transforms.

**Base URL:** `https://res.cloudinary.com/dgx0fr20a/image/upload`

**Transform Presets:**

| Preset | Params | Use Case |
|--------|--------|----------|
| Nav | `w_84,h_84,c_fill,q_85` | Bottom navigation bar |
| Chat | `w_120,h_120,c_fill,q_85` | Chat bot avatar |
| Level | `w_192,h_192,c_fill,q_90` | CEFR level selection |
| Mode | `w_216,h_216,c_fill,q_90` | Mode card icons |
| Avatar | `w_240,h_240,c_fill,q_90` | User avatars |
| Splash | `w_360,h_360,c_fill,q_90` | Logo on splash screen |

### 1.1 App Mascot / Brand Icon

| ID | Asset | Cloudinary URL | Display | @3x |
|----|-------|---------------|---------|-----|
| `aura_orb` | Aura Orb (mascot) | [`aura-orbs-icons`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774779556/aura-coach-assets/aura-orbs-icons_1ff981_b7df4e.webp) | 40–120 dp | 120–360 px |
| `chatbot` | Chat Bot Avatar | [`chat-bot-avatar`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774765004/aura-coach-assets/avatars/chat-bot-avatar_tranformed.webp) | 36–40 dp | 120 px |

> **Note:** Aura Orb replaces Globe as the app logo. No separate Globe asset needed.

### 1.2 Mode Card Icons

| ID | Mode | Cloudinary URL | Display | @3x | Status |
|----|------|---------------|---------|-----|--------|
| `trophy` | Scenario Coach | [`trophy-icon`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774765701/aura-coach-assets/mode-icons/trophy-icon_770c25.webp) | 56–72 dp | 216 px | ✅ |
| `national_park` | Story Mode | [`national-park-icons`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774779261/aura-coach-assets/mode-icons/national-park-icons_628f11.webp) | 56–72 dp | 216 px | ✅ |
| `sparkles` | Tone Translator | [`tone-translator`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774766467/aura-coach-assets/mode-icons/tone-translator_327cd6.webp) | 56–72 dp | 216 px | ✅ |
| `ringed_planet` | Vocab Hub | [`ringed-planet-icons`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774779311/aura-coach-assets/mode-icons/ringed-planet-icons_bbcaa8.webp) | 56–72 dp | 216 px | ✅ |
| `high_voltage` | Vocab Quiz | ❌ **Not uploaded** | 56–72 dp | 216 px | 🔴 |
| `microphone` | Live Mode | ❌ **Not uploaded** | 56–72 dp | 216 px | 🔴 |

### 1.3 Level Icons (CEFR)

| ID | Level | Cloudinary URL | Display | @3x |
|----|-------|---------------|---------|-----|
| `beginner` | A1-A2 | [`beginner-level`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774765488/aura-coach-assets/level-icons/beginner-level_8b946e.webp) | 48–64 dp | 192 px |
| `intermediate` | B1-B2 | [`intermediate-level`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774765510/aura-coach-assets/level-icons/intermediate-level_332f3d.webp) | 48–64 dp | 192 px |
| `advanced` | C1-C2 | [`advanced-level`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774766290/aura-coach-assets/level-icons/advanced-level_75b99f.webp) | 48–64 dp | 192 px |

### 1.4 User Default Avatars

| ID | Animal | Cloudinary URL | Display | @3x | Status |
|----|--------|---------------|---------|-----|--------|
| `cat` | Cat | [`cat-avatar`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774780151/aura-coach-assets/avatars/cat-avatar_83a6ce_d702ea.webp) | 64–80 dp | 240 px | ✅ |
| `rabbit` | Bunny | [`rabbit-avatar`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774766456/aura-coach-assets/avatars/rabbit-avatar_004e97.webp) | 64–80 dp | 240 px | ✅ |
| `penguin` | Penguin | [`penguin-avatar`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774766444/aura-coach-assets/avatars/penguin-avatar_c3d46f.webp) | 64–80 dp | 240 px | ✅ |
| `fox` | Fox | [`fox-avatar`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774780247/aura-coach-assets/avatars/fox-avatar_677f5f.webp) | 64–80 dp | 240 px | ✅ |
| `owl` | Owl | [`owl-avatar`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774765533/aura-coach-assets/avatars/owl-avatar_ddeb3c.webp) | 64–80 dp | 240 px | ✅ |
| `bear` | Bear | ❌ **Not uploaded** | 64–80 dp | 240 px | 🟡 |
| `panda` | Panda | ❌ **Not uploaded** | 64–80 dp | 240 px | 🟡 |

> **Migration note:** Web codebase uses DiceBear micah avatars (SVG). Mobile uses custom clay 3D animal avatars (WebP via Cloudinary).

### 1.5 Navigation Icons (3-Tab Bottom Nav)

| ID | Tab | Cloudinary URL | Display | @3x | Status |
|----|-----|---------------|---------|-----|--------|
| `home` | Home | [`home-icon`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774765585/aura-coach-assets/navigation-bar/home-icon_f164a9.webp) | 24–28 dp | 84 px | ✅ |
| `settings` | Setting | [`setting-icon`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774780351/aura-coach-assets/navigation-bar/setting-icon_42d237_cac3a9.webp) | 24–28 dp | 84 px | ✅ |
| `user_profile` | User | ❌ **Needs regen v7 + upload** | 24–28 dp | 84 px | 🟡 |

### 1.6 Logo

| ID | Context | Cloudinary URL | Display | @3x |
|----|---------|---------------|---------|-----|
| `logo_header` | AppBar header | [`aura-orbs-icons`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774779556/aura-coach-assets/aura-orbs-icons_1ff981_b7df4e.webp) | 32–40 dp | 120 px |
| `logo_splash` | Splash screen | [`aura-orbs-icons`](https://res.cloudinary.com/dgx0fr20a/image/upload/v1774779556/aura-coach-assets/aura-orbs-icons_1ff981_b7df4e.webp) | 80–120 dp | 360 px |

> Logo = Aura Orb at different transform sizes. Same base asset.

---

## 2. Topic Icons (16 Topics — Onboarding)

### Strategy

Web codebase uses **Animated Fluent Emojis** (GitHub-hosted PNG). For Flutter:

| Phase | Approach | Package | Status |
|-------|----------|---------|--------|
| **v1 (Launch)** | 3D static Fluent emojis | `fluentui_emoji_icon` | ✅ Recommended |
| **v2 (Future)** | Custom clay 3D icons on Cloudinary | Custom generation | Planned |

### Topic → Icon Mapping (16 topics)

| # | ID | Label | Fluent Icon | Emoji Fallback |
|---|-----|-------|------------|----------------|
| 1 | `travel` | Travel & Survival | `Fluent.airplane_3d` | ✈️ |
| 2 | `business` | Business & Work | `Fluent.briefcase_3d` | 💼 |
| 3 | `social` | Socializing | `Fluent.clinking_glasses_3d` | 🥂 |
| 4 | `daily` | Daily Life | `Fluent.house_3d` | 🏠 |
| 5 | `tech` | Technology | `Fluent.laptop_3d` | 💻 |
| 6 | `food` | Food & Dining | `Fluent.steaming_bowl_3d` | 🍜 |
| 7 | `medical` | Medical & Health | `Fluent.hospital_3d` | 🏥 |
| 8 | `shopping` | Shopping & Fashion | `Fluent.shopping_bags_3d` | 🛍️ |
| 9 | `entertainment` | Movies & Music | `Fluent.clapper_board_3d` | 🎬 |
| 10 | `sports` | Sports & Fitness | `Fluent.soccer_ball_3d` | ⚽ |
| 11 | `education` | Education & Academic | `Fluent.graduation_cap_3d` | 🎓 |
| 12 | `environment` | Nature & Environment | `Fluent.herb_3d` | 🌿 |
| 13 | `finance` | Money & Finance | `Fluent.money_bag_3d` | 💰 |
| 14 | `relationships` | Love & Relationships | `Fluent.red_heart_3d` | ❤️ |
| 15 | `legal` | Law & Politics | `Fluent.balance_scale_3d` | ⚖️ |
| 16 | `property` | Housing & Real Estate | `Fluent.key_3d` | 🔑 |

**Display Specs:** 32–40 dp (in grid chips), @3x = 120 px, from package assets (built-in).

---

## 3. UI Icons (Lucide React → Flutter)

**Package:** `flutter_lucide: ^1.6.0`

```dart
import 'package:flutter_lucide/flutter_lucide.dart';
Icon(LucideIcons.send, size: 20, color: AppColors.tealClay)
```

### Full Mapping: React → Flutter

**Navigation & Layout**

| Web (lucide-react) | Flutter (flutter_lucide) | Used In |
|--------------------|------------------------|---------|
| `PanelLeft` | `LucideIcons.panel_left` | ModeSwitcher |
| `PanelLeftClose` | `LucideIcons.panel_left_close` | Sidebar |
| `ArrowLeft` | `LucideIcons.arrow_left` | Back navigation |
| `ArrowRight` | `LucideIcons.arrow_right` | Flashcards, Onboarding |
| `ChevronRight` | `LucideIcons.chevron_right` | List items |

**Chat & Messaging**

| Web | Flutter | Used In |
|-----|---------|---------|
| `Send` | `LucideIcons.send` | ChatInput |
| `MessageSquare` | `LucideIcons.message_square` | ConversationHistory |
| `MessageSquareQuote` | `LucideIcons.message_square_quote` | Tone variations |
| `MessageCircle` | `LucideIcons.message_circle` | Neutral tone |
| `Bot` | `LucideIcons.bot` | LoadingBubble |

**Audio & Voice**

| Web | Flutter | Used In |
|-----|---------|---------|
| `Mic` | `LucideIcons.mic` | ChatInput, Live |
| `MicOff` | `LucideIcons.mic_off` | Live muted |
| `Volume2` | `LucideIcons.volume_2` | Audio playback |

**Learning & Content**

| Web | Flutter | Used In |
|-----|---------|---------|
| `BookOpen` | `LucideIcons.book_open` | Flashcards, VocabHub |
| `BrainCircuit` | `LucideIcons.brain_circuit` | ModeSwitcher |
| `Languages` | `LucideIcons.languages` | ModeSwitcher |
| `Lightbulb` | `LucideIcons.lightbulb` | ProgressiveHint |
| `Network` | `LucideIcons.network` | MindMap tab |
| `Library` | `LucideIcons.library` | VocabHub |
| `Tag` | `LucideIcons.tag` | Tags, SavedItems |
| `Bookmark` | `LucideIcons.bookmark` | SavedItems |

**Actions & State**

| Web | Flutter | Used In |
|-----|---------|---------|
| `Search` | `LucideIcons.search` | Search bars |
| `Plus` | `LucideIcons.plus` | Add actions |
| `Check` | `LucideIcons.check` | Selection |
| `CheckCircle` | `LucideIcons.check_circle` | Success |
| `XCircle` | `LucideIcons.x_circle` | Error |
| `X` | `LucideIcons.x` | Close/dismiss |
| `RefreshCw` | `LucideIcons.refresh_cw` | Retry/refresh |
| `RotateCcw` | `LucideIcons.rotate_ccw` | Reset |
| `Loader` | `LucideIcons.loader` + animation | Loading states |
| `Download` | `LucideIcons.download` | Export |
| `Save` | `LucideIcons.save` | Save action |
| `Edit2` | `LucideIcons.edit_2` | Edit action |
| `Trash2` | `LucideIcons.trash_2` | Delete |
| `Play` | `LucideIcons.play` | Audio play |
| `Sparkles` | `LucideIcons.sparkles` | AI indicator |

**User & Profile**

| Web | Flutter | Used In |
|-----|---------|---------|
| `User` | `LucideIcons.user` | Profile |
| `UserPen` | `LucideIcons.user_pen` | Edit profile |
| `Users` | `LucideIcons.users` | Dialogue list |
| `Award` | `LucideIcons.award` | Achievements |
| `Activity` | `LucideIcons.activity` | Progress stats |
| `LogOut` | `LucideIcons.log_out` | Logout |
| `UserPlus` | `LucideIcons.user_plus` | Register |

**Auth & System**

| Web | Flutter | Used In |
|-----|---------|---------|
| `Mail` | `LucideIcons.mail` | Email input |
| `Lock` | `LucideIcons.lock` | Password input |
| `LogIn` | `LucideIcons.log_in` | Login |
| `Bell` | `LucideIcons.bell` | Notifications |
| `Settings` | `LucideIcons.settings` | Settings |
| `History` | `LucideIcons.history` | History |
| `Clock` | `LucideIcons.clock` | Timestamps |
| `ListFilter` | `LucideIcons.list_filter` | Filter |
| `AlertCircle` | `LucideIcons.alert_circle` | Warning |
| `AlertTriangle` | `LucideIcons.alert_triangle` | Danger |
| `Info` | `LucideIcons.info` | Info tooltip |

**Tone Icons**

| Web | Flutter | Tone |
|-----|---------|------|
| `Briefcase` | `LucideIcons.briefcase` | Formal |
| `MessageCircle` | `LucideIcons.message_circle` | Neutral |
| `Smile` | `LucideIcons.smile` | Friendly |
| `Coffee` | `LucideIcons.coffee` | Casual |

### Display Specs — UI Icons

| Context | Size (dp) | Color |
|---------|-----------|-------|
| Nav bar active | 24 | `teal-clay` (#7ECEC5) |
| Nav bar inactive | 24 | `warm-muted` (#6B6D7B) |
| Action buttons | 18–20 | `warm-dark` (#2D3047) |
| Inline text | 14–16 | inherit |
| Floating buttons | 20–24 | `white` on teal bg |

---

## 4. Dimension Specs Summary

| Category | Icon Type | Logical (dp) | @3x (px) | Quality | Source |
|----------|-----------|-------------|----------|---------|--------|
| Nav bar (clay) | 3D clay | 24–28 | 84 | q_85 | Cloudinary |
| Nav bar (UI) | Vector | 24 | — | — | `flutter_lucide` |
| Chat avatar | 3D clay | 36–40 | 120 | q_85 | Cloudinary |
| Topic chips | 3D fluent | 32–40 | 120 | — | `fluentui_emoji_icon` |
| Level icons | 3D clay | 48–64 | 192 | q_90 | Cloudinary |
| Mode cards | 3D clay | 56–72 | 216 | q_90 | Cloudinary |
| User avatars | 3D clay | 64–80 | 240 | q_90 | Cloudinary |
| Logo (header) | 3D clay | 32–40 | 120 | q_90 | Cloudinary |
| Logo (splash) | 3D clay | 80–120 | 360 | q_90 | Cloudinary |
| UI actions | Vector | 14–24 | — | — | `flutter_lucide` |

---

## 5. Flutter Implementation

### 5.1 Dependencies

```yaml
# pubspec.yaml
dependencies:
  # 3D Clay icons (Cloudinary hosted)
  cached_network_image: ^3.4.1

  # UI vector icons (replaces lucide-react)
  flutter_lucide: ^1.6.0

  # Topic icons (replaces Animated Fluent Emojis)
  fluentui_emoji_icon: ^1.2.0  # 3D static
```

### 5.2 CloudinaryAssets Constants

```dart
// lib/core/constants/cloudinary_assets.dart

class CloudinaryAssets {
  CloudinaryAssets._();

  static const _base = 'https://res.cloudinary.com/dgx0fr20a/image/upload';

  // ── Transform Presets ──
  static const _nav = 'w_84,h_84,c_fill,q_85';
  static const _chat = 'w_120,h_120,c_fill,q_85';
  static const _level = 'w_192,h_192,c_fill,q_90';
  static const _mode = 'w_216,h_216,c_fill,q_90';
  static const _avatar = 'w_240,h_240,c_fill,q_90';
  static const _splash = 'w_360,h_360,c_fill,q_90';

  // ═══ MASCOT ═══
  static const auraOrbChat =
      '$_base/$_chat/v1774779556/aura-coach-assets/aura-orbs-icons_1ff981_b7df4e.webp';
  static const auraOrbLarge =
      '$_base/$_splash/v1774779556/aura-coach-assets/aura-orbs-icons_1ff981_b7df4e.webp';
  static const chatbotAvatar =
      '$_base/$_chat/v1774765004/aura-coach-assets/avatars/chat-bot-avatar_tranformed.webp';

  // ═══ MODE CARDS ═══
  static const modeScenarioCoach =
      '$_base/$_mode/v1774765701/aura-coach-assets/mode-icons/trophy-icon_770c25.webp';
  static const modeStory =
      '$_base/$_mode/v1774779261/aura-coach-assets/mode-icons/national-park-icons_628f11.webp';
  static const modeTranslator =
      '$_base/$_mode/v1774766467/aura-coach-assets/mode-icons/tone-translator_327cd6.webp';
  static const modeVocabHub =
      '$_base/$_mode/v1774779311/aura-coach-assets/mode-icons/ringed-planet-icons_bbcaa8.webp';
  // TODO: static const modeQuiz = '...high_voltage...';
  // TODO: static const modeLive = '...microphone...';

  // ═══ LEVELS ═══
  static const levelBeginner =
      '$_base/$_level/v1774765488/aura-coach-assets/level-icons/beginner-level_8b946e.webp';
  static const levelIntermediate =
      '$_base/$_level/v1774765510/aura-coach-assets/level-icons/intermediate-level_332f3d.webp';
  static const levelAdvanced =
      '$_base/$_level/v1774766290/aura-coach-assets/level-icons/advanced-level_75b99f.webp';

  static String levelIcon(String cefr) => switch (cefr) {
        'A1-A2' => levelBeginner,
        'B1-B2' => levelIntermediate,
        'C1-C2' => levelAdvanced,
        _ => levelBeginner,
      };

  // ═══ USER AVATARS ═══
  static const avatarCat =
      '$_base/$_avatar/v1774780151/aura-coach-assets/avatars/cat-avatar_83a6ce_d702ea.webp';
  static const avatarRabbit =
      '$_base/$_avatar/v1774766456/aura-coach-assets/avatars/rabbit-avatar_004e97.webp';
  static const avatarPenguin =
      '$_base/$_avatar/v1774766444/aura-coach-assets/avatars/penguin-avatar_c3d46f.webp';
  static const avatarFox =
      '$_base/$_avatar/v1774780247/aura-coach-assets/avatars/fox-avatar_677f5f.webp';
  static const avatarOwl =
      '$_base/$_avatar/v1774765533/aura-coach-assets/avatars/owl-avatar_ddeb3c.webp';
  // TODO: static const avatarBear = '...';
  // TODO: static const avatarPanda = '...';

  static const allAvatars = <({String id, String label, String url})>[
    (id: 'cat', label: 'Cat', url: avatarCat),
    (id: 'rabbit', label: 'Bunny', url: avatarRabbit),
    (id: 'penguin', label: 'Penguin', url: avatarPenguin),
    (id: 'fox', label: 'Fox', url: avatarFox),
    (id: 'owl', label: 'Owl', url: avatarOwl),
  ];

  // ═══ NAVIGATION (3-tab bottom nav) ═══
  static const navHome =
      '$_base/$_nav/v1774765585/aura-coach-assets/navigation-bar/home-icon_f164a9.webp';
  static const navSettings =
      '$_base/$_nav/v1774780351/aura-coach-assets/navigation-bar/setting-icon_42d237_cac3a9.webp';
  // TODO: static const navProfile = '...user_profile_v7...';

  // ═══ LOGO (= Aura Orb at different sizes) ═══
  static const logoHeader =
      '$_base/$_nav/v1774779556/aura-coach-assets/aura-orbs-icons_1ff981_b7df4e.webp';
  static const logoSplash =
      '$_base/$_splash/v1774779556/aura-coach-assets/aura-orbs-icons_1ff981_b7df4e.webp';
}
```

### 5.3 Topic Constants

```dart
// lib/core/constants/topic_constants.dart

import 'package:flutter/material.dart';

class TopicItem {
  final String id;
  final String label;
  final String fluentEmoji;
  final String fallbackEmoji;
  final Color accentColor;

  const TopicItem({
    required this.id,
    required this.label,
    required this.fluentEmoji,
    required this.fallbackEmoji,
    required this.accentColor,
  });
}

const onboardingTopics = <TopicItem>[
  TopicItem(id: 'travel', label: 'Travel & Survival', fluentEmoji: 'airplane', fallbackEmoji: '✈️', accentColor: Color(0xFF10B981)),
  TopicItem(id: 'business', label: 'Business & Work', fluentEmoji: 'briefcase', fallbackEmoji: '💼', accentColor: Color(0xFF3B82F6)),
  TopicItem(id: 'social', label: 'Socializing', fluentEmoji: 'clinking_glasses', fallbackEmoji: '🥂', accentColor: Color(0xFFF43F5E)),
  TopicItem(id: 'daily', label: 'Daily Life', fluentEmoji: 'house', fallbackEmoji: '🏠', accentColor: Color(0xFFF59E0B)),
  TopicItem(id: 'tech', label: 'Technology', fluentEmoji: 'laptop', fallbackEmoji: '💻', accentColor: Color(0xFF6366F1)),
  TopicItem(id: 'food', label: 'Food & Dining', fluentEmoji: 'steaming_bowl', fallbackEmoji: '🍜', accentColor: Color(0xFFF97316)),
  TopicItem(id: 'medical', label: 'Medical & Health', fluentEmoji: 'hospital', fallbackEmoji: '🏥', accentColor: Color(0xFF06B6D4)),
  TopicItem(id: 'shopping', label: 'Shopping & Fashion', fluentEmoji: 'shopping_bags', fallbackEmoji: '🛍️', accentColor: Color(0xFFEC4899)),
  TopicItem(id: 'entertainment', label: 'Movies & Music', fluentEmoji: 'clapper_board', fallbackEmoji: '🎬', accentColor: Color(0xFF8B5CF6)),
  TopicItem(id: 'sports', label: 'Sports & Fitness', fluentEmoji: 'soccer_ball', fallbackEmoji: '⚽', accentColor: Color(0xFFEF4444)),
  TopicItem(id: 'education', label: 'Education & Academic', fluentEmoji: 'graduation_cap', fallbackEmoji: '🎓', accentColor: Color(0xFF2563EB)),
  TopicItem(id: 'environment', label: 'Nature & Environment', fluentEmoji: 'herb', fallbackEmoji: '🌿', accentColor: Color(0xFF22C55E)),
  TopicItem(id: 'finance', label: 'Money & Finance', fluentEmoji: 'money_bag', fallbackEmoji: '💰', accentColor: Color(0xFF059669)),
  TopicItem(id: 'relationships', label: 'Love & Relationships', fluentEmoji: 'red_heart', fallbackEmoji: '❤️', accentColor: Color(0xFFE11D48)),
  TopicItem(id: 'legal', label: 'Law & Politics', fluentEmoji: 'balance_scale', fallbackEmoji: '⚖️', accentColor: Color(0xFF64748B)),
  TopicItem(id: 'property', label: 'Housing & Real Estate', fluentEmoji: 'key', fallbackEmoji: '🔑', accentColor: Color(0xFFD97706)),
];
```

### 5.4 CloudImage Widget

```dart
// lib/core/widgets/cloud_image.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CloudImage extends StatelessWidget {
  final String url;
  final double size;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? error;

  const CloudImage({
    super.key,
    required this.url,
    required this.size,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: fit,
      memCacheWidth: (size * dpr).toInt(),
      memCacheHeight: (size * dpr).toInt(),
      placeholder: (_, __) =>
          placeholder ?? SizedBox(width: size, height: size),
      errorWidget: (_, __, ___) =>
          error ??
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EDE3),
              borderRadius: BorderRadius.circular(size / 4),
            ),
            child: Icon(Icons.image_not_supported_outlined, size: size * 0.4),
          ),
    );
  }
}
```

---

## 6. Gap Analysis

### Assets Not Yet on Cloudinary

| # | Asset | Action | Priority |
|---|-------|--------|----------|
| 1 | High Voltage (Vocab Quiz mode) | Generate + Upload | 🔴 High |
| 2 | Microphone (Live mode) | Generate + Upload | 🔴 High |
| 3 | Bear avatar | Generate + Upload | 🟡 Medium |
| 4 | Panda avatar | Generate + Upload | 🟡 Medium |
| 5 | User Profile icon v7 (nav bar) | Generate + Upload | 🟡 Medium |
| | **Total missing** | **5 assets** | |

### Flutter Packages Required

| Package | Replaces | Priority |
|---------|----------|----------|
| `flutter_lucide: ^1.6.0` | Lucide React (~52 icons) | 🔴 High |
| `fluentui_emoji_icon: ^1.2.0` | Animated Fluent Emojis (16 topics) | 🔴 High |
| `cached_network_image: ^3.4.1` | Image loading + disk cache | 🔴 High |
