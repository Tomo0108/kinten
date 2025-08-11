@echo off
chcp 65001 >nul
echo ========================================
echo Kinten Full Build Start
echo ========================================

REM Clean previous build
echo Cleaning previous build...
if exist dist rmdir /s /q dist

REM Build backend
echo.
echo [1/2] Building backend...
call build_backend.bat

REM Build frontend
echo.
echo [2/2] Building frontend...
call build_frontend.bat

echo ========================================
echo Full build completed!
echo ========================================
echo Backend: dist\kinten_backend.exe
echo Frontend: dist\kinten.exe
echo Data folders: dist\templates, dist\input, dist\output
echo ========================================
echo.
echo Distribution folder structure:
echo dist\
echo ├── kinten_backend.exe
echo ├── kinten.exe
echo ├── flutter_windows.dll
echo ├── permission_handler_windows_plugin.dll
echo ├── templates\
echo ├── input\
echo └── output\
echo ========================================

pause 