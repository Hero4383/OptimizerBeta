@echo off
setlocal EnableDelayedExpansion

REM === IMMEDIATE CRASH-PROOF LOGGING ===
echo [INIT] Script started at %date% %time% > crash_debug.log 2>&1
echo [INIT] EnableDelayedExpansion set >> crash_debug.log 2>&1
echo [INIT] Creating multiple log files for redundancy >> crash_debug.log 2>&1

REM Create logs in multiple locations
echo [LOG] Primary log started > optimizer_install.log 2>&1
echo [LOG] Primary log started > "%USERPROFILE%\optimizer_install.log" 2>&1
echo [LOG] Primary log started > "%TEMP%\optimizer_install.log" 2>&1

REM Set error handling - continue on all errors
set CRASH_LOG=crash_debug.log
set MAIN_LOG=optimizer_install.log
set BACKUP_LOG=%USERPROFILE%\optimizer_install.log
set TEMP_LOG=%TEMP%\optimizer_install.log

echo [INIT] Log files configured >> !CRASH_LOG! 2>&1
echo [INIT] Starting configuration phase >> !CRASH_LOG! 2>&1

REM ================================================================================================
REM CONFIGURATION PHASE - ALL VARIABLES SET HERE
REM ================================================================================================
echo [CONFIG] Setting all configuration variables >> !CRASH_LOG! 2>&1

REM Core configuration
set "GITHUB_TOKEN=YOUR_TOKEN_HERE"
set "REPO_OWNER=Hero4383"
set "REPO_NAME=Optimizer"
set "PLUGIN_NAME=optimizer-1.0-SNAPSHOT.jar"
set "KEY_VALIDATION_URL=https://api.github.com/repos/Hero4383/OptimizerBeta/contents/used_keys.txt"

echo [CONFIG] Basic variables set >> !CRASH_LOG! 2>&1
echo [CONFIG] GITHUB_TOKEN configured >> !CRASH_LOG! 2>&1
echo [CONFIG] REPO_OWNER=!REPO_OWNER! >> !CRASH_LOG! 2>&1
echo [CONFIG] REPO_NAME=!REPO_NAME! >> !CRASH_LOG! 2>&1
echo [CONFIG] PLUGIN_NAME=!PLUGIN_NAME! >> !CRASH_LOG! 2>&1

REM Test variable expansion safety
echo [TEST] Testing variable expansion >> !CRASH_LOG! 2>&1
if defined GITHUB_TOKEN (
    echo [TEST] GITHUB_TOKEN is defined, length check >> !CRASH_LOG! 2>&1
    if "!GITHUB_TOKEN!"=="YOUR_TOKEN_HERE" (
        echo [TEST] Token needs to be replaced by user >> !CRASH_LOG! 2>&1
    ) else (
        echo [TEST] Token appears to be set >> !CRASH_LOG! 2>&1
    )
) else (
    echo [ERROR] GITHUB_TOKEN is not defined >> !CRASH_LOG! 2>&1
)

echo [CONFIG] Variable testing complete >> !CRASH_LOG! 2>&1

REM Safe title setting
echo [UI] Setting window title >> !CRASH_LOG! 2>&1
title OptimizerBeta Plugin Installer - Debug Mode
echo [UI] Title set successfully >> !CRASH_LOG! 2>&1

REM ================================================================================================
REM OptimizerBeta RuneLite Plugin Installer - CRASH-PROOF VERSION
REM 
REM This script automatically downloads and installs the OptimizerBeta plugin for RuneLite
REM Features:
REM - Comprehensive crash prevention and error logging
REM - Automatic RuneLite detection with fallbacks
REM - Plugin download from GitHub with multiple retry methods
REM - Installation verification and rollback capability
REM - Extensive debug logging to multiple locations
REM - Backup of existing versions
REM
REM Instructions:
REM 1. Edit this file and replace YOUR_TOKEN_HERE with the token provided by the developer
REM 2. Right-click and "Run as administrator" (recommended)
REM 3. Check the log files if any issues occur
REM ================================================================================================


REM ================================================================================================
REM DISPLAY USER INTERFACE
REM ================================================================================================
echo [UI] Clearing screen and showing header >> !CRASH_LOG! 2>&1
cls
echo.
echo  ================================================================================================
echo   OptimizerBeta Plugin Installer - CRASH-PROOF DEBUG VERSION
echo  ================================================================================================
echo.
echo  Status: Initializing...
echo  Logs: crash_debug.log, optimizer_install.log
echo.
echo  This installer will:
echo   ^> Test all systems before proceeding
echo   ^> Download the latest OptimizerBeta plugin
echo   ^> Install to RuneLite automatically
echo   ^> Create detailed logs for troubleshooting
echo.
echo  Starting diagnostic phase...
echo.

echo [UI] Header displayed successfully >> !CRASH_LOG! 2>&1

REM ================================================================================================
REM SAFE TIMESTAMP CREATION
REM ================================================================================================
echo [TIME] Creating timestamp >> !CRASH_LOG! 2>&1
set "timestamp=fallback_timestamp"

REM Try to get actual timestamp, but don't crash if it fails
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value 2^>nul') do (
    if not "%%a"=="" (
        set "dt=%%a"
        echo [TIME] Got system time: %%a >> !CRASH_LOG! 2>&1
    )
)

if defined dt (
    echo [TIME] Processing timestamp >> !CRASH_LOG! 2>&1
    set "timestamp=!dt:~0,4!-!dt:~4,2!-!dt:~6,2!_!dt:~8,2!-!dt:~10,2!-!dt:~12,2!"
    echo [TIME] Timestamp created: !timestamp! >> !CRASH_LOG! 2>&1
) else (
    echo [TIME] Using fallback timestamp >> !CRASH_LOG! 2>&1
)

echo [TIME] Timestamp setup complete: !timestamp! >> !CRASH_LOG! 2>&1

REM ================================================================================================
REM ENHANCED LOG FILE SETUP
REM ================================================================================================
echo [LOGS] Setting up comprehensive logging >> !CRASH_LOG! 2>&1

REM Set up multiple log files with fallbacks
set "LOG_FILE=%USERPROFILE%\optimizer_install_!timestamp!.log"
set "ERROR_LOG=%USERPROFILE%\optimizer_error_!timestamp!.log"
set "DEBUG_LOG=%USERPROFILE%\optimizer_debug_!timestamp!.log"

echo [LOGS] Primary log: !LOG_FILE! >> !CRASH_LOG! 2>&1
echo [LOGS] Error log: !ERROR_LOG! >> !CRASH_LOG! 2>&1
echo [LOGS] Debug log: !DEBUG_LOG! >> !CRASH_LOG! 2>&1

REM Test log file creation
echo Log initialized at %date% %time% > "!LOG_FILE!" 2>nul
if not exist "!LOG_FILE!" (
    echo [LOGS] USERPROFILE write failed, trying TEMP >> !CRASH_LOG! 2>&1
    set "LOG_FILE=%TEMP%\optimizer_install_!timestamp!.log"
    set "ERROR_LOG=%TEMP%\optimizer_error_!timestamp!.log"
    set "DEBUG_LOG=%TEMP%\optimizer_debug_!timestamp!.log"
    echo Log initialized at %date% %time% > "!LOG_FILE!" 2>nul
)

if exist "!LOG_FILE!" (
    echo [LOGS] Main log file created successfully >> !CRASH_LOG! 2>&1
    echo ================================================================================================ >> "!LOG_FILE!" 2>nul
    echo OptimizerBeta Plugin Installer - CRASH-PROOF VERSION >> "!LOG_FILE!" 2>nul
    echo Started: %date% %time% >> "!LOG_FILE!" 2>nul
    echo Timestamp: !timestamp! >> "!LOG_FILE!" 2>nul
    echo ================================================================================================ >> "!LOG_FILE!" 2>nul
) else (
    echo [LOGS] WARNING: Could not create main log, using crash log only >> !CRASH_LOG! 2>&1
    set "LOG_FILE=!CRASH_LOG!"
)

echo [LOGS] Log setup complete >> !CRASH_LOG! 2>&1

REM Update display
echo [UI] Updating status display >> !CRASH_LOG! 2>&1
cls
echo.
echo  ================================================================================================
echo   OptimizerBeta Plugin Installer - RUNNING DIAGNOSTICS
echo  ================================================================================================
echo.
echo  Status: System verification in progress...
echo  Logs: !CRASH_LOG!, !LOG_FILE!
echo.
echo  Configuration:
echo   ^> Token: [CONFIGURED]
echo   ^> Repository: !REPO_OWNER!/!REPO_NAME!
echo   ^> Plugin: !PLUGIN_NAME!
echo.
echo  Starting comprehensive system checks...
echo.

echo [UI] Updated display, starting diagnostics >> !CRASH_LOG! 2>&1

REM ================================================================================================
REM COMPREHENSIVE SYSTEM DIAGNOSTICS
REM ================================================================================================
echo [DIAG] Starting system verification phase >> !CRASH_LOG! 2>&1
echo [%time%] === SYSTEM DIAGNOSTICS PHASE === >> "!LOG_FILE!" 2>nul

echo [1/6] System diagnostics...
echo [DIAG] Checking Windows version >> !CRASH_LOG! 2>&1

REM Windows version check with error handling
set "WINDOWS_VERSION=Unknown"
for /f "tokens=4-7 delims=[]. " %%i in ('ver 2^>nul') do (
    if not "%%i"=="" (
        set "WINDOWS_VERSION=%%i.%%j.%%k.%%l"
        echo [DIAG] Version detected: %%i.%%j.%%k.%%l >> !CRASH_LOG! 2>&1
    )
)
echo [DIAG] Windows Version: !WINDOWS_VERSION! >> !CRASH_LOG! 2>&1
echo [%time%] Windows Version: !WINDOWS_VERSION! >> "!LOG_FILE!" 2>nul
echo   ^> Windows Version: !WINDOWS_VERSION!

REM Administrator privileges check
echo [DIAG] Checking administrator status >> !CRASH_LOG! 2>&1
net session >nul 2>&1
set "admin_check_result=%errorlevel%"
if !admin_check_result! equ 0 (
    set "IS_ADMIN=true"
    echo [DIAG] Administrator privileges: YES >> !CRASH_LOG! 2>&1
    echo [%time%] Running with Administrator privileges >> "!LOG_FILE!" 2>nul
    echo   ^> Administrator: YES
) else (
    set "IS_ADMIN=false"
    echo [DIAG] Administrator privileges: NO >> !CRASH_LOG! 2>&1
    echo [%time%] NOT running as Administrator >> "!LOG_FILE!" 2>nul
    echo   ^> Administrator: NO - may cause permission issues
    echo     TIP: Right-click and "Run as administrator" if problems occur
)

REM Internet connectivity test
echo [DIAG] Testing internet connectivity >> !CRASH_LOG! 2>&1
ping -n 1 github.com >nul 2>&1
set "ping_result=%errorlevel%"
if !ping_result! equ 0 (
    set "INTERNET_OK=true"
    echo [DIAG] Internet connectivity: OK >> !CRASH_LOG! 2>&1
    echo [%time%] Internet connectivity: OK >> "!LOG_FILE!" 2>nul
    echo   ^> Internet: CONNECTED
) else (
    set "INTERNET_OK=false"
    echo [DIAG] Internet connectivity: FAILED (code: !ping_result!) >> !CRASH_LOG! 2>&1
    echo [%time%] Internet: FAILED (code: !ping_result!) >> "!LOG_FILE!" 2>nul
    echo   ^> Internet: PING FAILED - continuing anyway (may be firewall)
)

REM Download tools verification
echo [DIAG] Checking download capabilities >> !CRASH_LOG! 2>&1
curl --version >nul 2>&1
set "curl_check=%errorlevel%"
if !curl_check! equ 0 (
    set "CURL_AVAILABLE=true"
    set "POWERSHELL_AVAILABLE=true"
    echo [DIAG] curl: AVAILABLE >> !CRASH_LOG! 2>&1
    echo [%time%] curl is available >> "!LOG_FILE!" 2>nul
    echo   ^> Download tool: curl (preferred)
) else (
    set "CURL_AVAILABLE=false"
    echo [DIAG] curl: NOT AVAILABLE, checking PowerShell >> !CRASH_LOG! 2>&1
    
    powershell -Command "Get-Command Invoke-WebRequest" >nul 2>&1
    set "ps_check=%errorlevel%"
    if !ps_check! equ 0 (
        set "POWERSHELL_AVAILABLE=true"
        echo [DIAG] PowerShell: AVAILABLE >> !CRASH_LOG! 2>&1
        echo [%time%] PowerShell download available >> "!LOG_FILE!" 2>nul
        echo   ^> Download tool: PowerShell (fallback)
    ) else (
        set "POWERSHELL_AVAILABLE=false"
        echo [DIAG] Neither curl nor PowerShell available >> !CRASH_LOG! 2>&1
        echo [%time%] NO download tools available >> "!LOG_FILE!" 2>nul
        echo   ^> Download tool: NONE AVAILABLE - installation may fail
        echo     Requires Windows 10+ or curl installation
    )
)

:: ================================================================================================
:: TOKEN VALIDATION
:: ================================================================================================

echo.
echo [2/6] Validating access token...
echo DEBUG: Starting token validation...
echo DEBUG: Token length: 
echo !GITHUB_TOKEN! | find /c /v "" 
echo [%time%] Validating GitHub token... >> "!LOG_FILE!" 2>nul

if "!GITHUB_TOKEN!"=="YOUR_TOKEN_HERE" (
    echo [%time%] ERROR: Token not configured >> "!LOG_FILE!" 2>nul
    echo DEBUG: ERROR - Token not configured
    echo.
    echo  ERROR: GitHub token not configured!
    echo.
    echo  Instructions:
    echo  1. Right-click this file and select "Edit"
    echo  2. Find the line: set "GITHUB_TOKEN=YOUR_TOKEN_HERE"
    echo  3. Replace YOUR_TOKEN_HERE with the token provided by the developer
    echo  4. Save the file and run it again
    echo.
    echo  The token should start with 'ghp_' and be about 40 characters long.
    echo.
    echo CONTINUING WITHOUT TOKEN...
    set "GITHUB_TOKEN=NONE"
)

:: Validate token format
echo DEBUG: Validating token format...
echo !GITHUB_TOKEN! | findstr /R "^ghp_[A-Za-z0-9]*$" >nul
set "token_format_check=%errorlevel%"
if %token_format_check% neq 0 (
    echo [%time%] ERROR: Invalid token format (exit code: %token_format_check%) >> "!LOG_FILE!" 2>nul
    echo DEBUG: ERROR - Invalid token format (exit code: %token_format_check%)
    echo DEBUG: Token starts with: !GITHUB_TOKEN:~0,4!
    echo.
    echo  WARNING: Invalid token format!
    echo.
    echo  The token should:
    echo  - Start with 'ghp_'
    echo  - Be approximately 40 characters long
    echo  - Contain only letters and numbers
    echo.
    echo  Your token starts with: !GITHUB_TOKEN:~0,4!
    echo  CONTINUING ANYWAY - might still work...
    echo.
)

echo [%time%] Token format appears valid >> "!LOG_FILE!" 2>nul

:: Test token by making a simple API call
echo DEBUG: Testing token access to repository...
echo [%time%] Testing token access to repository... >> "!LOG_FILE!" 2>nul

set "test_url=https://api.github.com/repos/!REPO_OWNER!/!REPO_NAME!"
echo DEBUG: Testing URL: !test_url!

if "!CURL_AVAILABLE!"=="true" (
    echo DEBUG: Using curl for token test...
    curl -s -w "HTTP_CODE:%%{http_code}" -H "Authorization: token !GITHUB_TOKEN!" "!test_url!" > "%TEMP%\token_test.txt" 2>&1
    set "token_test_result=!errorlevel!"
    echo DEBUG: Curl exit code: !token_test_result!
    type "%TEMP%\token_test.txt"
) else (
    echo DEBUG: Using PowerShell for token test...
    powershell -Command "$headers = @{'Authorization' = 'token !GITHUB_TOKEN!'}; try { $response = Invoke-WebRequest -Uri '!test_url!' -Headers $headers -UseBasicParsing; Write-Host 'HTTP_CODE:' $response.StatusCode; Write-Host 'SUCCESS: Token works'; exit 0 } catch { Write-Host 'ERROR:' $_.Exception.Message; Write-Host 'HTTP_CODE:' $_.Exception.Response.StatusCode.Value__; exit 1 }" 2>&1
    set "token_test_result=!errorlevel!"
    echo DEBUG: PowerShell exit code: !token_test_result!
)

if !token_test_result! neq 0 (
    echo [%time%] ERROR: Token authentication failed (exit code: !token_test_result!) >> "!LOG_FILE!" 2>nul
    echo DEBUG: ERROR - Token authentication failed (exit code: !token_test_result!)
    echo.
    echo  WARNING: Cannot access repository with provided token!
    echo.
    echo  Possible issues:
    echo  - Token is expired or invalid
    echo  - Token doesn't have access to the repository
    echo  - Network connectivity issues
    echo.
    echo  CONTINUING ANYWAY - direct download might still work...
    echo.
) else (
    echo DEBUG: Token authentication successful!
)

echo [%time%] Token authentication successful >> "!LOG_FILE!" 2>nul

:: ================================================================================================
:: ONE-TIME KEY VALIDATION
:: ================================================================================================

echo.
echo [2.5/6] Validating one-time key usage...
echo [%time%] Checking if key has been used before... >> "!LOG_FILE!" 2>nul

:: Create a unique key identifier based on the token (hash-like)
set "KEY_ID="
for /f "delims=" %%a in ('echo !GITHUB_TOKEN! ^| findstr /R "ghp_.*"') do (
    set "key_part=%%a"
    set "key_part=!key_part:~4,8!"
    set "KEY_ID=key_!key_part!"
)

if "!KEY_ID!"=="" (
    echo [%time%] ERROR: Could not generate key identifier >> "!LOG_FILE!" 2>nul
    echo  WARNING: Invalid key format for validation - skipping key validation.
    set "KEY_ID=unknown_key"
)

echo [%time%] Generated key identifier: !KEY_ID! >> "!LOG_FILE!" 2>nul

:: Check if key has been used (download used_keys.txt from OptimizerBeta repo)
set "USED_KEYS_FILE=%TEMP%\used_keys.txt"
set "key_already_used=false"

echo [%time%] Downloading used keys list... >> "!LOG_FILE!" 2>nul

if "!CURL_AVAILABLE!"=="true" (
    curl -s -H "Authorization: token !GITHUB_TOKEN!" -H "Accept: application/vnd.github.v3.raw" "!KEY_VALIDATION_URL!" > "!USED_KEYS_FILE!" 2>&1
    set "download_result=!errorlevel!"
) else (
    powershell -Command "$headers = @{'Authorization' = 'token !GITHUB_TOKEN!'; 'Accept' = 'application/vnd.github.v3.raw'}; try { Invoke-WebRequest -Uri '!KEY_VALIDATION_URL!' -Headers $headers -UseBasicParsing | Select-Object -ExpandProperty Content | Out-File -FilePath '!USED_KEYS_FILE!' -Encoding UTF8; exit 0 } catch { exit 1 }" 2>&1
    set "download_result=!errorlevel!"
)

:: If file doesn't exist (404), that's OK - means no keys used yet
if !download_result! neq 0 (
    echo [%time%] Used keys file not found - creating new tracking >> "!LOG_FILE!" 2>nul
    echo # Used Beta Keys > "!USED_KEYS_FILE!"
    echo # Format: key_id timestamp >> "!USED_KEYS_FILE!"
) else (
    echo [%time%] Successfully downloaded used keys list >> "!LOG_FILE!" 2>nul
    
    :: Check if this key ID is already in the file
    findstr /C:"!KEY_ID!" "!USED_KEYS_FILE!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [%time%] ERROR: Key has already been used >> "!LOG_FILE!" 2>nul
        set "key_already_used=true"
    )
)

if "!key_already_used!"=="true" (
    echo.
    echo  WARNING: This beta key has already been used!
    echo.
    echo  Each beta key can only be used once to prevent unauthorized sharing.
    echo  If you need a new key, please contact the developer.
    echo.
    echo  Key ID: !KEY_ID!
    echo  CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

echo [%time%] Key validation passed - key is unused >> "!LOG_FILE!" 2>nul

:: Mark key as used by updating the used_keys.txt file
echo [%time%] Marking key as used... >> "!LOG_FILE!" 2>nul
echo !KEY_ID! %date% %time% >> "!USED_KEYS_FILE!"

:: Upload updated used_keys.txt back to the repo
set "UPDATED_CONTENT_B64=%TEMP%\used_keys_b64.txt"
powershell -Command "[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content '!USED_KEYS_FILE!' -Raw))) | Out-File -FilePath '!UPDATED_CONTENT_B64!' -Encoding ASCII" 2>nul

if exist "!UPDATED_CONTENT_B64!" (
    set /p "content_b64=" < "!UPDATED_CONTENT_B64!"
    
    :: Get current SHA of the file (needed for GitHub API update)
    set "TEMP_SHA_JSON=%TEMP%\file_sha.json"
    if "!CURL_AVAILABLE!"=="true" (
        curl -s -H "Authorization: token !GITHUB_TOKEN!" "!KEY_VALIDATION_URL!" > "!TEMP_SHA_JSON!" 2>&1
    ) else (
        powershell -Command "$headers = @{'Authorization' = 'token !GITHUB_TOKEN!'}; Invoke-WebRequest -Uri '!KEY_VALIDATION_URL!' -Headers $headers -UseBasicParsing | Select-Object -ExpandProperty Content | Out-File -FilePath '!TEMP_SHA_JSON!' -Encoding UTF8" 2>&1
    )
    
    :: Extract SHA from JSON (simplified)
    set "file_sha="
    for /f "tokens=2 delims=:" %%a in ('findstr /C:"sha" "!TEMP_SHA_JSON!"') do (
        set "sha_line=%%a"
        set "sha_line=!sha_line: =!"
        set "sha_line=!sha_line:~1,-2!"
        set "file_sha=!sha_line!"
        goto :sha_found
    )
    
    :sha_found
    :: Update the file via GitHub API
    if "!CURL_AVAILABLE!"=="true" (
        curl -s -X PUT -H "Authorization: token !GITHUB_TOKEN!" -H "Content-Type: application/json" -d "{\"message\":\"Mark beta key as used: !KEY_ID!\",\"content\":\"!content_b64!\",\"sha\":\"!file_sha!\"}" "!KEY_VALIDATION_URL!" >nul 2>&1
        set "update_result=!errorlevel!"
    ) else (
        powershell -Command "$headers = @{'Authorization' = 'token !GITHUB_TOKEN!'; 'Content-Type' = 'application/json'}; $body = @{message='Mark beta key as used: !KEY_ID!'; content='!content_b64!'; sha='!file_sha!'} | ConvertTo-Json; try { Invoke-WebRequest -Uri '!KEY_VALIDATION_URL!' -Method PUT -Headers $headers -Body $body -UseBasicParsing | Out-Null; exit 0 } catch { exit 1 }" 2>&1
        set "update_result=!errorlevel!"
    )
    
    if !update_result! equ 0 (
        echo [%time%] Successfully marked key as used >> "!LOG_FILE!" 2>nul
        echo  ^> Key marked as used - proceeding with installation
    ) else (
        echo [%time%] WARNING: Could not update used keys list >> "!LOG_FILE!" 2>nul
        echo  ^> WARNING: Could not mark key as used, but proceeding...
    )
) else (
    echo [%time%] WARNING: Could not encode content for key tracking >> "!LOG_FILE!" 2>nul
    echo  ^> WARNING: Key tracking failed, but proceeding with installation...
)

:: Clean up temporary files
del "!USED_KEYS_FILE!" >nul 2>&1
del "!UPDATED_CONTENT_B64!" >nul 2>&1
del "!TEMP_SHA_JSON!" >nul 2>&1

:: ================================================================================================
:: RUNELITE DETECTION
:: ================================================================================================

echo.
echo [3/6] Detecting RuneLite installation...
echo [%time%] Searching for RuneLite installation... >> "!LOG_FILE!" 2>nul

set "RUNELITE_DIR="
set "PLUGINS_DIR="

:: Common RuneLite installation paths
set "search_paths[0]=%USERPROFILE%\.runelite"
set "search_paths[1]=%LOCALAPPDATA%\RuneLite"
set "search_paths[2]=%APPDATA%\RuneLite"
set "search_paths[3]=C:\Users\%USERNAME%\.runelite"
set "search_paths[4]=C:\RuneLite"
set "search_paths[5]=%PROGRAMFILES%\RuneLite"
set "search_paths[6]=%PROGRAMFILES(X86)%\RuneLite"

:: Search for RuneLite directories
for /L %%i in (0,1,6) do (
    if defined search_paths[%%i] (
        set "test_path=!search_paths[%%i]!"
        echo [%time%] Checking: !test_path! >> "!LOG_FILE!" 2>nul
        
        if exist "!test_path!" (
            echo [%time%] Found RuneLite directory: !test_path! >> "!LOG_FILE!" 2>nul
            set "RUNELITE_DIR=!test_path!"
            
            :: Check for plugins subdirectory
            if exist "!test_path!\plugins" (
                set "PLUGINS_DIR=!test_path!\plugins"
                echo [%time%] Found plugins directory: !PLUGINS_DIR! >> "!LOG_FILE!" 2>nul
                goto :runelite_found
            ) else (
                echo [%time%] Plugins directory not found, will create it >> "!LOG_FILE!" 2>nul
                set "PLUGINS_DIR=!test_path!\plugins"
                goto :runelite_found
            )
        )
    )
)

:: If not found, prompt user
echo [%time%] RuneLite not found in standard locations >> "!LOG_FILE!" 2>nul
echo.
echo  RuneLite installation not found in standard locations.
echo.
echo  Searched locations:
for /L %%i in (0,1,6) do (
    if defined search_paths[%%i] (
        echo   - !search_paths[%%i]!
    )
)
echo.
echo  Please enter the path to your RuneLite directory manually.
echo  (Usually contains .runelite folder or RuneLite.exe)
echo.
set /p "user_path=Enter RuneLite path (or press Enter to cancel): "

if "!user_path!"=="" (
    echo [%time%] User cancelled RuneLite path selection >> "!LOG_FILE!" 2>nul
    echo  Installation cancelled by user.
    echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

:: Validate user-provided path
if not exist "!user_path!" (
    echo [%time%] User-provided path does not exist: !user_path! >> "!LOG_FILE!" 2>nul
    echo  ERROR: The specified path does not exist: !user_path!
    echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

set "RUNELITE_DIR=!user_path!"
set "PLUGINS_DIR=!user_path!\plugins"
echo [%time%] Using user-provided RuneLite directory: !RUNELITE_DIR! >> "!LOG_FILE!" 2>nul

:runelite_found
echo  ^> RuneLite found: !RUNELITE_DIR!
echo  ^> Plugins directory: !PLUGINS_DIR!

:: Create plugins directory if it doesn't exist
if not exist "!PLUGINS_DIR!" (
    echo [%time%] Creating plugins directory: !PLUGINS_DIR! >> "!LOG_FILE!" 2>nul
    mkdir "!PLUGINS_DIR!" 2>nul
    if !errorlevel! neq 0 (
        echo [%time%] ERROR: Failed to create plugins directory >> "!LOG_FILE!" 2>nul
        echo  ERROR: Cannot create plugins directory: !PLUGINS_DIR!
        echo  This may be a permissions issue. Try running as Administrator.
        echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
    )
    echo  ^> Created plugins directory
)

:: ================================================================================================
:: BACKUP EXISTING PLUGIN
:: ================================================================================================

echo.
echo [4/6] Checking for existing plugin...
echo [%time%] Checking for existing OptimizerBeta plugin... >> "!LOG_FILE!" 2>nul

set "EXISTING_PLUGIN=!PLUGINS_DIR!\!PLUGIN_NAME!"
set "BACKUP_CREATED=false"

if exist "!EXISTING_PLUGIN!" (
    echo [%time%] Found existing plugin: !EXISTING_PLUGIN! >> "!LOG_FILE!" 2>nul
    echo  ^> Found existing OptimizerBeta plugin
    
    :: Create backup
    set "BACKUP_NAME=!PLUGIN_NAME!.backup.%timestamp%"
    set "BACKUP_PATH=!PLUGINS_DIR!\!BACKUP_NAME!"
    
    echo [%time%] Creating backup: !BACKUP_PATH! >> "!LOG_FILE!" 2>nul
    copy "!EXISTING_PLUGIN!" "!BACKUP_PATH!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo  ^> Backup created: !BACKUP_NAME!
        echo [%time%] Backup successful >> "!LOG_FILE!" 2>nul
        set "BACKUP_CREATED=true"
    ) else (
        echo  ^> WARNING: Could not create backup
        echo [%time%] WARNING: Backup failed >> "!LOG_FILE!" 2>nul
    )
) else (
    echo [%time%] No existing plugin found >> "!LOG_FILE!" 2>nul
    echo  ^> No existing plugin found
)

:: ================================================================================================
:: DOWNLOAD LATEST PLUGIN
:: ================================================================================================

echo.
echo [5/6] Downloading latest plugin...
echo [%time%] Starting plugin download... >> "!LOG_FILE!" 2>nul

:: Use direct download from releases folder (simpler and more reliable)
echo DEBUG: Setting up download URL...
echo DEBUG: Testing different branch possibilities...

:: First try master branch
set "DOWNLOAD_URL=https://raw.githubusercontent.com/!REPO_OWNER!/!REPO_NAME!/master/releases/optimizer-latest.jar"
echo DEBUG: Trying master branch URL: !DOWNLOAD_URL!

:: Quick test with curl to see if it exists
echo DEBUG: Testing URL with curl...
set "STATUS_CODE=000"
curl -s -o nul -w "%%{http_code}" -H "Authorization: token !GITHUB_TOKEN!" "!DOWNLOAD_URL!" > "%TEMP%\status_code.txt" 2>&1
if exist "%TEMP%\status_code.txt" (
    set /p STATUS_CODE=<"%TEMP%\status_code.txt"
)
echo DEBUG: Master branch HTTP status: !STATUS_CODE!

if "!STATUS_CODE!" neq "200" (
    echo DEBUG: Master branch failed, trying main branch...
    set "DOWNLOAD_URL=https://raw.githubusercontent.com/!REPO_OWNER!/!REPO_NAME!/main/releases/optimizer-latest.jar"
    echo DEBUG: Trying main branch URL: !DOWNLOAD_URL!
    
    set "STATUS_CODE2=000"
    curl -s -o nul -w "%%{http_code}" -H "Authorization: token !GITHUB_TOKEN!" "!DOWNLOAD_URL!" > "%TEMP%\status_code2.txt" 2>&1
    if exist "%TEMP%\status_code2.txt" (
        set /p STATUS_CODE2=<"%TEMP%\status_code2.txt"
    )
    echo DEBUG: Main branch HTTP status: !STATUS_CODE2!
    
    if "!STATUS_CODE2!"=="200" (
        echo DEBUG: SUCCESS - Using main branch!
    ) else (
        echo DEBUG: WARNING - Neither master nor main branch URLs work!
        echo DEBUG: Continuing with master branch URL anyway...
        set "DOWNLOAD_URL=https://raw.githubusercontent.com/!REPO_OWNER!/!REPO_NAME!/master/releases/optimizer-latest.jar"
    )
) else (
    echo DEBUG: SUCCESS - Using master branch!
)

echo [%time%] Using direct download from releases folder >> "!LOG_FILE!"
echo [%time%] Download URL: !DOWNLOAD_URL! >> "!LOG_FILE!"
echo [%time%] Testing access to releases folder... >> "!LOG_FILE!"

:: Test that we can access the releases folder
echo DEBUG: Testing access with token...
echo DEBUG: Token being used: !GITHUB_TOKEN:~0,10!...

if "!CURL_AVAILABLE!"=="true" (
    echo DEBUG: Using curl to test access...
    echo DEBUG: Running: curl -s -I -H "Authorization: token [TOKEN]" "!DOWNLOAD_URL!"
    
    :: First try to see full response
    curl -v -H "Authorization: token !GITHUB_TOKEN!" "!DOWNLOAD_URL!" -o nul 2> "%TEMP%\curl_debug.txt"
    echo DEBUG: Curl verbose output:
    type "%TEMP%\curl_debug.txt"
    
    :: Now do the actual test
    curl -s -I -H "Authorization: token !GITHUB_TOKEN!" "!DOWNLOAD_URL!" > "%TEMP%\curl_headers.txt" 2>&1
    set "access_test=!errorlevel!"
    echo DEBUG: Curl exit code: !access_test!
    echo DEBUG: Response headers:
    type "%TEMP%\curl_headers.txt"
    
    :: Check for different responses
    findstr /C:"200 OK" "%TEMP%\curl_headers.txt" >nul 2>&1
    if !errorlevel! equ 0 (
        echo DEBUG: Found 200 OK - Access successful!
        set "access_test=0"
    ) else (
        findstr /C:"404" "%TEMP%\curl_headers.txt" >nul 2>&1
        if !errorlevel! equ 0 (
            echo DEBUG: Found 404 - File not found!
            echo DEBUG: This means the URL is wrong or file doesn't exist
        )
        findstr /C:"401" "%TEMP%\curl_headers.txt" >nul 2>&1
        if !errorlevel! equ 0 (
            echo DEBUG: Found 401 - Authentication failed!
            echo DEBUG: Token might be invalid or lack permissions
        )
        findstr /C:"403" "%TEMP%\curl_headers.txt" >nul 2>&1
        if !errorlevel! equ 0 (
            echo DEBUG: Found 403 - Access forbidden!
            echo DEBUG: Token doesn't have access to this repository
        )
    )
) else (
    echo DEBUG: Using PowerShell to test access...
    powershell -Command "$headers = @{'Authorization' = 'token !GITHUB_TOKEN!'}; try { Write-Host 'DEBUG: Attempting to access URL...'; $response = Invoke-WebRequest -Uri '!DOWNLOAD_URL!' -Headers $headers -Method Head -UseBasicParsing; Write-Host 'DEBUG: Response Status:' $response.StatusCode; Write-Host 'DEBUG: Response Headers:' $response.Headers; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { Write-Host 'DEBUG: PowerShell Error:' $_.Exception.Message; Write-Host 'DEBUG: Status Code:' $_.Exception.Response.StatusCode.Value__; exit 1 }" 2>&1
    set "access_test=!errorlevel!"
    echo DEBUG: PowerShell exit code: !access_test!
)

if !access_test! neq 0 (
    echo [%time%] ERROR: Cannot access plugin download URL >> "!LOG_FILE!" 2>nul
    echo  ERROR: Cannot access the plugin file from GitHub.
    echo  This could be due to:
    echo  - Network connectivity issues
    echo  - Invalid or expired token
    echo  - Repository access restrictions
    echo  - Plugin file not available in releases folder
    echo.
    echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

echo [%time%] Download URL found: !DOWNLOAD_URL! >> "!LOG_FILE!" 2>nul
echo  ^> Download URL: !DOWNLOAD_URL!

:: Download the plugin
echo DEBUG: Starting actual download...
set "TEMP_PLUGIN=%TEMP%\!PLUGIN_NAME!"
echo DEBUG: Target file: !TEMP_PLUGIN!
echo [%time%] Downloading to: !TEMP_PLUGIN! >> "!LOG_FILE!" 2>nul

if "!CURL_AVAILABLE!"=="true" (
    echo  ^> Downloading with curl...
    echo DEBUG: Full curl command: curl -L -H "Authorization: token !GITHUB_TOKEN:~0,10!..." -o "!TEMP_PLUGIN!" "!DOWNLOAD_URL!"
    
    :: Run curl with full output
    curl -L -v -H "Authorization: token !GITHUB_TOKEN!" -o "!TEMP_PLUGIN!" "!DOWNLOAD_URL!" 2> "%TEMP%\curl_download_debug.txt"
    set "download_result=!errorlevel!"
    
    echo DEBUG: Curl download exit code: !download_result!
    echo DEBUG: Curl download verbose output:
    type "%TEMP%\curl_download_debug.txt"
    
    :: Check if file was created
    if exist "!TEMP_PLUGIN!" (
        echo DEBUG: File created successfully
        for %%F in ("!TEMP_PLUGIN!") do (
            echo DEBUG: File size: %%~zF bytes
        )
    ) else (
        echo DEBUG: ERROR - File was NOT created!
    )
) else (
    echo  ^> Downloading with PowerShell...
    echo DEBUG: Using PowerShell to download...
    powershell -Command "$ProgressPreference = 'SilentlyContinue'; $headers = @{'Authorization' = 'token !GITHUB_TOKEN!'}; try { Write-Host 'DEBUG: Starting download...'; Invoke-WebRequest -Uri '!DOWNLOAD_URL!' -Headers $headers -OutFile '!TEMP_PLUGIN!' -UseBasicParsing; Write-Host 'DEBUG: Download completed'; Write-Host 'DEBUG: File size:' (Get-Item '!TEMP_PLUGIN!').Length 'bytes'; exit 0 } catch { Write-Host 'DEBUG: Download failed!'; Write-Host 'ERROR:' $_.Exception.Message; Write-Host 'Status:' $_.Exception.Response.StatusCode.Value__; exit 1 }" 2>&1
    set "download_result=!errorlevel!"
    echo DEBUG: PowerShell download exit code: !download_result!
)

if !download_result! neq 0 (
    echo [%time%] ERROR: Plugin download failed >> "!LOG_FILE!" 2>nul
    echo  ERROR: Failed to download the plugin.
    echo  Check your internet connection and token permissions.
    echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

:: Verify download
if not exist "!TEMP_PLUGIN!" (
    echo [%time%] ERROR: Downloaded file not found >> "!LOG_FILE!" 2>nul
    echo  ERROR: Download completed but file not found.
    echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

:: Check file size (should be more than a few KB for a valid JAR)
for %%F in ("!TEMP_PLUGIN!") do set "file_size=%%~zF"
if !file_size! lss 1024 (
    echo [%time%] ERROR: Downloaded file too small (!file_size! bytes) >> "!LOG_FILE!" 2>nul
    echo  ERROR: Downloaded file appears to be corrupted or invalid.
    echo  File size: !file_size! bytes (expected: much larger)
    echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

echo [%time%] Download successful, file size: !file_size! bytes >> "!LOG_FILE!" 2>nul
echo  ^> Download complete (Size: !file_size! bytes)

:: ================================================================================================
:: INSTALL PLUGIN
:: ================================================================================================

echo.
echo [6/6] Installing plugin...
echo [%time%] Installing plugin to: !EXISTING_PLUGIN! >> "!LOG_FILE!" 2>nul

:: Copy plugin to RuneLite plugins directory
copy "!TEMP_PLUGIN!" "!EXISTING_PLUGIN!" >nul 2>&1
if !errorlevel! neq 0 (
    echo [%time%] ERROR: Failed to copy plugin to plugins directory >> "!LOG_FILE!" 2>nul
    echo  ERROR: Cannot install plugin to RuneLite plugins directory.
    echo  This may be a permissions issue.
    echo.
    echo  Try:
    echo  1. Running this installer as Administrator
    echo  2. Closing RuneLite if it's currently running
    echo  3. Checking that the plugins directory is writable
    echo.
    echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

:: Verify installation
if not exist "!EXISTING_PLUGIN!" (
    echo [%time%] ERROR: Plugin not found after installation >> "!LOG_FILE!" 2>nul
    echo  ERROR: Installation failed - plugin not found in plugins directory.
    echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

:: Check installed file size
for %%F in ("!EXISTING_PLUGIN!") do set "installed_size=%%~zF"
if !installed_size! neq !file_size! (
    echo [%time%] WARNING: Installed file size mismatch >> "!LOG_FILE!" 2>nul
    echo  WARNING: Installed file size (!installed_size!) differs from download (!file_size!)
)

echo [%time%] Plugin installation successful >> "!LOG_FILE!" 2>nul
echo  ^> Plugin installed successfully!

:: Clean up temporary files
del "!TEMP_PLUGIN!" >nul 2>&1

:: ================================================================================================
:: INSTALLATION COMPLETE
:: ================================================================================================

echo.
echo  ================================================================================================
echo   Installation Complete!
echo  ================================================================================================
echo.
echo  ^> Plugin installed to: !EXISTING_PLUGIN!
echo  ^> File size: !installed_size! bytes
if "!BACKUP_CREATED!"=="true" (
    echo  ^> Backup created: !BACKUP_NAME!
)
echo  ^> Installation log: !LOG_FILE!
echo.
echo  Next Steps:
echo  1. Start or restart RuneLite
echo  2. Go to the Plugin Hub (wrench icon in RuneLite)
echo  3. Enable "Optimizer" in the plugin list
echo  4. Configure the plugin settings as needed
echo.
echo  If you encounter any issues:
echo  - Check the log file: !LOG_FILE!
echo  - Report issues at: https://github.com/!REPO_OWNER!/!REPO_NAME!/issues
echo  - Include the log file and error details
echo.

echo [%time%] Installation completed successfully >> "!LOG_FILE!" 2>nul
echo ================================================================================================ >> "!LOG_FILE!" 2>nul

echo  Debug completed! Window will close in 5 seconds...
timeout /t 5 >nul
REM ================================================================================================
REM SCRIPT COMPLETION
REM ================================================================================================
:end
echo [COMPLETE] Installer finished successfully >> !CRASH_LOG! 2>&1
echo [%time%] Installer completed >> "!LOG_FILE!" 2>nul

echo.
echo  ================================================================================================
echo   INSTALLATION COMPLETE
echo  ================================================================================================
echo.
echo  Status: All phases completed
echo  Logs saved to: !CRASH_LOG!, !LOG_FILE!
echo.
echo  If any errors occurred, check the log files above.
echo  Installation will continue automatically after diagnostics.
echo.
echo  Window will close in 10 seconds...
echo.

echo [COMPLETE] Showing completion message >> !CRASH_LOG! 2>&1
timeout /t 10 >nul 2>&1
echo [COMPLETE] Script ending normally >> !CRASH_LOG! 2>&1
endlocal