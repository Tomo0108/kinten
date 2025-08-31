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

echo "[pkg] Prepare empty input -> $PKG_ROOT/input"
rm -rf "$PKG_ROOT/input"
mkdir -p "$PKG_ROOT/input"

echo "[pkg] Ensure empty output -> $PKG_ROOT/output"
rm -rf "$PKG_ROOT/output"
mkdir -p "$PKG_ROOT/output"

echo "[pkg] Copy requirements.txt -> $PKG_ROOT/"
cp -f "$ROOT_DIR/requirements.txt" "$PKG_ROOT/"

# バックエンドをPyInstallerでスタンドアロン化（配布先にPython不要）
echo "[pkg] Build backend (PyInstaller onefile) -> $PKG_ROOT/kinten_backend"
PYI_DIR="$ROOT_DIR/.pyi"
python3 -m venv "$PYI_DIR" || true
PYI_PY="$PYI_DIR/bin/python"
PYI_PIP="$PYI_DIR/bin/pip"
PYI_CLI="$PYI_DIR/bin/pyinstaller"

if [[ -x "$PYI_PY" ]]; then
  "$PYI_PY" -m pip install --upgrade pip setuptools wheel >/dev/null
  "$PYI_PIP" install pyinstaller >/dev/null
  "$PYI_PIP" install -r <(grep -v 'pywin32' "$ROOT_DIR/requirements.txt") >/dev/null
  # 事前に用意したspecでbackend配下のモジュールを同梱
  "$PYI_CLI" --clean "$ROOT_DIR/kinten_backend.spec" >/dev/null || true
  # 出力物をPKG_ROOTへ配置（dist優先。frontend/distにも出力される場合があるため両方を確認）
  if [[ -f "$ROOT_DIR/dist/kinten_backend" ]]; then
    mv -f "$ROOT_DIR/dist/kinten_backend" "$PKG_ROOT/kinten_backend" || true
  elif [[ -f "$ROOT_DIR/frontend/dist/kinten_backend" ]]; then
    mv -f "$ROOT_DIR/frontend/dist/kinten_backend" "$PKG_ROOT/kinten_backend" || true
  fi
  chmod +x "$PKG_ROOT/kinten_backend" || true
else
  echo "[pkg] WARN: python3 venv not available. Trying user-site PyInstaller build."
  if command -v python3 >/dev/null 2>&1; then
    python3 -m pip install --user --upgrade pip setuptools wheel >/dev/null 2>&1 || true
    python3 -m pip install --user pyinstaller >/dev/null 2>&1 || true
    python3 -m pip install --user -r "$ROOT_DIR/requirements.txt" >/dev/null 2>&1 || true
    python3 -m PyInstaller --clean "$ROOT_DIR/kinten_backend.spec" >/dev/null 2>&1 || true
    if [[ -f "$ROOT_DIR/dist/kinten_backend" ]]; then
      mv -f "$ROOT_DIR/dist/kinten_backend" "$PKG_ROOT/kinten_backend" || true
    elif [[ -f "$ROOT_DIR/frontend/dist/kinten_backend" ]]; then
      mv -f "$ROOT_DIR/frontend/dist/kinten_backend" "$PKG_ROOT/kinten_backend" || true
    fi
    chmod +x "$PKG_ROOT/kinten_backend" || true
  else
    echo "[pkg] ERROR: python3 not found. Backend bundling skipped."
  fi
fi

# macOSアプリバンドル内にもkinten_backendを同梱
if [[ -f "$PKG_ROOT/kinten_backend" ]]; then
  MACOS_DIR="$PKG_ROOT/kinten.app/Contents/MacOS"
  if [[ -d "$MACOS_DIR" ]]; then
    echo "[pkg] Embed kinten_backend into app bundle: $MACOS_DIR"
    cp -f "$PKG_ROOT/kinten_backend" "$MACOS_DIR/kinten_backend" || true
    chmod +x "$MACOS_DIR/kinten_backend" || true
  else
    echo "[pkg] WARN: MacOS directory not found inside app bundle: $MACOS_DIR"
  fi
fi

# ZIP作成（input/outputを空のまま梱包）
mkdir -p "$PKG_DIR"
(
  cd "$PKG_DIR"
  # 念のため実行直前にも空にする
  find "$PKG_ROOT/input" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
  find "$PKG_ROOT/output" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
  rm -f kinten.zip
  zip -r -9 kinten.zip kinten >/dev/null
  echo "[pkg] DONE: $PKG_DIR/kinten.zip"
)


