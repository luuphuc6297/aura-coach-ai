# Aura Coach Mobile — Asset Registry v2

**Version:** 2.0  
**Date:** 2026-04-04  
**Cloudinary Cloud:** `dgx0fr20a`  
**Folder:** `aura-coach-assets/`

---

## ⚠️ CRITICAL ISSUES FROM AUDIT

### Issue 1: App Launcher Icon Not Set
The app is using the **default Flutter icon**. A custom Aura Coach launcher icon MUST be created.

**Required:**
- Source image: Aura Orb on cream (#FFF8F0) background, 1024×1024 PNG
- Tool: `flutter_launcher_icons` package
- Config in `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.3

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/launcher/aura-coach-icon.png"
  min_sdk_android: 21
  adaptive_icon_background: "#FFF8F0"
  adaptive_icon_foreground: "assets/launcher/aura-coach-foreground.png"
```

### Issue 2: Logo Brand Identity
"AURA COACH" text must incorporate the Aura Orb as the letter "O" in "COACH":
- Display as: `AURA C` + [aura-orb-inline] + `ACH`
- The orb replaces the "O" visually
- See `design-system-v2.md` Section 1 for implementation

### Issue 3: Missing GoogleService-Info.plist
Without this file, the iOS app crashes with SIGABRT. See `business-flows-v2.md` Section 2 for setup.

---

## 1. Cloudinary Transform Presets

| Preset | Params | Use Case | Physical px |
|--------|--------|----------|-------------|
| `_nav` | `w_84,h_84,c_fill,q_85` | Bottom nav icons (28dp @3x) | 84×84 |
| `_chat` | `w_120,h_120,c_fill,q_85` | Chat avatar, inline icons | 120×120 |
| `_level` | `w_192,h_192,c_fill,q_90` | Onboarding level icons (64dp @3x) | 192×192 |
| `_mode` | `w_216,h_216,c_fill,q_90` | Home mode card icons (72dp @3x) | 216×216 |
| `_avatar` | `w_240,h_240,c_fill,q_90` | User avatars (80dp @3x) | 240×240 |
| `_splash` | `w_360,h_360,c_fill,q_90` | Splash logo, large display | 360×360 |

**Format:** All assets served as `.webp` (80-90% smaller than PNG, hardware-decoded on iOS 14+/Android 5+).

---

## 2. Uploaded Assets (Verified Working)

### 2.1 Mascot / Brand

| Asset | Cloudinary Path | Status |
|-------|----------------|--------|
| Aura Orb (chat) | `aura-coach-assets/aura-orbs-icons_1ff981_b7df4e.webp` | ✅ Uploaded |
| Aura Orb (splash) | Same asset, `_splash` transform | ✅ Uploaded |
| Chatbot Avatar | `aura-coach-assets/avatars/chat-bot-avatar_tranformed.webp` | ✅ Uploaded |

### 2.2 Mode Card Icons

| Mode | Asset Name | Cloudinary Path | Status |
|------|-----------|----------------|--------|
| Scenario Coach | Trophy | `mode-icons/trophy-icon_770c25.webp` | ✅ Uploaded |
| Story Mode | National Park | `mode-icons/national-park-icons_628f11.webp` | ✅ Uploaded |
| Tone Translator | Translator | `mode-icons/tone-translator_327cd6.webp` | ✅ Uploaded |
| Vocab Hub | Ringed Planet | `mode-icons/ringed-planet-icons_bbcaa8.webp` | ✅ Uploaded |
| Vocab Quiz | High Voltage ⚡ | — | ❌ **NOT UPLOADED** |
| Live Mode | Microphone 🎙️ | — | ❌ **NOT UPLOADED** |

### 2.3 Level Icons

| Level | Asset | Status |
|-------|-------|--------|
| Beginner (A1-A2) | `level-icons/beginner-level_8b946e.webp` | ✅ Uploaded |
| Intermediate (B1-B2) | `level-icons/intermediate-level_332f3d.webp` | ✅ Uploaded |
| Advanced (C1-C2) | `level-icons/advanced-level_75b99f.webp` | ✅ Uploaded |

### 2.4 User Avatars

| Avatar | Asset | Status |
|--------|-------|--------|
| Cat | `avatars/cat-avatar_83a6ce_d702ea.webp` | ✅ Uploaded |
| Rabbit | `avatars/rabbit-avatar_004e97.webp` | ✅ Uploaded |
| Penguin | `avatars/penguin-avatar_c3d46f.webp` | ✅ Uploaded |
| Fox | `avatars/fox-avatar_677f5f.webp` | ✅ Uploaded |
| Owl | `avatars/owl-avatar_ddeb3c.webp` | ✅ Uploaded |
| Bear | — | ❌ **NOT UPLOADED** |
| Panda | — | ❌ **NOT UPLOADED** |

### 2.5 Navigation Icons

| Tab | Asset | Status |
|-----|-------|--------|
| Home | `navigation-bar/home-icon_f164a9.webp` | ✅ Uploaded |
| Setting | `navigation-bar/setting-icon_42d237_cac3a9.webp` | ✅ Uploaded |
| User Profile | — | ❌ **NOT UPLOADED** (using fallback `Icons.person_rounded`) |

---

## 3. Topic Icons (Onboarding) — Currently NOT Rendering

### 3.1 Problem
`topic_constants.dart` defines 16 topics with `fluentEmoji` fields, but `onboarding_screen.dart` Step 2 **never renders the emoji**. Users see only checkmarks and text labels — no icons.

### 3.2 Topic Icon Registry

| Topic | Emoji | Fluent Package Icon | Accent Color |
|-------|-------|---------------------|-------------|
| Travel | ✈️ | `FluentUiEmojiIcon(icon: Emojis.travelPlaces.airplane)` | `#00A4EF` |
| Business | 💼 | `FluentUiEmojiIcon(icon: Emojis.objects.briefcase)` | `#107C10` |
| Social | 👥 | `FluentUiEmojiIcon(icon: Emojis.peopleBody.bustInSilhouette)` | `#E81123` |
| Daily Life | 🏠 | `FluentUiEmojiIcon(icon: Emojis.travelPlaces.house)` | `#FFA500` |
| Technology | 💻 | `FluentUiEmojiIcon(icon: Emojis.objects.laptop)` | `#5B2C6F` |
| Food & Cooking | 🍽️ | `FluentUiEmojiIcon(icon: Emojis.foodDrink.forkAndKnife)` | `#D4860C` |
| Medical | ⚕️ | `FluentUiEmojiIcon(icon: Emojis.symbols.medicalSymbol)` | `#00A4EF` |
| Shopping | 🛍️ | `FluentUiEmojiIcon(icon: Emojis.objects.shoppingBags)` | `#E81123` |
| Entertainment | 🎬 | `FluentUiEmojiIcon(icon: Emojis.objects.clapperBoard)` | `#8661C5` |
| Sports | ⚽ | `FluentUiEmojiIcon(icon: Emojis.activities.soccerBall)` | `#107C10` |
| Education | 📚 | `FluentUiEmojiIcon(icon: Emojis.objects.books)` | `#5B2C6F` |
| Environment | 🌍 | `FluentUiEmojiIcon(icon: Emojis.travelPlaces.globeShowingEurope)` | `#107C10` |
| Finance | 💰 | `FluentUiEmojiIcon(icon: Emojis.objects.moneyBag)` | `#00A4EF` |
| Relationships | 💕 | `FluentUiEmojiIcon(icon: Emojis.smileysEmotion.twoHearts)` | `#E81123` |
| Legal | ⚖️ | `FluentUiEmojiIcon(icon: Emojis.objects.balanceScale)` | `#5B2C6F` |
| Property | 🏢 | `FluentUiEmojiIcon(icon: Emojis.travelPlaces.officeBuilding)` | `#8661C5` |

### 3.3 Implementation Options

**Option A — Platform emoji (simplest, current approach if actually rendered):**
```dart
Text(topic.fluentEmoji, style: TextStyle(fontSize: 32))
```

**Option B — Fluent UI Emoji package (matches design doc spec):**
```dart
FluentUiEmojiIcon(
  icon: topic.fluentPackageIcon,
  w: 36,
  h: 36,
)
```
Requires `fluentui_emoji_icon: ^0.0.2` (already in `pubspec.yaml`).

**Option C — Cloudinary 3D clay icons (highest quality, not yet uploaded):**
Would require generating and uploading 16 clay-style 3D topic icons to Cloudinary.

**Recommendation:** Use **Option A** (platform emoji) immediately for the fix, then upgrade to **Option C** (Cloudinary 3D) in a future sprint for visual consistency with the clay aesthetic.

---

## 4. Flutter Implementation

### 4.1 CloudImage Widget (Verified Working ✅)

Uses `cached_network_image` for automatic disk + memory caching with `memCacheWidth`/`memCacheHeight` for memory optimization. Widget is correctly implemented.

### 4.2 CloudinaryAssets Constants (Verified ✅, TODOs remaining)

```dart
class CloudinaryAssets {
  static const _base = 'https://res.cloudinary.com/dgx0fr20a/image/upload';
  // All uploaded assets correctly defined
  
  // TODOs remaining:
  // static const modeQuiz = '...high_voltage...';     // ❌ Needs upload
  // static const modeLive = '...microphone...';        // ❌ Needs upload
  // static const avatarBear = '...';                   // ❌ Needs upload
  // static const avatarPanda = '...';                  // ❌ Needs upload
  // static const navProfile = '...user_profile_v7...'; // ❌ Needs upload
}
```

---

## 5. Missing Assets — Priority Remediation

### 5.1 HIGH Priority (Blocks feature display)

| # | Asset | Type | Action Required |
|---|-------|------|-----------------|
| 1 | **App Launcher Icon** | ios/android | Generate 1024×1024 Aura Orb on cream bg, run `flutter_launcher_icons` |
| 2 | High Voltage ⚡ (Vocab Quiz mode) | mode icon | Generate clay-3D style, upload to Cloudinary |
| 3 | Microphone 🎙️ (Live mode) | mode icon | Generate clay-3D style, upload to Cloudinary |

### 5.2 MEDIUM Priority (Fallbacks exist)

| # | Asset | Type | Current Fallback | Action Required |
|---|-------|------|-----------------|-----------------|
| 4 | User Profile nav icon | nav icon | `Icons.person_rounded` | Generate clay-3D, upload |
| 5 | Bear avatar | avatar | Not in selection list | Generate clay-3D, upload |
| 6 | Panda avatar | avatar | Not in selection list | Generate clay-3D, upload |

### 5.3 LOW Priority (Enhancement)

| # | Asset | Type | Action Required |
|---|-------|------|-----------------|
| 7-22 | 16 topic icons (clay 3D) | topic | Generate matching clay-3D style for each topic |

---

## 6. iOS Build Asset Requirements

### 6.1 iOS App Icon (Required for App Store)

Generated via `flutter_launcher_icons`. Source must be:
- 1024×1024 PNG, no transparency, no rounded corners (iOS adds them)
- sRGB color space
- No alpha channel

### 6.2 Launch Screen

Currently using default `LaunchScreen.storyboard`. Should be updated to match splash screen (cream background + Aura Orb).

### 6.3 GoogleService-Info.plist

**MUST be present in `ios/Runner/` and added to Xcode target's "Copy Bundle Resources" build phase.**

Without it → native SIGABRT crash before Dart code executes.

---

*End of Asset Registry v2*
