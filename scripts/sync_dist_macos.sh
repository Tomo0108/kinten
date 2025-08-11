#!/usr/bin/env bash
set -euo pipefail

# macOS: Flutterビルド成果物と必要リソースを dist/ に同期する

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/frontend"
APP_PATH="$FRONTEND_DIR/build/macos/Build/Products/Release/kinten.app"
DIST_DIR="$ROOT_DIR/dist"

echo "[sync] ROOT_DIR=$ROOT_DIR"

if [[ ! -d "$APP_PATH" ]]; then
  echo "[sync] macOS .app が見つかりません: $APP_PATH"
  echo "[sync] 先にフロントエンドをビルドしてください: cd frontend && flutter build macos --release"
  exit 1
fi

mkdir -p "$DIST_DIR/macos"
mkdir -p "$DIST_DIR/output"

echo "[sync] Copy .app -> $DIST_DIR/macos/"
rsync -a "$APP_PATH" "$DIST_DIR/macos/"

echo "[sync] Copy backend -> $DIST_DIR/backend"
rsync -a "$ROOT_DIR/backend" "$DIST_DIR/"

echo "[sync] Copy templates -> $DIST_DIR/templates"
rsync -a "$ROOT_DIR/templates" "$DIST_DIR/"

echo "[sync] Copy input -> $DIST_DIR/input"
rsync -a "$ROOT_DIR/input" "$DIST_DIR/"

echo "[sync] Copy requirements.txt -> $DIST_DIR/"
cp -f "$ROOT_DIR/requirements.txt" "$DIST_DIR/"

echo "[sync] Done. dist に同期しました。"

echo "[sync] Optional: 初回のみ依存導入 (pywin32除外)"
echo "[sync]   cd $DIST_DIR && python3 -m venv .venv && source .venv/bin/activate && pip install -r <(grep -v 'pywin32' requirements.txt) xlwings"


