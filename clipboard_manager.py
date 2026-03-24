#!/usr/bin/env python3
"""
ClipStash - A lightweight macOS menu bar clipboard manager.
Automatically captures clipboard history and keeps the 5 most recent items.
Click any item to copy it back to your clipboard.
"""

import AppKit
import rumps
import subprocess
import threading
import time
import os
import json

# Hide Python icon from Dock — run as accessory (menu bar only)
AppKit.NSApplication.sharedApplication().setActivationPolicy_(
    AppKit.NSApplicationActivationPolicyAccessory
)

# --- Config ---
MAX_ITEMS = 5
POLL_INTERVAL = 0.5  # seconds between clipboard checks
DATA_FILE = os.path.expanduser("~/.clipstash_history.json")
MAX_DISPLAY_LEN = 50  # truncate long items in the menu


def get_clipboard():
    """Get current clipboard content using pbpaste."""
    try:
        result = subprocess.run(
            ["pbpaste"], capture_output=True, text=True, timeout=2
        )
        return result.stdout
    except Exception:
        return None


def set_clipboard(text):
    """Set clipboard content using pbcopy."""
    try:
        process = subprocess.Popen(["pbcopy"], stdin=subprocess.PIPE)
        process.communicate(text.encode("utf-8"))
    except Exception:
        pass


def truncate(text, max_len=MAX_DISPLAY_LEN):
    """Truncate text for menu display, replacing newlines."""
    single_line = text.replace("\n", " ").replace("\r", "").strip()
    if len(single_line) > max_len:
        return single_line[:max_len] + "…"
    return single_line


class ClipStashApp(rumps.App):
    def __init__(self):
        super().__init__("📋", quit_button=None)
        self.history = []
        self.last_clip = None
        self._load_history()
        self._rebuild_menu()

        # Start clipboard watcher in background thread
        self.watcher_thread = threading.Thread(target=self._watch_clipboard, daemon=True)
        self.watcher_thread.start()

    # --- Persistence ---

    def _load_history(self):
        """Load saved clipboard history from disk."""
        if os.path.exists(DATA_FILE):
            try:
                with open(DATA_FILE, "r") as f:
                    self.history = json.load(f)
                # Ensure max items
                self.history = self.history[:MAX_ITEMS]
                if self.history:
                    self.last_clip = self.history[0]
            except (json.JSONDecodeError, IOError):
                self.history = []

    def _save_history(self):
        """Persist clipboard history to disk."""
        try:
            with open(DATA_FILE, "w") as f:
                json.dump(self.history, f, ensure_ascii=False)
        except IOError:
            pass

    # --- Clipboard Watcher ---

    def _watch_clipboard(self):
        """Poll the clipboard for changes."""
        while True:
            try:
                current = get_clipboard()
                if current and current.strip() and current != self.last_clip:
                    self.last_clip = current
                    self._add_item(current)
            except Exception:
                pass
            time.sleep(POLL_INTERVAL)

    def _add_item(self, text):
        """Add a new item to history (most recent first), cap at MAX_ITEMS."""
        # Remove duplicate if it already exists
        if text in self.history:
            self.history.remove(text)
        self.history.insert(0, text)
        self.history = self.history[:MAX_ITEMS]
        self._save_history()
        self._rebuild_menu()

    # --- Menu Building ---

    def _rebuild_menu(self):
        """Rebuild the dropdown menu with current history."""
        self.menu.clear()

        if not self.history:
            self.menu.add(rumps.MenuItem("No items yet", callback=None))
        else:
            for i, item in enumerate(self.history):
                display = f"{i + 1}. {truncate(item)}"
                menu_item = rumps.MenuItem(display, callback=self._on_click)
                # Store the full text in the menu item
                menu_item._full_text = item
                self.menu.add(menu_item)

        self.menu.add(rumps.separator)
        self.menu.add(rumps.MenuItem("Clear History", callback=self._clear_history))
        self.menu.add(rumps.separator)
        self.menu.add(rumps.MenuItem("Quit ClipStash", callback=self._quit))

    # --- Callbacks ---

    def _on_click(self, sender):
        """Copy the selected item back to clipboard."""
        full_text = getattr(sender, "_full_text", None)
        if full_text:
            set_clipboard(full_text)
            rumps.notification(
                title="ClipStash",
                subtitle="Copied to clipboard!",
                message=truncate(full_text, 80),
            )

    def _clear_history(self, _):
        """Clear all clipboard history."""
        self.history = []
        self.last_clip = None
        self._save_history()
        self._rebuild_menu()

    def _quit(self, _):
        """Quit the app."""
        rumps.quit_application()


if __name__ == "__main__":
    ClipStashApp().run()