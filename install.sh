#!/bin/bash
# ClipStash — One-command install
# curl -fsSL https://raw.githubusercontent.com/Himanshub15/ClipStash/main/install.sh | bash
set -e

REPO="Himanshub15/ClipStash"
BRANCH="main"
INSTALL_DIR="$HOME/.clipstash"
VENV_DIR="$INSTALL_DIR/venv"
PLIST_PATH="$HOME/Library/LaunchAgents/com.clipstash.plist"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"

echo ""
echo "  📋 ClipStash Installer"
echo "  ─────────────────────"
echo ""

# --- macOS check ---
if [ "$(uname)" != "Darwin" ]; then
    echo "  ✗ ClipStash only works on macOS."
    exit 1
fi

# --- Find python3 ---
PY=$(command -v python3 2>/dev/null)
if [ -z "$PY" ]; then
    echo "  ✗ python3 not found."
    echo "    Install it: https://python.org/downloads"
    exit 1
fi
echo "  ✓ Found Python: $PY"

# --- Stop old instance if running ---
pkill -f "clipstash/clipboard_manager.py" 2>/dev/null || true
launchctl unload "$PLIST_PATH" 2>/dev/null || true

# --- Download files ---
echo "  → Downloading ClipStash..."
mkdir -p "$INSTALL_DIR"
curl -fsSL "$RAW_BASE/clipboard_manager.py" -o "$INSTALL_DIR/clipboard_manager.py"
curl -fsSL "$RAW_BASE/update.sh" -o "$INSTALL_DIR/update.sh"
chmod +x "$INSTALL_DIR/update.sh"
curl -fsSL "$RAW_BASE/VERSION" -o "$INSTALL_DIR/VERSION" 2>/dev/null || echo "1.0.0" > "$INSTALL_DIR/VERSION"

# --- Create venv and install dependencies ---
echo "  → Setting up environment..."
"$PY" -m venv "$VENV_DIR" 2>/dev/null || {
    echo "  ✗ Failed to create virtual environment."
    echo "    Try: pip3 install virtualenv"
    exit 1
}
"$VENV_DIR/bin/pip" install --upgrade pip >/dev/null 2>&1 || true
"$VENV_DIR/bin/pip" install rumps 2>&1 | tail -1
echo "  ✓ Dependencies ready"

VENV_PY="$VENV_DIR/bin/python3"
echo "  ✓ Installed to $INSTALL_DIR"

# --- Create LaunchAgent ---
cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.clipstash</string>
    <key>ProgramArguments</key>
    <array>
        <string>$VENV_PY</string>
        <string>$INSTALL_DIR/clipboard_manager.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardErrorPath</key>
    <string>$INSTALL_DIR/error.log</string>
</dict>
</plist>
EOF

launchctl load "$PLIST_PATH"
echo "  ✓ ClipStash is running — look for 📋 in your menu bar"

# --- Setup daily auto-update check ---
UPDATE_PLIST="$HOME/Library/LaunchAgents/com.clipstash.updater.plist"
cat > "$UPDATE_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.clipstash.updater</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$INSTALL_DIR/update.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>86400</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>$INSTALL_DIR/updater.log</string>
</dict>
</plist>
EOF

launchctl load "$UPDATE_PLIST" 2>/dev/null || true
echo "  ✓ Auto-updates enabled (checks daily)"

# --- Create 'clipstash' CLI command ---
CLI_PATH="/usr/local/bin/clipstash"
cat > /tmp/clipstash_cli << CLIP
#!/bin/bash
PLIST="$PLIST_PATH"
case "\${1:-start}" in
    start)
        pkill -f "clipstash/clipboard_manager.py" 2>/dev/null || true
        launchctl unload "\$PLIST" 2>/dev/null || true
        launchctl load "\$PLIST"
        echo "ClipStash started — look for 📋 in your menu bar."
        ;;
    stop)
        launchctl unload "\$PLIST" 2>/dev/null || true
        pkill -f "clipstash/clipboard_manager.py" 2>/dev/null || true
        echo "ClipStash stopped."
        ;;
    restart)
        "\$0" stop
        "\$0" start
        ;;
    status)
        if pgrep -f "clipstash/clipboard_manager.py" >/dev/null 2>&1; then
            echo "ClipStash is running."
        else
            echo "ClipStash is not running. Run 'clipstash start' to start."
        fi
        ;;
    *)
        echo "Usage: clipstash [start|stop|restart|status]"
        ;;
esac
CLIP

if [ -d "/usr/local/bin" ] && mv /tmp/clipstash_cli "$CLI_PATH" 2>/dev/null && chmod +x "$CLI_PATH" 2>/dev/null; then
    echo "  ✓ CLI ready — type 'clipstash' to manage"
else
    rm -f /tmp/clipstash_cli
    echo "  ℹ CLI skipped (no write access to /usr/local/bin)"
    echo "    To enable: sudo cp ~/.clipstash/clipstash /usr/local/bin/"
fi

echo ""
echo "  ┌──────────────────────────────────────────┐"
echo "  │  ClipStash is ready!                     │"
echo "  │                                          │"
echo "  │  📋 Copy anything — it's auto-captured   │"
echo "  │  Click the 📋 icon to see your history   │"
echo "  │  Starts automatically on login           │"
echo "  │  Updates automatically in the background │"
echo "  │                                          │"
echo "  │  Reopen anytime:  clipstash start        │"
echo "  │  Stop:            clipstash stop         │"
echo "  │  Check status:    clipstash status       │"
echo "  └──────────────────────────────────────────┘"
echo ""
echo "  Uninstall: curl -fsSL $RAW_BASE/uninstall.sh | bash"
echo ""
