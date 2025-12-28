# Brief - Share Extension Setup Guide

This guide helps you configure the Xcode project for the Brief Share Extension.

## Project Structure

```
Brief/
├── Shared (App)/          # Shared app code (iOS + macOS)
│   ├── APIService.swift   # API calls to Brief backend
│   ├── ContentView.swift  # Main app UI (configure email)
│   └── UserPreferences.swift # Shared preferences via App Group
├── Shared (Extension)/    # Shared extension code
│   └── ShareView.swift    # Share sheet UI (SwiftUI)
├── iOS (App)/             # iOS app entry point
│   └── BriefApp.swift
├── iOS (Extension)/       # iOS Share Extension
│   └── ShareViewController.swift
├── macOS (App)/           # macOS app entry point
│   └── AppDelegate.swift
└── macOS (Extension)/     # macOS Share Extension
    └── ShareViewController.swift
```

## Xcode Configuration Steps

### 1. Open the Project
Open `Brief.xcodeproj` in Xcode.

### 2. Configure Signing
For each target (Brief iOS, Brief macOS, Brief Extension iOS, Brief Extension macOS):
1. Select the target in the project navigator
2. Go to "Signing & Capabilities"
3. Select your Team
4. Enable "Automatically manage signing"

### 3. Configure App Groups
All targets need the same App Group for sharing preferences:

1. Select each target
2. Go to "Signing & Capabilities"
3. Click "+ Capability"
4. Add "App Groups"
5. Add: `group.com.quickcapture.brief`

### 4. Update Extension Targets (if needed)
The extension targets should be configured as **Share Extensions** (not Safari Web Extensions):

1. Select the extension target
2. Check that Info.plist has:
   - `NSExtensionPointIdentifier`: `com.apple.share-services`
   - `NSExtensionPrincipalClass`: `$(PRODUCT_MODULE_NAME).ShareViewController`

### 5. Add Swift Files to Targets
Ensure each target has the correct source files:

**iOS App Target:**
- `iOS (App)/BriefApp.swift`
- `Shared (App)/*.swift`

**macOS App Target:**
- `macOS (App)/AppDelegate.swift`
- `Shared (App)/*.swift`

**iOS Extension Target:**
- `iOS (Extension)/ShareViewController.swift`
- `Shared (Extension)/ShareView.swift`

**macOS Extension Target:**
- `macOS (Extension)/ShareViewController.swift`
- `Shared (Extension)/ShareView.swift`

### 6. Build & Run
1. Select "Brief (macOS)" or "Brief (iOS)" scheme
2. Build and run
3. Configure your email in the app
4. Test sharing a URL from Safari or any other app

## How It Works

1. **Main App**: Configure your email address (stored in shared App Group)
2. **Share Extension**: Share any URL from any app
3. **API Call**: URL is sent to Brief API with optional AI summary
4. **Email**: You receive the article via email

## Troubleshooting

**"Please set your email in the Brief app first"**
- Open the main Brief app and configure your email address

**Share extension not appearing**
- Make sure the extension target is properly signed
- Check that App Groups capability is added
- Restart your device/simulator

**Build errors about missing files**
- Ensure all Swift files are added to the correct targets
- Check "Target Membership" in the File Inspector
