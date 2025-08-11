Write-Host "========================================" -ForegroundColor Green
Write-Host "Kinten Frontend Build Start" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Change to frontend directory
Set-Location frontend

# Get Flutter dependencies
Write-Host "Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

# Build for Windows
Write-Host "Building for Windows..." -ForegroundColor Yellow
flutter build windows --release

# Return to root directory
Set-Location ..

# Create dist folder structure
Write-Host "Creating dist folder structure..." -ForegroundColor Yellow
if (-not (Test-Path "dist")) {
    New-Item -ItemType Directory -Path "dist" -Force
}

# Copy frontend executable and dependencies to dist (support two possible output paths)
Write-Host "Copying frontend files to dist..." -ForegroundColor Yellow
$releasePaths = @(
    "frontend\build\windows\runner\Release\*",
    "frontend\build\windows\x64\runner\Release\*"
)
$copied = $false
foreach ($rp in $releasePaths) {
    if (Test-Path $rp) {
        Copy-Item $rp "dist\" -Recurse -Force
        $copied = $true
        break
    }
}
if (-not $copied) {
    Write-Host "Warning: Release folder not found. Did the Flutter build succeed?" -ForegroundColor Red
}

# Clean up temporary build files
Write-Host "Cleaning up temporary build files..." -ForegroundColor Yellow
if (Test-Path "frontend\build") {
    Remove-Item -Recurse -Force "frontend\build"
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "Frontend build completed!" -ForegroundColor Green
Write-Host "Executable: dist\kinten.exe" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Green

Read-Host "Press Enter to continue"

