#!/bin/bash
# ClipStash - Release Helper
# Builds, packages, and prints instructions for publishing a release.
#
# Usage:
#   bash release.sh 1.0.0
#   bash release.sh 1.1.0

set -e

VERSION="${1:?Usage: bash release.sh <version>  (e.g. 1.0.0)}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DMG_NAME="ClipStash-${VERSION}.dmg"

cd "$SCRIPT_DIR"

echo "=== ClipStash Release v${VERSION} ==="
echo ""

# --- Build ---
echo "[1/4] Building app..."
bash build.sh

# --- Package DMG ---
echo "[2/4] Creating DMG..."

# Update version in build_dmg.sh dynamically
sed "s/DMG_NAME=\"ClipStash-.*\.dmg\"/DMG_NAME=\"${DMG_NAME}\"/" build_dmg.sh > /tmp/build_dmg_versioned.sh
bash /tmp/build_dmg_versioned.sh
rm /tmp/build_dmg_versioned.sh

# --- Calculate SHA ---
echo "[3/4] Calculating SHA256..."
SHA256=$(shasum -a 256 "dist/${DMG_NAME}" | awk '{print $1}')
echo "  SHA256: ${SHA256}"

# --- Print instructions ---
echo ""
echo "[4/4] Release checklist:"
echo ""
echo "  ┌─────────────────────────────────────────────────────┐"
echo "  │  GITHUB RELEASE                                     │"
echo "  ├─────────────────────────────────────────────────────┤"
echo "  │  1. Go to your ClipStash repo on GitHub             │"
echo "  │  2. Click 'Releases' → 'Create a new release'      │"
echo "  │  3. Tag: v${VERSION}                                │"
echo "  │  4. Title: ClipStash v${VERSION}                    │"
echo "  │  5. Attach: dist/${DMG_NAME}                        │"
echo "  │  6. Publish release                                 │"
echo "  └─────────────────────────────────────────────────────┘"
echo ""
echo "  ┌─────────────────────────────────────────────────────┐"
echo "  │  HOMEBREW TAP UPDATE                                │"
echo "  ├─────────────────────────────────────────────────────┤"
echo "  │  In your homebrew-tap repo, update Casks/clipstash.rb:"
echo "  │                                                     │"
echo "  │    version \"${VERSION}\"                           │"
echo "  │    sha256 \"${SHA256}\"                             │"
echo "  │                                                     │"
echo "  │  Then commit and push.                              │"
echo "  └─────────────────────────────────────────────────────┘"
echo ""
echo "  DMG ready at: ${SCRIPT_DIR}/dist/${DMG_NAME}"
echo ""
echo "=== Done ==="
