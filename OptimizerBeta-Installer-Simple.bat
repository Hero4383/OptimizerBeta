@echo off
setlocal EnableDelayedExpansion
title OptimizerBeta Plugin Installer - Simple Debug
color 0A

:: Force console output and simple logging
echo ========================================
echo STARTING DEBUG - Step by step output
echo ========================================

:: Create simple log in user temp (should always work)
set "SIMPLE_LOG=%USERPROFILE%\optimizer_debug.log"
echo Starting debug at %date% %time% > "%SIMPLE_LOG%"

echo STEP 1: Basic setup
echo Token check starting...

:: Replace YOUR_TOKEN_HERE with the token provided by the developer
set "GITHUB_TOKEN=YOUR_TOKEN_HERE"
set "REPO_OWNER=Hero4383"
set "REPO_NAME=Optimizer"

echo Token configured: %GITHUB_TOKEN%
echo Token configured: %GITHUB_TOKEN% >> "%SIMPLE_LOG%"

if "%GITHUB_TOKEN%"=="YOUR_TOKEN_HERE" (
    echo ERROR: Token not configured
    echo ERROR: Token not configured >> "%SIMPLE_LOG%"
) else (
    echo Token appears to be set
    echo Token appears to be set >> "%SIMPLE_LOG%"
)

echo.
echo STEP 2: System checks
echo Checking Windows version...

:: Simple version check
ver
ver >> "%SIMPLE_LOG%"

echo.
echo STEP 3: Admin check
net session >nul 2>&1
if %errorlevel% equ 0 (
    echo Running as ADMIN
    echo Running as ADMIN >> "%SIMPLE_LOG%"
) else (
    echo NOT running as admin
    echo NOT running as admin >> "%SIMPLE_LOG%"
)

echo.
echo STEP 4: Internet test
ping -n 1 google.com
if %errorlevel% equ 0 (
    echo Internet: WORKS
    echo Internet: WORKS >> "%SIMPLE_LOG%"
) else (
    echo Internet: FAILED
    echo Internet: FAILED >> "%SIMPLE_LOG%"
)

echo.
echo STEP 5: Tool check
curl --version
if %errorlevel% equ 0 (
    echo Curl: AVAILABLE
    echo Curl: AVAILABLE >> "%SIMPLE_LOG%"
) else (
    echo Curl: NOT AVAILABLE
    echo Curl: NOT AVAILABLE >> "%SIMPLE_LOG%"
)

echo.
echo STEP 6: GitHub test
set "TEST_URL=https://raw.githubusercontent.com/%REPO_OWNER%/%REPO_NAME%/master/releases/optimizer-latest.jar"
echo Testing URL: %TEST_URL%
echo Testing URL: %TEST_URL% >> "%SIMPLE_LOG%"

curl -I "%TEST_URL%"
set "curl_result=%errorlevel%"
echo Curl result: %curl_result%
echo Curl result: %curl_result% >> "%SIMPLE_LOG%"

echo.
echo ========================================
echo DEBUG COMPLETED
echo ========================================
echo Log saved to: %SIMPLE_LOG%
echo.
echo This window will stay open so you can see all output.
echo Close it manually when done.

:: Don't auto-close - let user see everything
cmd /k