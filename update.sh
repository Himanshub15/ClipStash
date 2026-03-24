#!/bin/bash
# ClipStash — Auto-updater
# Checks GitHub for new version and updates silently
set -e

REPO="Himanshub15/ClipStash"
BRANCH="main"
INSTALL_DIR="$HOME/.clipstash"
PLIST_PATH="$HOME/Library/LaunchAgents/com.clipstash.plist"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"

# Get current and remote version
LOCAL_VERSION=$(cat "$INSTALL_DIR/VERSION" 2>/dev/null || echo "0.0.0")
REMOTE_VERSION=$(curl -fsSL "$RAW_BASE/VERSION" 2>/dev/null || echo "$LOCAL_VERSION")

if [ "$LOCAL_VERSION" = "$REMOTE_VERSION" ]; then
    exit 0
fi

# New version available — update
echo "[$(date)] Updating ClipStash: $LOCAL_VERSION → $REMOTE_VERSION"

curl -fsSL "$RAW_BASE/clipboard_manager.py" -o "$INSTALL_DIR/clipboard_manager.py"
curl -fsSL "$RAW_BASE/update.sh" -o "$INSTALL_DIR/update.sh"
curl -fsSL "$RAW_BASE/VERSION" -o "$INSTALL_DIR/VERSION"
chmod +x "$INSTALL_DIR/update.sh"

# Restart the app
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

echo "[$(date)] Updated to $REMOTE_VERSION and restarted."
