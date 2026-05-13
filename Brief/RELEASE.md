# Brief Release Checklist

This checklist is for preparing the next Brief App Store update.

Current release candidate:
- Version: 1.2
- Build: 6
- macOS bundle ID: `com.danielensign.Brief`
- macOS share extension bundle ID: `com.danielensign.Brief.Extension`

## Before Upload

1. Confirm the repo is on the intended branch and the release commits are pushed.
2. Confirm there are no unrelated local changes staged for release.
3. Confirm the App Store Connect private key exists outside the repo:
   `~/.appstoreconnect/private_keys/AuthKey_PAQ942SRH8.p8`
4. Confirm Xcode has the needed platforms installed.
   - macOS release builds are currently verified.
   - iOS simulator release builds are currently verified with iOS 26.4.1.

## Local Verification

Run these checks before creating an App Store archive:

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app/brief-api
npm test
npm audit
```

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app/brief-web
npm test
npm audit
```

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app
git diff --check
xcodebuild -project Brief/Brief.xcodeproj -scheme "Brief (macOS)" -configuration Release -destination "generic/platform=macOS" CODE_SIGNING_ALLOWED=NO build
xcodebuild -project Brief/Brief.xcodeproj -scheme "Brief (iOS)" -configuration Release -destination "platform=iOS Simulator,name=iPhone 17,OS=26.4.1" CODE_SIGNING_ALLOWED=NO build
```

## Mac App Store Upload

Only run this after an explicit approval checkpoint, because it creates and uploads a signed App Store package.

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app/Brief
fastlane mac release_macos
```

Expected output artifact:
- `~/Desktop/BriefArchives/macOS-Export/Brief.pkg`

## Current Release Notes

Use these notes for the App Store version update:

```text
Reliability improvements for saving and sharing links:
- Safer handling of article text and AI summaries before email delivery.
- More reliable web-link validation in the app and share extensions.
- Better timeout handling and clearer send failures from share sheets.
```

## Manual Checks

Before submitting for review:
- Open Brief on macOS and confirm the saved email still appears.
- Share a normal web page from Safari into Brief.
- Send with AI Summary off.
- Send with AI Summary on, confirming the consent copy still appears when needed.
- Confirm the received email opens the correct link.

## Known Blockers

- App Store upload/submission should wait for approval because it touches App Store Connect.
