---
name: deploy-android
description: Build a signed Android App Bundle (AAB) and APK for Google Play release. Verifies version bump, runs analyzer, generates artifacts, and prints upload checklist.
---

# Deploy Android (Google Play)

When the user asks to "build for release", "deploy to Play", "make AAB", or any
similar phrasing, run this workflow.

## Prerequisites Check

1. Confirm `key.properties` exists at `android/key.properties` (signing key).
   If missing, ask the user — never auto-generate keys.
2. Confirm `pubspec.yaml` `version` was bumped since the last release tag.
   If not, ask: "Last release was X.X.X+N. Bump to which version?"
3. Run `flutter analyze` — abort if any errors.

## Build Sequence

```bash
flutter clean
flutter pub get
flutter analyze
flutter test               # optional — skip only if user confirms
flutter build appbundle --release
flutter build apk --release --split-per-abi
```

Outputs:
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-*-release.apk`

## After Build

Print this checklist for the user:

```
✅ AAB ready: build/app/outputs/bundle/release/app-release.aab
✅ APK (per-ABI): build/app/outputs/flutter-apk/

Next steps:
1. Open Play Console → Release → Production → Create new release
2. Upload the AAB
3. Fill release notes (in Arabic — see GOOGLE_PLAY_GUIDE.md)
4. Save → Review → Send for review
```

## Don'ts

- Do NOT bump `targetSdkVersion` below 35 (Google Play requirement).
- Do NOT change `applicationId` from `com.ruqyah.altatil`.
- Do NOT skip `flutter analyze` even if user is in a hurry.
- Do NOT push the AAB to GitHub — only the source code.
