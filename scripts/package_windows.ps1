Param(
  [switch]$SkipBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ROOT = (Resolve-Path "$PSScriptRoot\..\").Path
$PYI_DIST = Join-Path $ROOT 'build\kinten_backend'
$PKG_DIR = Join-Path $ROOT 'package'
$PKG_ROOT = Join-Path $PKG_DIR 'kinten'
$RELEASE_DIR = Join-Path $ROOT 'frontend\build\windows\x64\runner\Release'

Write-Host "[pkg-win] ROOT=$ROOT"

if (-not $SkipBuild) {
  # 0) Clean Flutter project to avoid stale artifacts
  Write-Host "[pkg-win] Flutter clean + pub get"
  Push-Location (Join-Path $ROOT 'frontend')
  flutter clean | Write-Host
  flutter pub get | Write-Host
  Pop-Location

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
    pyinstaller --distpath .\build\kinten_backend .\kinten_backend.spec | Write-Host
  } else {
    pyinstaller --onefile .\backend\main.py --name kinten_backend --distpath .\build\kinten_backend | Write-Host
  }
  deactivate
  Pop-Location
}

# 3) パッケージフォルダ作成（クリーン）
Write-Host "[pkg-win] Prepare package folder (clean)"
if (Test-Path $PKG_ROOT) { Remove-Item -Recurse -Force $PKG_ROOT }
New-Item -ItemType Directory -Force -Path $PKG_ROOT | Out-Null

# 4) フロントエンド成果物（Releaseフォルダ一式）
Write-Host "[pkg-win] Copy frontend Release -> package"
Copy-Item -Recurse -Force "$RELEASE_DIR\*" "$PKG_ROOT\" | Out-Null

# 4.1) 必須ファイル検証（存在しない場合は失敗）
Write-Host "[pkg-win] Validate required runtime files"
$exePath = Join-Path $PKG_ROOT 'kinten.exe'
$flutterDll1 = Join-Path $PKG_ROOT 'flutter_windows.dll'
$flutterDll2 = Join-Path $PKG_ROOT 'flutter.dll'
$assetsDir = Join-Path $PKG_ROOT 'data\flutter_assets'
$icuData = Join-Path $PKG_ROOT 'data\icudtl.dat'

if (-not (Test-Path $exePath)) {
  throw "Executable not found: $exePath"
}
if (-not (Test-Path $flutterDll1) -and -not (Test-Path $flutterDll2)) {
  throw "Flutter engine DLL not found (expected flutter_windows.dll or flutter.dll) in $PKG_ROOT"
}
if (-not (Test-Path $assetsDir)) {
  throw "Flutter assets directory not found: $assetsDir"
}
if (-not (Test-Path $icuData)) {
  throw "ICU data file not found: $icuData"
}

# 5) バックエンド実行ファイル（Python不要版）
Write-Host "[pkg-win] Copy backend exe"
if (Test-Path (Join-Path $PYI_DIST 'kinten_backend.exe')) {
  Copy-Item -Force (Join-Path $PYI_DIST 'kinten_backend.exe') (Join-Path $PKG_ROOT 'kinten_backend.exe')
}

# 5.1) バックエンドソース一式も同梱（FlutterからPython直呼びのフォールバック用）
Write-Host "[pkg-win] Copy backend source folder"
Copy-Item -Recurse -Force (Join-Path $ROOT 'backend') $PKG_ROOT
 
# 6) テンプレート/入出力/requirements
Write-Host "[pkg-win] Copy templates + create input/output"
Copy-Item -Recurse -Force (Join-Path $ROOT 'templates') $PKG_ROOT
New-Item -ItemType Directory -Force -Path (Join-Path $PKG_ROOT 'input') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $PKG_ROOT 'output') | Out-Null

# Copy sample CSVs into package/input if exist in repo input
$repoInputDir = Join-Path $ROOT 'input'
$destInputDir = Join-Path $PKG_ROOT 'input'
if (Test-Path $repoInputDir) {
  Get-ChildItem -Path $repoInputDir -Filter *.csv -File -ErrorAction SilentlyContinue | ForEach-Object {
    Copy-Item -Force $_.FullName $destInputDir
  }
}

Copy-Item -Force (Join-Path $ROOT 'requirements.txt') $PKG_ROOT
 
# 7) zip 作成
Write-Host "[pkg-win] Create zip"
New-Item -ItemType Directory -Force -Path $PKG_DIR | Out-Null
$zipPath = Join-Path $PKG_DIR 'kinten_windows.zip'
if (Test-Path $zipPath) { Remove-Item -Force $zipPath }
# Include the top-level 'kinten' folder in the zip
Compress-Archive -Path $PKG_ROOT -DestinationPath $zipPath -Force
 
Write-Host "[pkg-win] Done: $zipPath"

