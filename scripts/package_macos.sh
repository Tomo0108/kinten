#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/frontend"
APP_PATH="$FRONTEND_DIR/build/macos/Build/Products/Release/kinten.app"

PKG_DIR="$ROOT_DIR/package"
PKG_ROOT="$PKG_DIR/kinten"

echo "[pkg] ROOT_DIR=$ROOT_DIR"

# Flutter macOSアプリをビルド（未ビルドの場合）
if [[ ! -d "$APP_PATH" ]]; then
  echo "[pkg] macOSアプリが見つかりません。ビルドを実行します: $APP_PATH"
  (cd "$FRONTEND_DIR" && flutter build macos --release)
fi

# パッケージレイアウト作成（distは使わない）
rm -rf "$PKG_ROOT"
mkdir -p "$PKG_ROOT"

echo "[pkg] Copy .app -> $PKG_ROOT/"
rsync -a "$APP_PATH" "$PKG_ROOT/"

echo "[pkg] Copy backend -> $PKG_ROOT/backend"
rsync -a "$ROOT_DIR/backend" "$PKG_ROOT/"

echo "[pkg] Copy templates -> $PKG_ROOT/templates"
rsync -a "$ROOT_DIR/templates" "$PKG_ROOT/"

echo "[pkg] Copy input -> $PKG_ROOT/input"
rsync -a "$ROOT_DIR/input" "$PKG_ROOT/"

echo "[pkg] Ensure empty output -> $PKG_ROOT/output"
mkdir -p "$PKG_ROOT/output"

echo "[pkg] Copy requirements.txt -> $PKG_ROOT/"
cp -f "$ROOT_DIR/requirements.txt" "$PKG_ROOT/"

# ZIP作成
mkdir -p "$PKG_DIR"
cd "$PKG_DIR"
zip -r -9 kinten.zip kinten >/dev/null
echo "[pkg] DONE: $PKG_DIR/kinten.zip"


