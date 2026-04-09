#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/KClip.app"

cd "$ROOT_DIR"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

swift build -c release

EXECUTABLE="$(find "$ROOT_DIR/.build" -type f -path "*/release/KClip" | head -n 1)"

if [[ -z "$EXECUTABLE" || ! -x "$EXECUTABLE" ]]; then
  echo "Release executable not found at $EXECUTABLE" >&2
  exit 1
fi

cp "$EXECUTABLE" "$APP_DIR/Contents/MacOS/KClip"

cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>KClip</string>
    <key>CFBundleExecutable</key>
    <string>KClip</string>
    <key>CFBundleIdentifier</key>
    <string>io.kclip.mac</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>KClip</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>
    <key>LSMinimumSystemVersion</key>
    <string>15.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

touch "$APP_DIR/Contents/PkgInfo"
echo "APPL????" > "$APP_DIR/Contents/PkgInfo"

codesign --force --deep --sign - "$APP_DIR"

rm -f "$DIST_DIR/KClip-macOS.zip"
ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$DIST_DIR/KClip-macOS.zip"

echo "Created:"
echo "  $APP_DIR"
echo "  $DIST_DIR/KClip-macOS.zip"
