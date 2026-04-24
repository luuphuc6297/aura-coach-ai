# CI/CD Setup

This document describes the CI/CD pipelines and the GitHub secrets required to run them.

## Workflows

| Workflow | Trigger | Purpose |
|---|---|---|
| `.github/workflows/ci.yml` | PR and push to `master` | Format check, analyze, test, coverage |
| `.github/workflows/release-android.yml` | Tag `v*.*.*`, manual | Build AAB, upload to Play Store |
| `.github/workflows/release-ios.yml` | Tag `v*.*.*`, manual | Build IPA, upload to TestFlight |
| `.github/workflows/build-macos.yml` | Tag `v*.*.*`, manual | Build macOS `.app` (verification only) |

## Releasing

1. Bump `version` in `pubspec.yaml` (format `<semver>+<build>`, e.g. `1.2.3+45`).
2. Commit and push to `master`.
3. Create and push a tag:
   ```bash
   git tag v1.2.3
   git push origin v1.2.3
   ```
4. Android and iOS release workflows run automatically.

## Required GitHub Secrets

Create these under **Settings → Secrets and variables → Actions**.

### Shared

| Secret | Description | How to generate |
|---|---|---|
| `ENV_FILE` | Base64 of `.env` | `base64 -i .env \| pbcopy` |

### Android (`release-android.yml`)

| Secret | Description |
|---|---|
| `ANDROID_GOOGLE_SERVICES_JSON` | Base64 of `android/app/google-services.json` |
| `ANDROID_KEYSTORE_BASE64` | Base64 of release keystore (`upload-keystore.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias (usually `upload`) |
| `ANDROID_KEY_PASSWORD` | Key password |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Plain JSON of Google Play service account with Release Manager role |

Generate the keystore:
```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
base64 -i upload-keystore.jks | pbcopy
```

Create a Play Store service account at Google Cloud Console → IAM → Service Accounts, grant access in Play Console (Setup → API access), download JSON key.

### iOS (`release-ios.yml`)

| Secret | Description |
|---|---|
| `IOS_GOOGLE_SERVICE_INFO_PLIST` | Base64 of `ios/Runner/GoogleService-Info.plist` |
| `IOS_DIST_CERTIFICATE_BASE64` | Base64 of Apple Distribution certificate (`.p12`) |
| `IOS_DIST_CERTIFICATE_PASSWORD` | `.p12` password |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 of `.mobileprovision` (App Store type) |
| `IOS_EXPORT_OPTIONS_PLIST` | Base64 of `ios/ExportOptions.plist` |
| `APPSTORE_API_KEY_ID` | App Store Connect API key ID |
| `APPSTORE_API_ISSUER_ID` | App Store Connect issuer ID |
| `APPSTORE_API_KEY_BASE64` | Base64 of `.p8` key file |

Export certificate:
1. Open **Keychain Access** on macOS.
2. Right-click your Apple Distribution certificate → Export → `.p12`.
3. `base64 -i cert.p12 | pbcopy`.

Export provisioning profile:
1. Download from https://developer.apple.com/account/resources/profiles/list.
2. `base64 -i profile.mobileprovision | pbcopy`.

`ExportOptions.plist` template:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.auracoach.aura_coach_ai</key>
        <string>YOUR_PROFILE_NAME</string>
    </dict>
</dict>
</plist>
```

Create App Store Connect API key at https://appstoreconnect.apple.com/access/api with role **Developer** or higher.

### macOS (`build-macos.yml`)

| Secret | Description |
|---|---|
| `MACOS_GOOGLE_SERVICE_INFO_PLIST` | Base64 of `macos/Runner/GoogleService-Info.plist` |

## Local Development

- Copy `android/key.properties.example` to `android/key.properties` and fill values (optional — debug build still works without it).
- Place `google-services.json`, `GoogleService-Info.plist`, `.env` locally; they are gitignored.
- Run `flutter pub get && flutter run` as usual.
