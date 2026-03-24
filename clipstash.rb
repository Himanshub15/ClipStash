# ============================================================
# Homebrew Tap for ClipStash
# ============================================================
#
# SETUP (one-time):
#   1. Create a GitHub repo named: homebrew-tap
#      (e.g. https://github.com/YOUR_USERNAME/homebrew-tap)
#
#   2. Put this file at: Casks/clipstash.rb
#      inside that repo.
#
#   3. Users can then install with:
#      brew install --cask YOUR_USERNAME/tap/clipstash
#
# UPDATING:
#   After each release, update the `version`, `url`, and `sha256`
#   below. Get the SHA with:
#     shasum -a 256 dist/ClipStash-1.0.0.dmg
#
# ============================================================

cask "clipstash" do
  version "1.0.0"
  sha256 "REPLACE_WITH_ACTUAL_SHA256_AFTER_BUILDING"

  url "https://github.com/YOUR_USERNAME/ClipStash/releases/download/v#{version}/ClipStash-#{version}.dmg"
  name "ClipStash"
  desc "Lightweight macOS menu bar clipboard manager"
  homepage "https://github.com/YOUR_USERNAME/ClipStash"

  depends_on macos: ">= :monterey"

  app "ClipStash.app"

  zap trash: [
    "~/.clipstash_history.json",
    "~/Library/LaunchAgents/com.clipstash.plist",
  ]

  caveats <<~EOS
    ClipStash runs in the menu bar (📋 icon).
    It automatically captures anything you copy.

    To start on login:
      System Settings → General → Login Items → add ClipStash
  EOS
end
