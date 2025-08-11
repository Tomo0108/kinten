Write-Host "========================================" -ForegroundColor Green
Write-Host "Kinten Full Build Start" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Clean previous build
Write-Host "Cleaning previous build..." -ForegroundColor Yellow
if (Test-Path "dist") {
    Remove-Item -Recurse -Force "dist"
}

# Build backend
Write-Host ""
Write-Host "[1/2] Building backend..." -ForegroundColor Cyan
& ".\build_backend.ps1"

# Build frontend
Write-Host ""
Write-Host "[2/2] Building frontend..." -ForegroundColor Cyan
& ".\build_frontend.ps1"

Write-Host "========================================" -ForegroundColor Green
Write-Host "Full build completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Backend: dist\kinten_backend.exe" -ForegroundColor White
Write-Host "Frontend: dist\kinten.exe" -ForegroundColor White
Write-Host "Data folders: dist\templates, dist\input, dist\output" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Distribution folder structure:" -ForegroundColor White
Write-Host "dist\" -ForegroundColor White
Write-Host "├── kinten_backend.exe" -ForegroundColor White
Write-Host "├── kinten.exe" -ForegroundColor White
Write-Host "├── flutter_windows.dll" -ForegroundColor White
Write-Host "├── permission_handler_windows_plugin.dll" -ForegroundColor White
Write-Host "├── templates\" -ForegroundColor White
Write-Host "├── input\" -ForegroundColor White
Write-Host "└── output\" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Green

Read-Host "Press Enter to continue"

