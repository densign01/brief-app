# Continuity Ledger: Brief App Store Release
Updated: 2026-01-17T19:50:00Z

## Goal
~~Streamline the Brief project and prepare iOS/macOS app for TestFlight submission.~~
**ACHIEVED:** App submitted to App Store Review on 2026-01-17.

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

### Phase 6: External TestFlight Beta [COMPLETE - 2025-12-31]
- [x] Create external testing group ("Friends & Family")
- [x] Submit build for Beta App Review
- [x] Beta App Review approved
- [x] Distribute to testers

### Phase 7: Onboarding Flow [COMPLETE - 2025-12-31]
- [x] Plan onboarding (3 steps: email, enable extension, share demo)
- [x] Create `OnboardingView.swift` container with TabView (iOS) / custom nav (macOS)
- [x] Create `OnboardingStepViews.swift` with EmailStepView, EnableExtensionStepView, ShareDemoStepView
- [x] Add `hasCompletedOnboarding` to UserPreferences
- [x] Update BriefApp.swift and AppDelegate.swift with conditional rendering
- [x] Add animated share demo with Safari mock and share sheet mock
- [x] Add deep link support (`brief://setup-complete`)
- [x] Add external setup guide link
- [x] Test in iOS simulator - SUCCESS
- [x] Merge to main and push to GitHub

### Phase 8: Polish & Bug Fixes [COMPLETE - 2025-01-01]
- [x] Change "article" → "link" terminology throughout UI (13 text changes)
- [x] Fix LinkedIn double-encoded HTML entities in app (`&amp;#39;` → `'`) - Xcode
- [x] Fix newlines in email subject for multi-line LinkedIn posts - Wrangler
- [x] Add HTML entity decoding on API side for cleaner emails - Wrangler
- [x] All changes pushed to GitHub

### Phase 9: TestFlight Build [COMPLETE - 2026-01-02]
**Build includes commits since `3025fa1`:**

**App Changes:**
| Commit | Change |
|--------|--------|
| `44e768d` | Let API extract page titles for product pages |
| `21fabe2` | Skip onboarding if email already saved |
| `f796cb7` | Fix double-encoded HTML entities (LinkedIn) |

**API Changes (already deployed):**
| Commit | Change |
|--------|--------|
| `26d366a` | HTML entity decoding on API side |
| `e451141` | Strip newlines from email subject |

**Testing Checklist:**
- [x] Fresh install → onboarding flow appears
- [x] Existing user with email → skips onboarding
- [x] Share LinkedIn post with special chars → clean title
- [x] Share multi-line LinkedIn post → email sends successfully
- [x] Verify email subject line is clean (no encoded entities)
- [x] Share product page → shows actual product name (not "Shared Link")

**Build Status:**
- [x] Archive iOS build
- [x] Archive macOS build
- [x] Upload to App Store Connect

### Phase 10: App Store Release [COMPLETE - 2026-01-17]
**Decision:** Launch as FREE app, add freemium later based on usage data

**App Store Listing:**
- **App Name:** Brief
- **Subtitle:** Send links to your inbox
- **Keywords:** read later,save articles,email,summary,AI,bookmark,links,share extension
- **Support URL:** https://send-brief.com/support.html
- **Privacy URL:** https://send-brief.com/privacy.html

**Checklist:**
- [x] Draft App Store listing copy
- [x] Review and finalize copy
- [x] Create iPhone screenshots
- [x] Create iPad screenshots (scaled from iPhone)
- [x] Complete age rating questionnaire
- [x] Complete App Privacy section
- [x] Set price to Free
- [x] Add support URL
- [x] Submit for App Review ✅

**Submitted:** 2026-01-17
**Status:** Waiting for App Review

**Infrastructure Setup:**
- [x] Register send-brief.com domain (Cloudflare)
- [x] Deploy docs to Cloudflare Pages (send-brief.com)
- [x] Landing page, support page, privacy policy, setup guide live

**Future: Freemium Model (post-launch)**
- Free tier: 10 links/month
- Pro tier: Unlimited @ $2.99/month or $19.99/year
- Requires: usage tracking, account/device ID, IAP integration, paywall UI

## Open Questions
- [x] Are bundle IDs registered in Apple Developer portal? YES
- [x] Is there a privacy policy URL for App Store Connect? YES → `https://densign01.github.io/quickcapture/privacy.html`
- [x] Register `send-brief.com` via Cloudflare → verify with Resend → update API from address

## Working Set
- `Brief/Brief.xcodeproj` - Main Xcode project
- `Brief/Shared (App)/ContentView.swift` - Main app UI
- `Brief/Shared (App)/OnboardingView.swift` - Onboarding container
- `Brief/Shared (App)/OnboardingStepViews.swift` - 3 onboarding step views
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

### ✅ FIXED: Instagram Sharing HTML Entity Decoding (2025-12-30)
- Instagram shares text with HTML-encoded entities (`&quot;`, `&#x201c;`, etc.)
- Title displayed raw without decoding, showing garbage characters
- **Fix:** Added `htmlDecoded` String extension using `NSAttributedString` HTML parser
- Applied to both iOS and macOS share extensions
- Decodes titles from: plain text, property list, og:title, twitter:title, `<title>` tag
- Commit: pending

### ✅ FIXED: Resend Domain Verification for External Testers (2025-12-31)
- Registered `send-brief.com` domain via Cloudflare
- Verified domain with Resend
- Updated API `from` address: `onboarding@resend.dev` → `brief@send-brief.com`
- Deployed to Cloudflare Workers

### ✅ FIXED: LinkedIn Sharing Issues (2025-01-01)
- **Double-encoded HTML entities** - Title showed `I&amp;#39;m` instead of `I'm`
  - App fix: Updated `htmlDecoded` to decode twice (Xcode) - `f796cb7`
  - API fix: Added `decodeHTMLEntities()` on Cloudflare side - `26d366a`
- **Newlines in email subject** - Multi-line LinkedIn posts broke email sending
  - Fix: Strip `\n` from subject line on API - `e451141`
- Applied to both iOS/macOS extensions and Cloudflare Workers

### ✅ FIXED: Product Pages Showing "Shared Link" (2026-01-02)
- Non-article links (e-commerce, product pages) showed generic "Shared Link" title
- Root cause: App sent "Shared Link" fallback, blocking API from extracting real title
- **Fix:** Send empty title to API, let API fetch og:title/twitter:title/<title>
- Applied to both iOS and macOS share extensions
- Commit: `44e768d`

### ✅ CHANGED: "Article" to "Link" Terminology (2025-01-01)
- Changed all user-facing "article" text to "link" for broader content support
- 13 text changes across 3 files (ContentView, OnboardingStepViews, ShareView)
- Better reflects support for tweets, Instagram posts, websites, etc.
- Commit: `3025fa1`

### ✅ ADDED: 3-Step Onboarding Flow (2025-12-31)
- Step 1: Email entry with validation (saves to UserPreferences)
- Step 2: Enable extension instructions with setup guide link
- Step 3: Animated share demo showing Safari → Share → Brief → Email
- Platform-specific: iOS uses swipe TabView, macOS uses button navigation
- Realistic mocks: Safari browser, share sheet with app icons, loading spinner
- Branch: `feature/onboarding-flow` merged to main
- Commit: `b0393da`

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
- `0de668e` - Prepare docs for send-brief.com hosting
- `039f2e8` - Add support page, update privacy policy for Gemini
- `44e768d` - Let API extract page titles when app extraction fails
- `21fabe2` - Skip onboarding when email is already saved
- `26d366a` - Add HTML entity decoding on API side for cleaner email titles
- `e451141` - Fix: strip newlines from email subject for multi-line LinkedIn posts
- `f796cb7` - Fix double-encoded HTML entities from LinkedIn shares
- `3025fa1` - Change 'article' to 'link' throughout UI for broader content types
- `d3e9412` - Update ledger: onboarding flow complete, pending TestFlight build
- `6496040` - Merge onboarding flow into main
- `056b0e9` - fix: use verified send-brief.com domain for email delivery
- `b0393da` - feat: implement 3-step onboarding flow with realistic demo and setup guide
- `d41d0ab` - Fix HTML entity decoding for Instagram shares
- `cfe54f6` - Add tweet content extraction via Twitter oEmbed API
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
