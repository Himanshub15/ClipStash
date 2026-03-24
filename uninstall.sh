#!/bin/bash
# ClipStash — Uninstall
set -e

echo ""
echo "  Uninstalling ClipStash..."

launchctl unload ~/Library/LaunchAgents/com.clipstash.plist 2>/dev/null || true
launchctl unload ~/Library/LaunchAgents/com.clipstash.updater.plist 2>/dev/null || true
rm -f ~/Library/LaunchAgents/com.clipstash.plist
rm -f ~/Library/LaunchAgents/com.clipstash.updater.plist
pkill -f "clipstash/clipboard_manager.py" 2>/dev/null || true
rm -rf ~/.clipstash
rm -f /usr/local/bin/clipstash 2>/dev/null || sudo rm -f /usr/local/bin/clipstash 2>/dev/null || true

echo ""
echo "  ✓ ClipStash removed."
echo "  History file kept at ~/.clipstash_history.json"
echo "  To remove it too: rm ~/.clipstash_history.json"
echo ""
