#!/usr/bin/env bash
# macOS packaging script for Kinten
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/frontend"
DIST_DIR="$ROOT_DIR/dist"
PKG_DIR="$ROOT_DIR/package"
PKG_ROOT="$PKG_DIR/kinten"
APP_SRC="$FRONTEND_DIR/build/macos/Build/Products/Release/kinten.app"

echo "[pkg-mac] ROOT_DIR=$ROOT_DIR"

if [[ "${1:-}" != "--skip-build" ]]; then
  echo "[pkg-mac] Build Flutter (macOS)"
  pushd "$FRONTEND_DIR" >/dev/null
  flutter clean
  flutter pub get
  flutter build macos --release
  popd >/dev/null

  echo "[pkg-mac] Sync dist"
  bash "$ROOT_DIR/scripts/sync_dist_macos.sh"
fi

# Prepare package root
rm -rf "$PKG_ROOT"
mkdir -p "$PKG_ROOT"

# Copy app bundle
echo "[pkg-mac] Copy app bundle"
if [[ ! -d "$DIST_DIR/macos/kinten.app" ]]; then
  # fallback to build dir
  if [[ -d "$APP_SRC" ]]; then
    mkdir -p "$DIST_DIR/macos"
    rsync -a "$APP_SRC" "$DIST_DIR/macos/"
  else
    echo "[pkg-mac] kinten.app not found. Build first."
    exit 1
  fi
fi
rsync -a "$DIST_DIR/macos/kinten.app" "$PKG_ROOT/"

# Copy backend sources and assets
echo "[pkg-mac] Copy backend/templates/input/output/requirements"
rsync -a "$ROOT_DIR/backend" "$PKG_ROOT/"
rsync -a "$ROOT_DIR/templates" "$PKG_ROOT/"
mkdir -p "$PKG_ROOT/input" "$PKG_ROOT/output"
cp -f "$ROOT_DIR/requirements.txt" "$PKG_ROOT/"

# Optional: include prebuilt backend if exists
if [[ -f "$DIST_DIR/kinten_backend" ]]; then
  echo "[pkg-mac] Copy prebuilt backend binary"
  cp -f "$DIST_DIR/kinten_backend" "$PKG_ROOT/"
fi

# Create zip
mkdir -p "$PKG_DIR"
ZIP_PATH="$PKG_DIR/kinten.zip"
rm -f "$ZIP_PATH"

echo "[pkg-mac] Create zip -> $ZIP_PATH"
pushd "$PKG_DIR" >/dev/null
zip -r9 "$(basename "$ZIP_PATH")" "$(basename "$PKG_ROOT")"
popd >/dev/null

echo "[pkg-mac] Done: $ZIP_PATH"