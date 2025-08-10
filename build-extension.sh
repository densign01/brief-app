#!/bin/bash

# Build script for QuickCapture Safari Extension
echo "Building QuickCapture Safari Extension..."

# Create build directory
BUILD_DIR="dist-extension"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Copy extension files
echo "Copying extension files..."
cp manifest.json "$BUILD_DIR/"
cp background.js "$BUILD_DIR/"
cp content.js "$BUILD_DIR/"
cp popup.html "$BUILD_DIR/"
cp popup.js "$BUILD_DIR/"

# Create icons directory
mkdir -p "$BUILD_DIR/icons"

# Check if icons exist, if not create placeholder
if [ ! -f "icons/icon-16.png" ]; then
    echo "Warning: Icons not found. Creating placeholder icons..."
    echo "You should replace these with proper QuickCapture icons."
    
    # Create simple placeholder icons using ImageMagick (if available)
    if command -v convert &> /dev/null; then
        convert -size 16x16 xc:blue "$BUILD_DIR/icons/icon-16.png"
        convert -size 32x32 xc:blue "$BUILD_DIR/icons/icon-32.png" 
        convert -size 48x48 xc:blue "$BUILD_DIR/icons/icon-48.png"
        convert -size 128x128 xc:blue "$BUILD_DIR/icons/icon-128.png"
        echo "Created placeholder icons with ImageMagick"
    else
        echo "ImageMagick not available. You'll need to create icons manually:"
        echo "- icons/icon-16.png (16x16)"
        echo "- icons/icon-32.png (32x32)" 
        echo "- icons/icon-48.png (48x48)"
        echo "- icons/icon-128.png (128x128)"
    fi
else
    cp icons/*.png "$BUILD_DIR/icons/"
    echo "Copied existing icons"
fi

# Validate manifest.json
if command -v jq &> /dev/null; then
    if jq . "$BUILD_DIR/manifest.json" > /dev/null 2>&1; then
        echo "✓ manifest.json is valid JSON"
    else
        echo "✗ Error: manifest.json is not valid JSON"
        exit 1
    fi
else
    echo "jq not available - cannot validate manifest.json"
fi

echo ""
echo "✓ Extension built successfully in $BUILD_DIR/"
echo ""
echo "To install in Chrome/Edge:"
echo "1. Go to chrome://extensions/"
echo "2. Enable 'Developer mode'"
echo "3. Click 'Load unpacked'"
echo "4. Select the $BUILD_DIR directory"
echo ""
echo "To convert to Safari extension:"
echo "1. Use Xcode to create a Safari Extension App project"
echo "2. Copy files from $BUILD_DIR to the extension bundle"
echo "3. Update manifest to Safari format if needed"