# Continuity Ledger: Brief TestFlight Prep

## Goal
Streamline the Brief project and prepare iOS/macOS app for TestFlight submission.

## Constraints
- Keep only: `Brief/` (iOS+macOS app), `brief-api/`, `brief-web/`
- Delete: `brief-raycast/`, `brief-extension/`, `brief-macos/` (superseded)

## Key Decisions
- Using unified `Brief/` Xcode project for both iOS and macOS
- Share Extension architecture (not Safari Web Extension)
- App Group: `group.com.danielensign.Brief`
- Bundle ID: `com.danielensign.Brief`
- Deployment targets: iOS 17.0, macOS 14.0

## State

### Phase 1: Cleanup [COMPLETE]
- [x] Delete `brief-raycast/`
- [x] Delete `brief-extension/`
- [x] Delete `brief-macos/` (old, superseded by Brief/)
- [x] Commit cleanup (a192107)

### Phase 2: Build Fixes [COMPLETE]
- [x] Fix iOS app icon reference in Contents.json
- [x] Add Shared (App) folder to iOS/macOS app targets
- [x] Add Shared (Extension) folder to iOS/macOS extension targets
- [x] Include ContentView, UserPreferences, APIService in macOS target
- [x] Bump deployment targets to iOS 17.0, macOS 14.0
- [x] Fix "Length" label vertical wrapping in UI
- [x] Test iOS simulator build - SUCCESS
- [x] Test macOS build - SUCCESS
- [x] Commit fixes (895b06d)

### Phase 3: TestFlight Submission [COMPLETE]
- [x] Register bundle IDs in Apple Developer portal
- [x] Let Xcode create provisioning profiles
- [x] Archive iOS build
- [x] Archive macOS build
- [x] Upload to App Store Connect
- [x] Configure TestFlight metadata

### Phase 4: TestFlight Bug Fixes [COMPLETE]
- [x] Fix App Groups capability not enabled in Xcode (share extension couldn't read email)
- [x] Re-archive and upload fixed build
- [x] Verify share extension works ✓
- [x] Verify sending from main app works ✓

## Status: ✅ READY FOR TESTING

## Open Questions
- [x] Are bundle IDs registered in Apple Developer portal? YES
- [x] Is there a privacy policy URL for App Store Connect? YES → `https://densign01.github.io/quickcapture/privacy.html`

## Working Set
- `Brief/Brief.xcodeproj` - Main Xcode project
- `Brief/Shared (App)/ContentView.swift` - Main app UI
- `Brief/Shared (Extension)/ShareView.swift` - Share extension UI

## Backlog

### ✅ FIXED: Missing Article Metadata from App Shares
- When sharing from NYT app, title and publication are not extracted
- **Fix:** Share extension now fetches page and extracts og:title/twitter:title/<title>
- Commit: `64fc202`

### ✅ FIXED: Hide API Endpoint from Settings
- API Endpoint field is exposed in Settings UI (unnecessary for end users)
- **Fix:** Removed from UI, keeps hardcoded default
- Commit: `64fc202`

### ✅ FIXED: Brief Not Visible in Share Sheet from Certain Apps
- Brief doesn't appear in share sheet when sharing from NYT app (works from Safari/NYT.com)
- **Fix:** Added NSExtensionActivationSupportsText and NSExtensionActivationSupportsAttachmentsWithMaxCount
- Commit: `500c662`

### ✅ FIXED: Paywall Bypass for AI Summaries  
- Paywalled content (e.g., NYT) returns "Article content was behind a paywall - no summary available"
- **Fix:** Now uses generateTitleBasedSummary() to create AI-inferred summary from title
- Deployed to Cloudflare Workers
- Commit: `500c662`

### Task: New App Icon Design
- Current icon needs refresh
- Generate several new icon options to choose from
- Should convey "quick capture", "reading", "email", or "summary" concepts

### Task: UI Cleanup
- Polish the main app and share extension UI
- Improve visual design and user experience
- Make it feel more premium/polished

### Feature: Links Sent History
- Add ability to see previously sent links
- Track what articles have been captured
- Would require backend storage or local persistence
- Consider sync across devices

### Exploration: Infrastructure Evaluation
- Evaluate alternatives to current Cloudflare Workers + Resend setup
- Firebase could provide:
  - Authentication
  - Firestore for history/sync
  - Cloud Functions for API
  - Push notifications
- Compare cost, complexity, and feature tradeoffs

## Recent Commits
- `64fc202` - Fix: Hide API endpoint from settings, add title fetching for share extension
- App Groups capability enabled in Xcode (not in git - Xcode project change)
- `783991b` - Add macOS Info.plist with app category for TestFlight
- `2dde282` - Fix privacy policy (Anthropic) and add iOS app category for TestFlight
- `895b06d` - Fix macOS build and UI layout issues
- `a192107` - Streamline project for TestFlight: remove unused modules, fix build
- `6509d55` - Convert from Safari Web Extension to native Share Extension
