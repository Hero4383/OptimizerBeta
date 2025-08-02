@echo off
setlocal EnableDelayedExpansion
title OptimizerBeta Plugin Installer - Debug Mode
color 0A

:: ================================================================================================
:: SIMPLIFIED DEBUG VERSION
:: ================================================================================================

echo.
echo =============================================
echo    OptimizerBeta Plugin Installer - DEBUG
echo =============================================
echo.

:: Replace YOUR_TOKEN_HERE with the token provided by the developer
set "GITHUB_TOKEN=YOUR_TOKEN_HERE"

:: GitHub repository information
set "REPO_OWNER=Hero4383"
set "REPO_NAME=Optimizer"
set "PLUGIN_NAME=optimizer-1.0-SNAPSHOT.jar"

echo Testing basic setup...
echo Token configured: %GITHUB_TOKEN%
echo.

:: Check if token is configured
if "%GITHUB_TOKEN%"=="YOUR_TOKEN_HERE" (
    echo ERROR: Token not configured!
    echo Please edit this file and replace YOUR_TOKEN_HERE with your actual token.
    echo.
    pause
    exit /b 1
)

echo Token appears to be configured.
echo.

:: Test internet connectivity
echo Testing internet connectivity...
ping -n 1 github.com >nul 2>&1
if %errorlevel% equ 0 (
    echo Internet: OK
) else (
    echo Internet: FAILED
    echo Cannot reach GitHub. Check your internet connection.
    pause
    exit /b 1
)

echo.
echo Testing GitHub access...

:: Test direct access to the JAR file
set "DOWNLOAD_URL=https://raw.githubusercontent.com/%REPO_OWNER%/%REPO_NAME%/master/releases/optimizer-latest.jar"
echo Download URL: %DOWNLOAD_URL%
echo.

:: Try to access the file with curl if available
curl --version >nul 2>&1
if %errorlevel% equ 0 (
    echo Using curl to test access...
    curl -I -H "Authorization: token %GITHUB_TOKEN%" "%DOWNLOAD_URL%" 2>&1
) else (
    echo Curl not available, trying PowerShell...
    powershell -Command "try { $headers = @{'Authorization' = 'token %GITHUB_TOKEN%'}; $response = Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -Headers $headers -Method Head -UseBasicParsing; Write-Host 'Status:' $response.StatusCode; Write-Host 'Success: File is accessible' } catch { Write-Host 'Error:' $_.Exception.Message }"
)

echo.
echo =============================================
echo    Debug test completed
echo =============================================
echo.
echo If you see errors above, that's the problem.
echo If everything looks OK, the main installer should work.
echo.
pause
exit /b 0