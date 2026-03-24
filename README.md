# ClipStash

**Lightweight clipboard manager for macOS.** Lives in your menu bar, remembers what you copy.

![macOS 12+](https://img.shields.io/badge/macOS-12%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-1.0.0-orange)

---

## Install

One command. That's it.

```bash
curl -fsSL https://raw.githubusercontent.com/Himanshub15/ClipStash/main/install.sh | bash
```

ClipStash installs, starts immediately, auto-launches on login, and updates itself in the background.

---

## What it does

Copy anything with **⌘C** — ClipStash captures it automatically.

Click the **📋** icon in your menu bar to see your last 5 copied items. Click any item to copy it back.

| | |
|---|---|
| **Auto-capture** | Everything you copy is saved |
| **5 recent items** | Oldest items rotate out as new ones come in |
| **One-click re-copy** | Click any item to put it back on your clipboard |
| **Persistent history** | Survives restarts and reboots |
| **No Dock icon** | Runs quietly in the menu bar |
| **Auto-updates** | New versions are pulled automatically every 24h |

---

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/Himanshub15/ClipStash/main/uninstall.sh | bash
```

---

## How it works

ClipStash is a Python script that uses [rumps](https://github.com/jaredks/rumps) to create a native macOS menu bar app. It polls the clipboard every 0.5 seconds, stores history in `~/.clipstash_history.json`, and runs as a LaunchAgent so it starts on login and restarts if it crashes.

```
~/.clipstash/                  # App files
~/.clipstash_history.json      # Clipboard history (persists across restarts)
~/Library/LaunchAgents/com.clipstash.plist           # Auto-start
~/Library/LaunchAgents/com.clipstash.updater.plist   # Auto-update (checks daily)
```

### Updates

When you push a new version to this repo:

1. Bump the `VERSION` file
2. Commit and push

Users get the update automatically within 24 hours. The updater checks `VERSION` on GitHub, downloads new files if changed, and restarts ClipStash — zero user action required.

---

## Requirements

- macOS 12+ (Monterey or later)
- Python 3.8+ (pre-installed on macOS or via [python.org](https://python.org/downloads))

The installer handles all dependencies automatically.

---

## Development

```bash
# Run directly during development
python3 clipboard_manager.py

# Test the install flow locally
bash install.sh
```

---

## License

MIT
