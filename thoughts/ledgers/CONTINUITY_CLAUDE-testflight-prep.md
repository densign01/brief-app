# Continuity Ledger: Brief TestFlight Prep

## Goal
Streamline the Brief project and prepare iOS/macOS app for TestFlight submission.

## Constraints
- Keep only: `Brief/` (iOS+macOS app), `brief-api/`, `brief-web/`
- Delete: `brief-raycast/`, `brief-extension/`, `brief-macos/` (superseded)
- User doesn't care about Raycast or Chrome extensions

## Key Decisions
- Using unified `Brief/` Xcode project for both iOS and macOS
- Share Extension architecture (not Safari Web Extension)
- App Group: `group.com.quickcapture.brief`
- Bundle ID: `com.danielensign.Brief`

## State

### Phase 1: Cleanup
- [ ] Delete `brief-raycast/`
- [ ] Delete `brief-extension/`
- [ ] Delete `brief-macos/` (old, superseded by Brief/)
- [ ] Update .gitignore if needed
- [ ] Commit cleanup

### Phase 2: TestFlight Readiness
- [ ] Verify app icons are complete (1024x1024 required)
- [ ] Check bundle IDs registered in Apple Developer portal
- [ ] Test build for iOS release configuration
- [ ] Test build for macOS release configuration
- [ ] Resolve any build errors/warnings

### Phase 3: TestFlight Submission
- [ ] Archive iOS build
- [ ] Archive macOS build
- [ ] Upload to App Store Connect
- [ ] Configure TestFlight metadata

## Open Questions
- [ ] UNCONFIRMED: Are bundle IDs already registered in Apple Developer portal?
- [ ] UNCONFIRMED: Is there a privacy policy URL for App Store Connect?
- [ ] Are app icons complete in Assets.xcassets?

## Working Set
- `Brief/` - Main Xcode project
- `Brief/Brief.xcodeproj/project.pbxproj` - Project config
- `Brief/Shared (App)/Assets.xcassets/` - App icons

## TestFlight Readiness Assessment
**Score: 8.5/10**

Ready:
- Project structure sound
- Signing configured (Team: PTP9R9BR3L)
- Deployment targets: iOS 15.0, macOS 13.5
- Entitlements configured for App Groups
- Hardened runtime enabled (macOS)

Needs attention:
- Bundle ID registration verification
- App icon completeness
- Privacy policy (if collecting data)
