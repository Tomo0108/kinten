#!/usr/bin/env bash
# macOS packaging script for Kinten (with backend binary)
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

  echo "[pkg-mac] Build backend (PyInstaller onefile)"
  bash "$ROOT_DIR/scripts/build_backend_macos.sh"
fi

# Prepare package root
rm -rf "$PKG_ROOT"
mkdir -p "$PKG_ROOT"

# Copy app bundle (prefer dist/macos, fallback to build products)
echo "[pkg-mac] Copy app bundle"
if [[ -d "$DIST_DIR/macos/kinten.app" ]]; then
  rsync -a "$DIST_DIR/macos/kinten.app" "$PKG_ROOT/"
elif [[ -d "$APP_SRC" ]]; then
  rsync -a "$APP_SRC" "$PKG_ROOT/"
else
  echo "[pkg-mac] kinten.app not found. Build first."
  exit 1
fi

# Copy backend binary and assets next to kinten.app (kinten/ 配下運用)
echo "[pkg-mac] Copy backend binary/templates/input/output/requirements"
if [[ -f "$DIST_DIR/kinten_backend" ]]; then
  cp -f "$DIST_DIR/kinten_backend" "$PKG_ROOT/"
else
  echo "[pkg-mac] WARNING: backend binary not found at $DIST_DIR/kinten_backend"
fi
rsync -a "$ROOT_DIR/backend" "$PKG_ROOT/"
rsync -a "$ROOT_DIR/templates" "$PKG_ROOT/"
mkdir -p "$PKG_ROOT/input" "$PKG_ROOT/output"
cp -f "$ROOT_DIR"/input/*.csv "$PKG_ROOT/input/" 2>/dev/null || true
cp -f "$ROOT_DIR/requirements.txt" "$PKG_ROOT/"

# Ensure backend binary is executable
if [[ -f "$PKG_ROOT/kinten_backend" ]]; then
  chmod +x "$PKG_ROOT/kinten_backend"
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