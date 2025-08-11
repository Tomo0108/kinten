Write-Host "========================================" -ForegroundColor Green
Write-Host "Kinten Backend Build Start" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Activate virtual environment if available
if (-not $env:VIRTUAL_ENV) {
    if (Test-Path ".\venv\Scripts\Activate.ps1") {
        Write-Host "Activating virtual environment..." -ForegroundColor Yellow
        & ".\venv\Scripts\Activate.ps1"
    } else {
        Write-Host "Virtual environment not found. Using system Python/pip." -ForegroundColor Yellow
    }
}

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

# Ensure PyInstaller is available
Write-Host "Checking PyInstaller..." -ForegroundColor Yellow
$pyi = Get-Command pyinstaller -ErrorAction SilentlyContinue
if (-not $pyi) {
    Write-Host "PyInstaller not found. Installing..." -ForegroundColor Yellow
    python -m pip install pyinstaller
}

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

# No need to copy the executable onto itself

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

