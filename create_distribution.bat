@echo off
chcp 65001 >nul
echo ========================================
echo Kinten Distribution Package Creation
echo ========================================

REM Check if dist folder exists
if not exist dist (
    echo Error: dist folder not found!
    echo Please run build_all.bat first to create the dist folder.
    pause
    exit /b 1
)

REM Create packages folder if not exists
if not exist packages mkdir packages

REM Get current date for filename
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~2,2%"
set "MM=%dt:~6,2%"
set "DD=%dt:~8,2%"
set "HH=%dt:~10,2%"
set "MIN=%dt:~12,2%"

REM Create ZIP filename
set "zipname=kinten_%YYYY%%MM%%DD%_%HH%%MIN%.zip"

echo Creating distribution package: %zipname%

REM Create ZIP file using PowerShell
powershell -command "Compress-Archive -Path 'dist\*' -DestinationPath 'packages\%zipname%' -Force"

if %errorlevel% equ 0 (
    echo ========================================
    echo Distribution package created successfully!
    echo Package: packages\%zipname%
    echo ========================================
    echo.
    echo Package contents:
    echo - kinten.exe (Flutter application)
    echo - kinten_backend.exe (Python backend)
    echo - flutter_windows.dll
    echo - permission_handler_windows_plugin.dll
    echo - templates\ (template files)
    echo - input\ (input folder)
    echo - output\ (output folder)
    echo ========================================
) else (
    echo ========================================
    echo Error: Failed to create distribution package!
    echo ========================================
)

pause 