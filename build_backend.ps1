Write-Host "========================================" -ForegroundColor Green
Write-Host "Kinten Backend Build Start" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Activate virtual environment if not already active
if (-not $env:VIRTUAL_ENV) {
    Write-Host "Activating virtual environment..." -ForegroundColor Yellow
    & ".\venv\Scripts\Activate.ps1"
}

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
pip install -r requirements.txt

# Check data folders
Write-Host "Checking data folders..." -ForegroundColor Yellow
if (-not (Test-Path "templates")) {
    Write-Host "Creating templates folder..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "templates" -Force
}
if (-not (Test-Path "input")) {
    Write-Host "Creating input folder..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "input" -Force
}
if (-not (Test-Path "output")) {
    Write-Host "Creating output folder..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "output" -Force
}

# Check if template file exists
if (-not (Test-Path "templates\勤怠表雛形_2025年版.xlsx")) {
    Write-Host "Warning: Template file not found in templates folder" -ForegroundColor Red
    Write-Host "Please place template file in templates folder" -ForegroundColor Red
}

# Build with PyInstaller
Write-Host "Building with PyInstaller..." -ForegroundColor Yellow
pyinstaller kinten_backend.spec

# Create dist folder structure
Write-Host "Creating dist folder structure..." -ForegroundColor Yellow
if (-not (Test-Path "dist")) {
    New-Item -ItemType Directory -Path "dist" -Force
}

# Copy backend executable to dist
Write-Host "Copying backend executable to dist..." -ForegroundColor Yellow
Copy-Item "dist\kinten_backend.exe" "dist\kinten_backend.exe" -Force

# Copy data folders to dist
Write-Host "Copying data folders to dist..." -ForegroundColor Yellow
Copy-Item "templates" "dist\templates" -Recurse -Force
Copy-Item "input" "dist\input" -Recurse -Force
Copy-Item "output" "dist\output" -Recurse -Force

# Clean up temporary build files
Write-Host "Cleaning up temporary build files..." -ForegroundColor Yellow
if (Test-Path "build") {
    Remove-Item -Recurse -Force "build"
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "Backend build completed!" -ForegroundColor Green
Write-Host "Executable: dist\kinten_backend.exe" -ForegroundColor White
Write-Host "Data folders: dist\templates, dist\input, dist\output" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Green

Read-Host "Press Enter to continue"

