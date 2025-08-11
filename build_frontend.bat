@echo off
chcp 65001 >nul
echo ========================================
echo Kinten Frontend Build Start
echo ========================================

REM Change to frontend directory
cd frontend

REM Get Flutter dependencies
echo Getting Flutter dependencies...
flutter pub get

REM Build for Windows
echo Building for Windows...
flutter build windows --release

REM Return to root directory
cd ..

REM Create dist folder structure
echo Creating dist folder structure...
if not exist dist mkdir dist

REM Copy frontend executable and dependencies to dist (support two possible output paths)
echo Copying frontend files to dist...
if exist frontend\build\windows\runner\Release\* (
  xcopy frontend\build\windows\runner\Release\* dist\ /E /I /Y >nul 2>&1
) else if exist frontend\build\windows\x64\runner\Release\* (
  xcopy frontend\build\windows\x64\runner\Release\* dist\ /E /I /Y >nul 2>&1
) else (
  echo Warning: Release folder not found. Did the Flutter build succeed?
)

REM Clean up temporary build files
echo Cleaning up temporary build files...
rmdir /s /q frontend\build

echo ========================================
echo Frontend build completed!
echo Executable: dist\kinten.exe
echo ========================================

pause 