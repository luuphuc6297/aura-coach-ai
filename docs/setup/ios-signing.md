# iOS Signing & Capabilities Setup

**Status:** Build currently bypasses Apple Sign-In capability so a Personal Apple Team (free tier) can build to device. **Sign in with Apple will not function** until the steps below are completed.

## Why Apple Sign-In is disabled in the project right now

The `sign_in_with_apple` plugin requires the `com.apple.developer.applesignin` entitlement. Apple [restricts this capability](https://developer.apple.com/documentation/sign_in_with_apple) to teams enrolled in the paid **Apple Developer Program** ($99/year). Personal teams will fail with:

```
Cannot create a iOS App Development provisioning profile for "com.auracoach.auraCoachAi".
Personal development teams, including "Luu Phuc", do not support the
Sign In with Apple capability.
```

We removed the `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;` reference from `Runner.xcodeproj/project.pbxproj` (3 build configs: Debug, Profile, Release) so the build no longer requests the capability. The entitlements file `ios/Runner/Runner.entitlements` is still in the repo, ready to wire back when enrollment is active.

## What still works on a Personal team

- ✅ Local builds to simulator + real device
- ✅ Google Sign-In
- ✅ Anonymous auth, Firestore, all Gemini calls
- ✅ TestFlight once enrolled — but **not** App Store distribution

## What does NOT work until enrolled

- ❌ Sign in with Apple button (the `signInWithApple()` call will throw `ASAuthorizationError`)
- ❌ Push notifications via APNs (none used yet, but `flutter_local_notifications` doesn't need APNs)
- ❌ Submit to App Store / TestFlight
- ❌ App Store Connect access for IAP product config (RevenueCat needs this)

## Re-enabling Apple Sign-In after Apple Developer Program enrollment

### Step 1 — Enroll
Go to https://developer.apple.com/programs/ → click **Enroll** → pay $99 → wait 24-48h for approval.

### Step 2 — Add capability in App Store Connect
1. https://developer.apple.com/account/resources/identifiers/list → click your bundle id `com.auracoach.auraCoachAi`.
2. Toggle **Sign In with Apple** → save.
3. Regenerate the provisioning profile (Xcode auto-managed signing handles this if "Automatically manage signing" is on).

### Step 3 — Re-wire entitlements in Xcode project

Open `ios/Runner.xcodeproj/project.pbxproj` and add this line back to **all three** Runner build configurations (Debug, Profile, Release). The line should appear right above each `PRODUCT_BUNDLE_IDENTIFIER = com.auracoach.auraCoachAi;` (NOT the RunnerTests one):

```
				CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;
```

There are 3 places to add this — search for `PRODUCT_BUNDLE_IDENTIFIER = com.auracoach.auraCoachAi;` (without `.RunnerTests`). Each Runner config needs its own line.

Or in Xcode UI:
1. `open ios/Runner.xcworkspace`
2. Select Runner target → Signing & Capabilities tab.
3. Click `+ Capability` → **Sign in with Apple**.
4. Xcode will add `CODE_SIGN_ENTITLEMENTS` to all configs and regenerate the provisioning profile automatically.

### Step 4 — Verify

```bash
flutter clean
flutter build ios --release
```

If Xcode shows `Error: Provisioning profile doesn't include the Sign In with Apple capability`, redo the Identifier toggle in Step 2 → wait 5 min for Apple's CDN to propagate → rebuild.

## Bundle id mismatch warning

Project bundle id is `com.auracoach.auraCoachAi` (camelCase). Some Firebase Console / RevenueCat setups expect lowercase variations like `com.auracoach.aura_coach_ai`. Verify both match exactly before submitting.

Current places where the bundle id appears:
- `ios/Runner.xcodeproj/project.pbxproj` — `PRODUCT_BUNDLE_IDENTIFIER`
- `ios/Runner/GoogleService-Info.plist` — `BUNDLE_ID`
- Firebase Console iOS app config
- App Store Connect → Identifiers
- RevenueCat dashboard → iOS app config

Pick one canonical form and audit every place. Recommend `com.auracoach.auraCoachAi` (current Xcode value).

## Android SDK setup (separate issue)

The Android build failed with `No Android SDK found. Try setting the ANDROID_HOME environment variable.`

### Fix on macOS

1. Install Android Studio: https://developer.android.com/studio
2. Open Android Studio → Tools → SDK Manager → install:
   - Android SDK Platform 35 (target)
   - Android SDK Build-Tools 35.x
   - Android SDK Platform-Tools
   - Android SDK Command-line Tools
3. Add to `~/.zshrc` (or `~/.bash_profile`):
   ```bash
   export ANDROID_HOME=$HOME/Library/Android/sdk
   export PATH=$PATH:$ANDROID_HOME/emulator
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
   ```
4. `source ~/.zshrc` then `flutter doctor` → should show ✓ for Android toolchain.
5. Accept Android licenses: `flutter doctor --android-licenses`
6. Generate a release keystore (one-time):
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
7. Create `android/key.properties`:
   ```
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=/Users/luuphuc/upload-keystore.jks
   ```
8. Run `flutter build apk --release` to verify.

## Production-blocker dependency chain

```
Apple Developer Program enrollment ($99)
    ├─ Required for App Store / TestFlight submission
    ├─ Required for Sign in with Apple capability
    └─ Required for App Store Connect IAP product setup
            └─ Required for RevenueCat product linking
                    └─ Required for paywall to show real prices
```

Conclusion: enroll ASAP — every downstream subscription work depends on it.
