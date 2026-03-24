#!/bin/bash
# ClipStash — Build .app bundle using py2app
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "Installing dependencies..."
pip3 install -r requirements.txt

echo "Cleaning previous build..."
rm -rf build dist

echo "Building ClipStash.app..."
python3 setup.py py2app

echo ""
echo "✓ Built: dist/ClipStash.app"
echo "  Run with: open dist/ClipStash.app"
