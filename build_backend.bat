@echo off
chcp 65001 >nul
echo ========================================
echo Kinten Backend Build Start
echo ========================================

REM Activate virtual environment if not already active
if not defined VIRTUAL_ENV (
    echo Activating virtual environment...
    call venv\Scripts\activate.bat
)

REM Install dependencies
echo Installing dependencies...
pip install -r requirements.txt

REM Check data folders
echo Checking data folders...
if not exist templates (
    echo Creating templates folder...
    mkdir templates
)
if not exist input (
    echo Creating input folder...
    mkdir input
)
if not exist output (
    echo Creating output folder...
    mkdir output
)

REM Check if template file exists
if not exist templates\勤怠表雛形_2025年版.xlsx (
    echo Warning: Template file not found in templates folder
    echo Please place template file in templates folder
)

REM Build with PyInstaller
echo Building with PyInstaller...
pyinstaller kinten_backend.spec

REM Create dist folder structure
echo Creating dist folder structure...
if not exist dist mkdir dist

REM Copy backend executable to dist
echo Copying backend executable to dist...
copy dist\kinten_backend.exe dist\kinten_backend.exe >nul 2>&1

REM Copy data folders to dist
echo Copying data folders to dist...
xcopy templates dist\templates /E /I /Y >nul 2>&1
xcopy input dist\input /E /I /Y >nul 2>&1
xcopy output dist\output /E /I /Y >nul 2>&1

REM Clean up temporary build files
echo Cleaning up temporary build files...
rmdir /s /q build

echo ========================================
echo Backend build completed!
echo Executable: dist\kinten_backend.exe
echo Data folders: dist\templates, dist\input, dist\output
echo ========================================

pause 