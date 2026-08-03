#!/usr/bin/env bash

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_DIR}"

mkdir -p Resources
ICONSET_DIR="/tmp/PIDkill_AppIcon.iconset"
rm -rf "${ICONSET_DIR}"
mkdir -p "${ICONSET_DIR}"

echo "🎨 Rendering 1024x1024 base icon..."
swift scripts/generate_icon.swift "${ICONSET_DIR}/icon_512x512@2x.png"

echo "📐 Resizing icon set variants..."
sips -z 16 16     "${ICONSET_DIR}/icon_512x512@2x.png" --out "${ICONSET_DIR}/icon_16x16.png" > /dev/null
sips -z 32 32     "${ICONSET_DIR}/icon_512x512@2x.png" --out "${ICONSET_DIR}/icon_16x16@2x.png" > /dev/null
sips -z 32 32     "${ICONSET_DIR}/icon_512x512@2x.png" --out "${ICONSET_DIR}/icon_32x32.png" > /dev/null
sips -z 64 64     "${ICONSET_DIR}/icon_512x512@2x.png" --out "${ICONSET_DIR}/icon_32x32@2x.png" > /dev/null
sips -z 128 128   "${ICONSET_DIR}/icon_512x512@2x.png" --out "${ICONSET_DIR}/icon_128x128.png" > /dev/null
sips -z 256 256   "${ICONSET_DIR}/icon_512x512@2x.png" --out "${ICONSET_DIR}/icon_128x128@2x.png" > /dev/null
sips -z 256 256   "${ICONSET_DIR}/icon_512x512@2x.png" --out "${ICONSET_DIR}/icon_256x256.png" > /dev/null
sips -z 512 512   "${ICONSET_DIR}/icon_512x512@2x.png" --out "${ICONSET_DIR}/icon_256x256@2x.png" > /dev/null
sips -z 512 512   "${ICONSET_DIR}/icon_512x512@2x.png" --out "${ICONSET_DIR}/icon_512x512.png" > /dev/null

echo "🛠️ Compiling AppIcon.icns..."
iconutil -c icns "${ICONSET_DIR}" -o Resources/AppIcon.icns
rm -rf "${ICONSET_DIR}"

echo "✅ Created Resources/AppIcon.icns successfully!"
