@echo off
setlocal enabledelayedexpansion
title Optimizer Plugin - Beta Test Installer
color 0A

echo.
echo =============================================
echo    OPTIMIZER PLUGIN - BETA TEST INSTALLER
echo =============================================
echo.

REM Detect RuneLite plugins directory
set "PLUGINS_DIR=%USERPROFILE%\.runelite\plugins"

REM Check if RuneLite plugins directory exists
if not exist "%PLUGINS_DIR%" (
    echo ERROR: RuneLite plugins directory not found!
    echo.
    echo Please make sure RuneLite is installed and has been run at least once.
    echo Expected location: %PLUGINS_DIR%
    echo.
    echo Creating directory...
    mkdir "%PLUGINS_DIR%" 2>nul
    if %errorlevel% neq 0 (
        echo Failed to create plugins directory!
        pause
        exit /b 1
    )
)

echo Installing Optimizer plugin...
echo.

REM Copy the JAR file
copy /Y "optimizer-1.0-SNAPSHOT.jar" "%PLUGINS_DIR%\" >nul 2>&1

if %errorlevel% equ 0 (
    echo ✓ Plugin installed successfully!
    echo.
    echo Location: %PLUGINS_DIR%\optimizer-1.0-SNAPSHOT.jar
    echo.
    echo =============================================
    echo           INSTALLATION COMPLETE!
    echo =============================================
    echo.
    echo Next steps:
    echo 1. Close RuneLite if it's currently running
    echo 2. Start RuneLite
    echo 3. Go to the wrench icon (Configuration)
    echo 4. Find "Optimizer" in the plugin list
    echo 5. Enable the plugin by checking the box
    echo.
    echo Happy testing!
    echo.
) else (
    echo ERROR: Failed to install plugin!
    echo.
    echo Please try:
    echo 1. Make sure RuneLite is not running
    echo 2. Run this installer as Administrator
    echo 3. Check that optimizer-1.0-SNAPSHOT.jar is in the same folder as this installer
    echo.
)

pause