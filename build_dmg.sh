#!/bin/bash
# ClipStash — Package .app into a .dmg installer
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

APP_PATH="dist/ClipStash.app"
DMG_NAME="ClipStash-1.0.0.dmg"
DMG_PATH="dist/${DMG_NAME}"
VOLUME_NAME="ClipStash"
TMP_DMG="/tmp/clipstash_tmp.dmg"

if [ ! -d "$APP_PATH" ]; then
    echo "Error: $APP_PATH not found. Run 'bash build.sh' first."
    exit 1
fi

echo "Creating DMG..."

# Clean up any previous DMG
rm -f "$DMG_PATH" "$TMP_DMG"

# Create a temporary DMG
hdiutil create -size 100m -fs HFS+ -volname "$VOLUME_NAME" "$TMP_DMG"

# Mount it
MOUNT_DIR=$(hdiutil attach "$TMP_DMG" | grep "/Volumes" | awk '{print $3}')

# Copy the app
cp -R "$APP_PATH" "$MOUNT_DIR/"

# Create Applications symlink for drag-install
ln -s /Applications "$MOUNT_DIR/Applications"

# Unmount
hdiutil detach "$MOUNT_DIR"

# Convert to compressed final DMG
hdiutil convert "$TMP_DMG" -format UDZO -o "$DMG_PATH"

# Clean up
rm -f "$TMP_DMG"

echo ""
echo "✓ DMG ready: $DMG_PATH"
