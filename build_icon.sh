#!/bin/bash
# ClipStash — Generate .icns icon from a PNG
# Usage: bash build_icon.sh my_logo.png
set -e

INPUT="${1:?Usage: bash build_icon.sh <input.png>}"
ICONSET_DIR="ClipStash.iconset"
OUTPUT="ClipStash.icns"

if [ ! -f "$INPUT" ]; then
    echo "Error: File '$INPUT' not found."
    exit 1
fi

echo "Generating icon from $INPUT..."

mkdir -p "$ICONSET_DIR"

# Generate all required sizes
for SIZE in 16 32 64 128 256 512; do
    sips -z $SIZE $SIZE "$INPUT" --out "$ICONSET_DIR/icon_${SIZE}x${SIZE}.png" >/dev/null
done
for SIZE in 32 64 128 256 512 1024; do
    HALF=$((SIZE / 2))
    sips -z $SIZE $SIZE "$INPUT" --out "$ICONSET_DIR/icon_${HALF}x${HALF}@2x.png" >/dev/null
done

# Convert iconset to icns
iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT"

# Clean up
rm -rf "$ICONSET_DIR"

echo "✓ Icon created: $OUTPUT"
