# Changelog

All notable changes to the Brief iOS app.

## [1.1] - Unreleased

### Added
- **Send History** - View recently sent links
  - iOS: Swipe left to access history page
  - macOS: Use Send/History segmented picker
- Tap any history item to open in in-app Safari browser
- History syncs between main app and Share Extension
- Stores last 100 articles
- Auto-refresh history when returning from background

### Changed
- Theme colors moved to shared Theme.swift file
- macOS Share Extension now saves to history (parity with iOS)

## [1.0] - 2025-01-19

Initial App Store release.

### Added
- Send links to email with optional AI summaries (Gemini 2.5 Flash)
- Share Extension for quick capture from Safari and other apps
- Onboarding flow with demo and setup guide
- macOS support via Catalyst

### Fixed
- Contrast issues for Apple accessibility review
- HTML entity decoding for Instagram/LinkedIn shares
- macOS Safari URL extraction
- Share extension content cutoff on macOS
