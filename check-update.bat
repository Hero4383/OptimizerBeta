@echo off
setlocal enabledelayedexpansion
title Optimizer Plugin - Update Checker
color 0B

echo.
echo =============================================
echo    OPTIMIZER PLUGIN - UPDATE CHECKER
echo =============================================
echo.

REM Configuration - Uses token for private repo access
set "GITHUB_TOKEN=YOUR_TOKEN_HERE"
set "GITHUB_REPO=Hero4383/OptimizerBeta"
set "UPDATE_URL=https://api.github.com/repos/%GITHUB_REPO%/releases/latest"
set "PLUGIN_NAME=optimizer-1.0-SNAPSHOT.jar"
set "PLUGINS_DIR=%USERPROFILE%\.runelite\plugins"
set "VERSION_FILE=%~dp0version.txt"

REM Check if token is configured
if "%GITHUB_TOKEN%"=="YOUR_TOKEN_HERE" (
    echo ERROR: Update token not configured!
    echo Please contact the developer for access credentials.
    echo.
    pause
    exit /b 1
)

REM Read current version
if exist "%VERSION_FILE%" (
    set /p CURRENT_VERSION=<"%VERSION_FILE%"
) else (
    set "CURRENT_VERSION=1.0.0"
    echo 1.0.0>"%VERSION_FILE%"
)

echo Current version: %CURRENT_VERSION%
echo Checking for updates...
echo.

REM Download latest release info using GitHub API with token
powershell -Command "try { $headers = @{'Authorization'='token %GITHUB_TOKEN%'}; $release = Invoke-RestMethod -Uri '%UPDATE_URL%' -Headers $headers -ErrorAction Stop; $asset = $release.assets | Where-Object {$_.name -eq '%PLUGIN_NAME%'}; if ($asset) { Write-Output $release.tag_name | Out-File '%TEMP%\optimizer-version-check.txt' -NoNewline; $asset.browser_download_url | Out-File '%TEMP%\optimizer-download-url.txt' -NoNewline; exit 0 } else { exit 2 } } catch { exit 1 }" >nul 2>&1

set RESULT=%errorlevel%

if %RESULT% equ 1 (
    echo Unable to check for updates.
    echo This could mean:
    echo - Invalid or revoked access token
    echo - No internet connection
    echo - Repository access denied
    echo.
    pause
    exit /b 1
)

if %RESULT% equ 2 (
    echo No plugin JAR found in latest release.
    echo Please contact the developer.
    echo.
    pause
    exit /b 1
)

set /p LATEST_VERSION=<"%TEMP%\optimizer-version-check.txt"
del "%TEMP%\optimizer-version-check.txt" >nul 2>&1

if "%CURRENT_VERSION%"=="%LATEST_VERSION%" (
    echo ✓ You have the latest version!
    echo.
    pause
    exit /b 0
)

echo New version available: %LATEST_VERSION%
echo.
set /p UPDATE="Do you want to update now? (y/n): "

if /i "!UPDATE!" neq "y" (
    echo Update cancelled.
    pause
    exit /b 0
)

echo.
echo Downloading update...

REM Download new JAR using URL from release
set /p DOWNLOAD_URL=<"%TEMP%\optimizer-download-url.txt"
del "%TEMP%\optimizer-download-url.txt" >nul 2>&1

powershell -Command "try { $headers = @{'Authorization'='token %GITHUB_TOKEN%'}; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -Headers $headers -OutFile '%TEMP%\optimizer-update.jar' -ErrorAction Stop } catch { exit 1 }" >nul 2>&1

if %errorlevel% neq 0 (
    echo ERROR: Failed to download update!
    echo Your access may have been revoked.
    echo.
    pause
    exit /b 1
)

REM Check if RuneLite is running
tasklist /FI "IMAGENAME eq RuneLite.exe" 2>NUL | find /I /N "RuneLite.exe">NUL
if %errorlevel% equ 0 (
    echo.
    echo WARNING: RuneLite is currently running!
    echo Please close RuneLite and run this updater again.
    echo.
    del "%TEMP%\optimizer-update.jar" >nul 2>&1
    pause
    exit /b 1
)

echo Installing update...

REM Backup and install
if exist "%PLUGINS_DIR%\%PLUGIN_NAME%" (
    copy /Y "%PLUGINS_DIR%\%PLUGIN_NAME%" "%PLUGINS_DIR%\%PLUGIN_NAME%.backup" >nul 2>&1
)

move /Y "%TEMP%\optimizer-update.jar" "%PLUGINS_DIR%\%PLUGIN_NAME%" >nul 2>&1

if %errorlevel% equ 0 (
    REM Update version file
    echo %LATEST_VERSION%>"%VERSION_FILE%"
    
    echo.
    echo =============================================
    echo         UPDATE SUCCESSFUL!
    echo =============================================
    echo.
    echo Updated to version %LATEST_VERSION%
    echo.
) else (
    echo ERROR: Failed to install update!
    if exist "%PLUGINS_DIR%\%PLUGIN_NAME%.backup" (
        move /Y "%PLUGINS_DIR%\%PLUGIN_NAME%.backup" "%PLUGINS_DIR%\%PLUGIN_NAME%" >nul 2>&1
    )
)

pause