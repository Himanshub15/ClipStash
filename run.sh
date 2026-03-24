#!/bin/bash
# ClipStash — Run or install
# Usage: bash run.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_PATH="$HOME/Library/LaunchAgents/com.clipstash.plist"

if [ -f "$PLIST_PATH" ]; then
    # Already installed — restart it
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    launchctl load "$PLIST_PATH"
    echo "ClipStash restarted. Look for 📋 in menu bar."
else
    # First time — install
    bash "$SCRIPT_DIR/install.sh"
fi
