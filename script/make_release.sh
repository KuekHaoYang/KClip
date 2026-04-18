#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-v0.1.1}"
PLAIN_VERSION="${VERSION#v}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
RELEASE_DIR="$DIST_DIR/releases"
ARCHIVE_PATH="$RELEASE_DIR/KClip-$VERSION-macOS.zip"

KCLIP_VERSION="$PLAIN_VERSION" "$ROOT_DIR/script/build_and_run.sh" package

rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"
rm -f "$ARCHIVE_PATH"
/usr/bin/xattr -cr "$DIST_DIR/KClip.app"
DITTONORSRC=1 /usr/bin/ditto -c -k --keepParent --norsrc --noextattr --noqtn --noacl \
  "$DIST_DIR/KClip.app" "$ARCHIVE_PATH"

echo "Created $ARCHIVE_PATH"
