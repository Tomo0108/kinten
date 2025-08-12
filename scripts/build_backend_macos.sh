#!/usr/bin/env bash
# Build macOS backend standalone binary using PyInstaller
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "[build-backend-mac] Using python3: $(python3 --version 2>/dev/null || true)"

# Create a temporary virtualenv to isolate build if not present
VENV_DIR=".pyi-mac"
if [[ ! -d "$VENV_DIR" ]]; then
  python3 -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"
python3 -m pip install --upgrade pip setuptools wheel

# Install deps required for building the onefile backend
pip install -r requirements.txt pyinstaller

# Build onefile backend: kinten_backend (no .exe on macOS)
echo "[build-backend-mac] Building PyInstaller onefile"
if [[ -f "kinten_backend.spec" ]]; then
  # Use spec to include data folders if needed, but create a mac binary name
  # We override name via --name when using a spec would require editing the spec;
  # for simplicity, build directly from entrypoint here.
  pyinstaller --onefile ./backend/main.py --name kinten_backend --distpath ./dist
else
  pyinstaller --onefile ./backend/main.py --name kinten_backend --distpath ./dist
fi

deactivate || true

echo "[build-backend-mac] Built: $ROOT_DIR/dist/kinten_backend"

