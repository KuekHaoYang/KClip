#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
APP_NAME="KClip"
BUNDLE_ID="com.kuekhaoyang.kclip"
MIN_SYSTEM_VERSION="15.0"
VERSION="${KCLIP_VERSION:-0.1.5}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
INSTALL_DIR="$HOME/Applications"
STAGING_BUNDLE="$DIST_DIR/$APP_NAME.app"
INSTALL_BUNDLE="$INSTALL_DIR/$APP_NAME.app"
APP_CONTENTS="$STAGING_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$APP_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"
BRAND_DIR="$DIST_DIR/Brand"

pkill -x "$APP_NAME" >/dev/null 2>&1 || true
swift "$ROOT_DIR/script/render_brand.swift" "$BRAND_DIR"
swift build
BUILD_BINARY="$(swift build --show-bin-path)/$APP_NAME"
rm -rf "$STAGING_BUNDLE"
mkdir -p "$APP_MACOS" "$APP_RESOURCES"
cp "$BUILD_BINARY" "$APP_BINARY"
cp "$BRAND_DIR/AppIcon.icns" "$APP_RESOURCES/AppIcon.icns"
chmod +x "$APP_BINARY"

cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" \
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>$APP_NAME</string>
<key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundleName</key><string>$APP_NAME</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>$VERSION</string>
<key>CFBundleVersion</key><string>$VERSION</string>
<key>LSMinimumSystemVersion</key><string>$MIN_SYSTEM_VERSION</string>
<key>LSUIElement</key><true/>
<key>NSPrincipalClass</key><string>NSApplication</string>
</dict></plist>
PLIST

SIGNING_IDENTITY="${KCLIP_SIGNING_IDENTITY:-$(
  security find-identity -v -p codesigning | awk -F'\"' '/Apple Development:/ {print $2; exit}'
)}"
SIGN_ARGS=(--force --deep --sign - --identifier "$BUNDLE_ID")
if [[ -n "$SIGNING_IDENTITY" ]]; then
  SIGN_ARGS=(--force --deep --sign "$SIGNING_IDENTITY" --identifier "$BUNDLE_ID")
fi
/usr/bin/codesign "${SIGN_ARGS[@]}" "$STAGING_BUNDLE"
mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_BUNDLE"
cp -R "$STAGING_BUNDLE" "$INSTALL_BUNDLE"

open_app() { /usr/bin/open -n "$INSTALL_BUNDLE"; }

case "$MODE" in
  package) ;;
  run) open_app ;;
  --debug|debug) lldb -- "$INSTALL_BUNDLE/Contents/MacOS/$APP_NAME" ;;
  --logs|logs)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --telemetry|telemetry)
    open_app
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"$BUNDLE_ID\""
    ;;
  --verify|verify)
    open_app
    sleep 1
    pgrep -x "$APP_NAME" >/dev/null
    ;;
  *)
    echo "usage: $0 [run|package|--debug|--logs|--telemetry|--verify]" >&2
    exit 2
    ;;
esac
