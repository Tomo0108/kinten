@echo off
chcp 65001 >nul
echo ========================================
echo Kinten Build Cleanup Start
echo ========================================

REM Clean dist folder
echo Cleaning dist folder...
if exist dist (
    rmdir /s /q dist
    echo dist folder removed
) else (
    echo dist folder not found
)

REM Clean frontend build folder
echo Cleaning frontend build folder...
if exist frontend\build (
    rmdir /s /q frontend\build
    echo frontend\build folder removed
) else (
    echo frontend\build folder not found
)

REM Clean backend build folders
echo Cleaning backend build folders...
if exist build (
    rmdir /s /q build
    echo build folder removed
) else (
    echo build folder not found
)

REM Clean distribution folder (legacy)
echo Cleaning legacy distribution folder...
if exist distribution (
    rmdir /s /q distribution
    echo distribution folder removed
) else (
    echo distribution folder not found
)

echo ========================================
echo Build cleanup completed!
echo ========================================

pause 