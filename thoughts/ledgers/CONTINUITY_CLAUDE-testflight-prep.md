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
- UI Theme: Purple/indigo gradient (#6346E0 → #9355E9)

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

### Phase 5: Polish & UX Improvements [COMPLETE - 2024-12-28]
- [x] New app icon (purple/indigo gradient with document + AI sparkle)
- [x] Complete UI redesign with matching purple/indigo theme
- [x] Fix X.com/Twitter URLs showing "JavaScript is not available"
- [x] Label title-based summaries clearly ("AI-generated from title")
- [x] Fix macOS Safari share extension URL extraction
- [x] Add ⌘+Return keyboard shortcut for macOS share extension
- [x] Add Escape to cancel on macOS
- [x] Commit: `1faa623`

## Status: ✅ READY FOR TESTING

## Open Questions
- [x] Are bundle IDs registered in Apple Developer portal? YES
- [x] Is there a privacy policy URL for App Store Connect? YES → `https://densign01.github.io/quickcapture/privacy.html`

## Working Set
- `Brief/Brief.xcodeproj` - Main Xcode project
- `Brief/Shared (App)/ContentView.swift` - Main app UI
- `Brief/Shared (Extension)/ShareView.swift` - Share extension UI
- `brief-api/src/index.js` - Cloudflare Workers API

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
- **Enhancement:** Summaries now labeled "AI-generated from title - full article not accessible"
- Deployed to Cloudflare Workers
- Commit: `500c662`, `b226e67`

### ✅ FIXED: New App Icon Design
- Created purple/indigo gradient icon with document + AI sparkle
- Matches new UI theme
- All sizes generated (16-1024px)
- Commit: `8fa2eb7`

### ✅ FIXED: UI Cleanup
- Complete redesign with purple/indigo theme
- Card-based layout with shadows
- Gradient accent buttons
- Better section organization with labels and icons
- Setup prompt for new users
- Polished settings view
- Commit: `b226e67`

### ✅ FIXED: X.com/Twitter URL Titles
- X/Twitter returned "JavaScript is not available" as title
- **Fix:** Extract @username from URL, display as "Post by @username on X"
- Filter out other bad titles from JS-heavy sites
- Commit: `b226e67`

### ✅ FIXED: macOS Safari Share Extension URL Not Extracted
- Share extension was sending empty URL from Safari
- **Fix:** Added multiple fallback extraction methods (userInfo, attributedContentText, fileURL type)
- Commit: `2f0388a`

### ✅ ADDED: Keyboard Shortcuts for macOS
- ⌘+Return to send
- Escape to cancel
- Hint text showing keyboard shortcut
- Commit: `1faa623`

### ✅ SWITCHED: AI Provider to Gemini 2.5 Flash (2024-12-28)
- Migrated from OpenAI GPT-4o-mini to Google Gemini 2.5 Flash
- Updated `@ai-sdk/openai` → `@ai-sdk/google` v3.0.1 in package.json
- Model: `gemini-2.5-flash`
- Pricing: $0.30/1M input, $2.50/1M output
- Added `GOOGLE_API_KEY` to Cloudflare secrets
- Updated UI text from "Claude" to "Gemini"
- Made share sheet more compact (removed scroll)
- Can remove `OPENAI_API_KEY`, `OPENAI_MODEL`, `ANTHROPIC_API_KEY` from Cloudflare
- Commit: `9126024`

### ✅ FIXED: AI Summary Not Generating (2025-12-29)
- Root cause: AI SDK v5 incompatible with Gemini 2.5 (v3 spec not supported)
- Secondary issue: False paywall detection ("subscribe" matching newsletter buttons)
- **Fix:** Switched from AI SDK to direct Gemini 2.0 Flash API calls
- **Fix:** Simplified paywall detection to content length only (< 500 chars)
- **Fix:** Added markdown-to-HTML conversion for email formatting
- Commit: `8c36103`

### ✅ FIXED: Restore AI Summary Toggle in Share Sheet (2025-12-29)
- Toggle and length picker were implemented but not rendered
- **Fix:** Added `aiSummarySection` to ShareView body
- Commit: pending user build verification

### ✅ ADDED: Tweet Content Extraction via oEmbed (2025-12-29)
- X/Twitter shares were showing AI-generated guesses instead of actual tweet text
- **Fix:** Added `fetchTweetContent()` using Twitter's free oEmbed API
- Extracts: author name, handle, actual tweet text
- Display: Tweet styled with Twitter-blue left border, proper attribution
- Skips AI summary for tweets (actual content is better)
- Detection now runs unconditionally (not just when title is missing)
- Deployed to Cloudflare Workers

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
- (pending) - Add tweet content extraction via Twitter oEmbed API
- `8c36103` - Fix AI summary generation with direct Gemini API
- `9126024` - Switch AI provider from OpenAI to Gemini 2.5 Flash
- `1faa623` - Add ⌘+Return keyboard shortcut for macOS share extension
- `2f0388a` - Fix macOS Safari URL extraction - add multiple fallback methods
- `96f0c05` - Add detailed API error logging to macOS share extension
- `b226e67` - UI redesign: Purple/indigo theme with better visual hierarchy
- `8fa2eb7` - New app icon: Purple/indigo gradient with document and AI sparkle
- `1bb446d` - Update ledger: mark share visibility and paywall fixes complete
- `500c662` - Fix share extension visibility and enable paywall bypass
- `64fc202` - Fix: Hide API endpoint from settings, add title fetching for share extension
- App Groups capability enabled in Xcode (not in git - Xcode project change)
- `783991b` - Add macOS Info.plist with app category for TestFlight
- `2dde282` - Fix privacy policy (Anthropic) and add iOS app category for TestFlight
- `895b06d` - Fix macOS build and UI layout issues
- `a192107` - Streamline project for TestFlight: remove unused modules, fix build
- `6509d55` - Convert from Safari Web Extension to native Share Extension
