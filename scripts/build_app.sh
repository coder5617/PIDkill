#!/usr/bin/env bash

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="PIDkill"
BUNDLE_DIR="${PROJECT_DIR}/${APP_NAME}.app"

echo "🔨 Building ${APP_NAME} (Release)..."
cd "${PROJECT_DIR}"
swift build -c release

echo "📦 Assembling ${APP_NAME}.app bundle..."
rm -rf "${BUNDLE_DIR}"
mkdir -p "${BUNDLE_DIR}/Contents/MacOS"
mkdir -p "${BUNDLE_DIR}/Contents/Resources"

cp "${PROJECT_DIR}/.build/release/${APP_NAME}" "${BUNDLE_DIR}/Contents/MacOS/${APP_NAME}"
cp "${PROJECT_DIR}/Resources/Info.plist" "${BUNDLE_DIR}/Contents/Info.plist"

chmod +x "${BUNDLE_DIR}/Contents/MacOS/${APP_NAME}"

echo "✅ Success! ${APP_NAME}.app bundle created at:"
echo "   ${BUNDLE_DIR}"
echo "   You can now double-click ${APP_NAME}.app in Finder to run it!"
