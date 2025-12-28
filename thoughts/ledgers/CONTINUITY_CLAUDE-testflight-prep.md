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

### Phase 3: TestFlight Submission [IN PROGRESS]
- [x] Register bundle IDs in Apple Developer portal
- [ ] Let Xcode create provisioning profiles
- [ ] Archive iOS build
- [ ] Archive macOS build
- [ ] Upload to App Store Connect
- [ ] Configure TestFlight metadata

## Open Questions
- [x] Are bundle IDs registered in Apple Developer portal? YES
- [ ] Is there a privacy policy URL for App Store Connect?

## Working Set
- `Brief/Brief.xcodeproj` - Main Xcode project
- `Brief/Shared (App)/ContentView.swift` - Main app UI
- `Brief/Shared (Extension)/ShareView.swift` - Share extension UI

## Recent Commits
- `895b06d` - Fix macOS build and UI layout issues
- `a192107` - Streamline project for TestFlight: remove unused modules, fix build
- `6509d55` - Convert from Safari Web Extension to native Share Extension
