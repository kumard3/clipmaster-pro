#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting local build test..."

# Set variables
BUILD_NUMBER=$(git rev-list --count HEAD)
VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
VERSION=${VERSION#v}

echo "📦 Build Number: $BUILD_NUMBER"
echo "📝 Version: $VERSION"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build/
rm -f ClipMaster-Pro.zip

# Build the app
echo "🏗️  Building app..."
xcodebuild -project clip-board-app.xcodeproj \
  -scheme "clip-board-app" \
  -configuration Release \
  -derivedDataPath build \
  -archivePath build/clip-board-app.xcarchive \
  MACOSX_DEPLOYMENT_TARGET=14.0 \
  archive

# Create zip
echo "📦 Creating zip archive..."
cd build/clip-board-app.xcarchive/Products/Applications/
zip -r ../../../../ClipMaster-Pro-$VERSION.zip "clip-board-app.app"
cd ../../../../

echo "✅ Build completed!"
echo "📍 Output: ClipMaster-Pro-$VERSION.zip"

# Optional: Test the app bundle
if [ -f "ClipMaster-Pro-$VERSION.zip" ]; then
    echo "🔍 Verifying app bundle..."
    unzip -l "ClipMaster-Pro-$VERSION.zip"
    echo "✅ Verification complete!"
else
    echo "❌ Error: Zip file not created!"
    exit 1
fi 