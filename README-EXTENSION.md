# QuickCapture Safari Extension

This directory contains the Safari browser extension version of QuickCapture.

## Files Structure

- `manifest.json` - Extension configuration and permissions
- `background.js` - Background script for handling API calls and browser events
- `content.js` - Content script that runs on web pages to extract metadata
- `popup.html` - Extension popup interface
- `popup.js` - Popup functionality and user interactions
- `icons/` - Extension icons (you need to create these)

## Required Icons

You need to create the following icon files in the `icons/` directory:
- `icon-16.png` - 16x16 pixels
- `icon-32.png` - 32x32 pixels  
- `icon-48.png` - 48x48 pixels
- `icon-128.png` - 128x128 pixels

## Installation for Development

### Chrome/Edge (for testing):
1. Open `chrome://extensions/`
2. Enable "Developer mode"
3. Click "Load unpacked"
4. Select this directory

### Safari:
1. Open Xcode
2. File → New → Project
3. Choose macOS → Safari Extension App
4. Copy these files to the extension bundle
5. Build and run

## Differences from Web Version

- Uses Chrome Extensions API for page access
- Popup interface instead of full-page app
- Background script handles API calls to avoid CORS
- Content script extracts better page metadata
- Keyboard shortcut support (Ctrl/Cmd + Shift + Q)
- Right-click context menu integration

## Security Notes

- Extension only requests necessary permissions
- API calls go through background script
- No inline scripts in HTML
- Follows Chrome Web Store security policies