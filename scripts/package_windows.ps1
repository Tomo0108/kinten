Param(
  [switch]$SkipBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ROOT = (Resolve-Path "$PSScriptRoot\..\").Path
$DIST = Join-Path $ROOT 'dist'
$PKG_DIR = Join-Path $ROOT 'package'
$PKG_ROOT = Join-Path $PKG_DIR 'kinten'
$RELEASE_DIR = Join-Path $ROOT 'frontend\build\windows\x64\runner\Release'

Write-Host "[pkg-win] ROOT=$ROOT"

if (-not $SkipBuild) {
  # 1) Flutter (Windows) リリースビルド
  Write-Host "[pkg-win] Build Flutter (windows)"
  Push-Location (Join-Path $ROOT 'frontend')
  flutter build windows --release | Write-Host
  Pop-Location

  # 2) PyInstaller でバックエンドをスタンドアロン化
  Write-Host "[pkg-win] Build backend (PyInstaller)"
  Push-Location $ROOT
  if (-not (Test-Path ".pyi-win")) {
    python -m venv .pyi-win | Write-Host
  }
  . .\.pyi-win\Scripts\Activate.ps1
  python -m pip install --upgrade pip setuptools wheel | Write-Host
  pip install -r requirements.txt pyinstaller | Write-Host
  if (Test-Path 'kinten_backend.spec') {
    pyinstaller .\kinten_backend.spec | Write-Host
  } else {
    pyinstaller --onefile .\backend\main.py --name kinten_backend --distpath .\dist | Write-Host
  }
  deactivate
  Pop-Location
}

# 3) パッケージフォルダ作成
Write-Host "[pkg-win] Prepare package folder"
New-Item -ItemType Directory -Force -Path $PKG_ROOT | Out-Null

# 4) フロントエンド成果物（Releaseフォルダ一式）
Write-Host "[pkg-win] Copy frontend Release -> package"
Copy-Item -Recurse -Force "$RELEASE_DIR\*" "$PKG_ROOT\" | Out-Null

# 5) バックエンド実行ファイル（Python不要版）
Write-Host "[pkg-win] Copy backend exe"
if (Test-Path (Join-Path $DIST 'kinten_backend.exe')) {
  Copy-Item -Force (Join-Path $DIST 'kinten_backend.exe') (Join-Path $PKG_ROOT 'kinten_backend.exe')
}

# 6) テンプレート/入出力/requirements
Write-Host "[pkg-win] Copy templates + create input/output"
Copy-Item -Recurse -Force (Join-Path $ROOT 'templates') $PKG_ROOT
New-Item -ItemType Directory -Force -Path (Join-Path $PKG_ROOT 'input') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $PKG_ROOT 'output') | Out-Null
Copy-Item -Force (Join-Path $ROOT 'requirements.txt') $PKG_ROOT

# 7) zip 作成
Write-Host "[pkg-win] Create zip"
New-Item -ItemType Directory -Force -Path $PKG_DIR | Out-Null
$zipPath = Join-Path $PKG_DIR 'kinten_windows.zip'
if (Test-Path $zipPath) { Remove-Item -Force $zipPath }
Compress-Archive -Path (Join-Path $PKG_ROOT '*') -DestinationPath $zipPath -Force

Write-Host "[pkg-win] Done: $zipPath"

