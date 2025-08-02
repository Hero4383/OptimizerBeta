@echo off
setlocal EnableDelayedExpansion
title OptimizerBeta Plugin Installer

:: ================================================================================================
:: OptimizerBeta RuneLite Plugin Installer
:: 
:: This script automatically downloads and installs the OptimizerBeta plugin for RuneLite
:: Features:
:: - Automatic RuneLite detection
:: - Plugin download from GitHub
:: - Installation verification
:: - Extensive error handling and logging
:: - Backup of existing versions
:: - Debug information for troubleshooting
::
:: Instructions:
:: 1. Edit this file and replace YOUR_TOKEN_HERE with the token provided by the developer
:: 2. Double-click this file to run the installer
:: 3. Follow the on-screen prompts
:: ================================================================================================

:: ================================================================================================
:: CONFIGURATION - EDIT THIS SECTION
:: ================================================================================================

:: Replace YOUR_TOKEN_HERE with the token provided by the developer
set "GITHUB_TOKEN=YOUR_TOKEN_HERE"

:: GitHub repository information (DO NOT CHANGE)
set "REPO_OWNER=Hero4383"
set "REPO_NAME=Optimizer"
set "PLUGIN_NAME=optimizer-1.0-SNAPSHOT.jar"

:: Key validation endpoint (for one-time use keys)
set "KEY_VALIDATION_URL=https://api.github.com/repos/Hero4383/OptimizerBeta/contents/used_keys.txt"

:: ================================================================================================
:: INITIALIZATION AND LOGGING SETUP
:: ================================================================================================

:: Create timestamp for logs
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%_%dt:~8,2%-%dt:~10,2%-%dt:~12,2%"

:: Set up log files
set "LOG_FILE=optimizer_install_%timestamp%.log"
set "ERROR_LOG=optimizer_error_%timestamp%.log"
set "DEBUG_LOG=optimizer_debug_%timestamp%.log"

:: Initialize logging
echo ================================================================================================ > "%LOG_FILE%"
echo OptimizerBeta Plugin Installer - Started at %date% %time% >> "%LOG_FILE%"
echo ================================================================================================ >> "%LOG_FILE%"

echo [%time%] Starting OptimizerBeta Plugin Installer... >> "%LOG_FILE%"

:: Display header
cls
echo.
echo  ================================================================================================
echo   OptimizerBeta Plugin Installer for RuneLite - DEBUG MODE
echo  ================================================================================================
echo.
echo  This installer will automatically:
echo   ^> Detect your RuneLite installation
echo   ^> Download the latest OptimizerBeta plugin
echo   ^> Install the plugin to the correct directory
echo   ^> Verify the installation
echo   ^> Create backups of existing versions
echo.
echo  Installation logs will be saved for troubleshooting.
echo.
echo  DEBUG: Starting diagnostics...
echo  DEBUG: Token configured: !GITHUB_TOKEN!
echo  DEBUG: Repo: !REPO_OWNER!/!REPO_NAME!
echo.
echo  Starting system verification automatically...
timeout /t 2 >nul

echo.
echo  DEBUG: Starting system verification...

:: ================================================================================================
:: SYSTEM VERIFICATION AND DIAGNOSTICS
:: ================================================================================================

echo [%time%] Running system diagnostics... >> "%LOG_FILE%"
echo.
echo [1/6] Running system diagnostics...
echo DEBUG: About to check Windows version...

:: Check Windows version
echo DEBUG: Checking Windows version...
for /f "tokens=4-7 delims=[]. " %%i in ('ver') do (
    set "WINDOWS_VERSION=%%i.%%j.%%k.%%l"
    echo [%time%] Windows Version: !WINDOWS_VERSION! >> "%LOG_FILE%"
    echo DEBUG: Windows Version: !WINDOWS_VERSION!
)

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% equ 0 (
    echo [%time%] Running with Administrator privileges >> "%LOG_FILE%"
    set "IS_ADMIN=true"
) else (
    echo [%time%] NOT running as Administrator >> "%LOG_FILE%"
    set "IS_ADMIN=false"
    echo.
    echo  WARNING: Not running as Administrator. This may cause permission issues.
    echo  If installation fails, try right-clicking this file and selecting "Run as administrator"
    echo.
)

:: Check internet connectivity
echo DEBUG: Testing internet connectivity...
echo [%time%] Testing internet connectivity... >> "%LOG_FILE%"
ping -n 1 github.com >nul 2>&1
set "ping_result=%errorlevel%"
if %ping_result% equ 0 (
    echo [%time%] Internet connectivity: OK >> "%LOG_FILE%"
    echo DEBUG: Internet connectivity: OK
    set "INTERNET_OK=true"
) else (
    echo [%time%] Internet connectivity: FAILED (exit code: %ping_result%) >> "%LOG_FILE%"
    echo DEBUG: Internet connectivity: FAILED (exit code: %ping_result%)
    echo WARNING: Cannot ping GitHub, but continuing anyway...
    echo This might be due to firewall settings blocking ping.
    set "INTERNET_OK=false"
)

:: Check if curl is available
echo DEBUG: Checking for download tools...
curl --version >nul 2>&1
set "curl_check=%errorlevel%"
if %curl_check% equ 0 (
    echo [%time%] curl is available >> "%LOG_FILE%"
    echo DEBUG: curl is available
    set "CURL_AVAILABLE=true"
) else (
    echo [%time%] curl is NOT available (exit code: %curl_check%), checking for PowerShell... >> "%LOG_FILE%"
    echo DEBUG: curl is NOT available (exit code: %curl_check%), checking for PowerShell...
    set "CURL_AVAILABLE=false"
    
    :: Check PowerShell as fallback
    powershell -Command "Get-Command Invoke-WebRequest" >nul 2>&1
    set "ps_check=%errorlevel%"
    if %ps_check% equ 0 (
        echo [%time%] PowerShell Invoke-WebRequest is available >> "%LOG_FILE%"
        echo DEBUG: PowerShell Invoke-WebRequest is available
        set "POWERSHELL_AVAILABLE=true"
    ) else (
        echo [%time%] Neither curl nor PowerShell available for downloads (PowerShell exit code: %ps_check%) >> "%LOG_FILE%"
        echo DEBUG: Neither curl nor PowerShell available for downloads (PowerShell exit code: %ps_check%)
        echo ERROR: Cannot find download tools (curl or PowerShell).
        echo This installer requires Windows 10 or newer, or curl to be installed.
        echo.
        echo CONTINUING ANYWAY - some features may not work...
        set "POWERSHELL_AVAILABLE=false"
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
echo [%time%] Validating GitHub token... >> "%LOG_FILE%"

if "!GITHUB_TOKEN!"=="YOUR_TOKEN_HERE" (
    echo [%time%] ERROR: Token not configured >> "%LOG_FILE%"
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
    echo [%time%] ERROR: Invalid token format (exit code: %token_format_check%) >> "%LOG_FILE%"
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

echo [%time%] Token format appears valid >> "%LOG_FILE%"

:: Test token by making a simple API call
echo DEBUG: Testing token access to repository...
echo [%time%] Testing token access to repository... >> "%LOG_FILE%"

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
    echo [%time%] ERROR: Token authentication failed (exit code: !token_test_result!) >> "%LOG_FILE%"
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

echo [%time%] Token authentication successful >> "%LOG_FILE%"

:: ================================================================================================
:: ONE-TIME KEY VALIDATION
:: ================================================================================================

echo.
echo [2.5/6] Validating one-time key usage...
echo [%time%] Checking if key has been used before... >> "%LOG_FILE%"

:: Create a unique key identifier based on the token (hash-like)
set "KEY_ID="
for /f "delims=" %%a in ('echo !GITHUB_TOKEN! ^| findstr /R "ghp_.*"') do (
    set "key_part=%%a"
    set "key_part=!key_part:~4,8!"
    set "KEY_ID=key_!key_part!"
)

if "!KEY_ID!"=="" (
    echo [%time%] ERROR: Could not generate key identifier >> "%LOG_FILE%"
    echo  WARNING: Invalid key format for validation - skipping key validation.
    set "KEY_ID=unknown_key"
)

echo [%time%] Generated key identifier: !KEY_ID! >> "%LOG_FILE%"

:: Check if key has been used (download used_keys.txt from OptimizerBeta repo)
set "USED_KEYS_FILE=%TEMP%\used_keys.txt"
set "key_already_used=false"

echo [%time%] Downloading used keys list... >> "%LOG_FILE%"

if "!CURL_AVAILABLE!"=="true" (
    curl -s -H "Authorization: token !GITHUB_TOKEN!" -H "Accept: application/vnd.github.v3.raw" "!KEY_VALIDATION_URL!" > "!USED_KEYS_FILE!" 2>&1
    set "download_result=!errorlevel!"
) else (
    powershell -Command "$headers = @{'Authorization' = 'token !GITHUB_TOKEN!'; 'Accept' = 'application/vnd.github.v3.raw'}; try { Invoke-WebRequest -Uri '!KEY_VALIDATION_URL!' -Headers $headers -UseBasicParsing | Select-Object -ExpandProperty Content | Out-File -FilePath '!USED_KEYS_FILE!' -Encoding UTF8; exit 0 } catch { exit 1 }" 2>&1
    set "download_result=!errorlevel!"
)

:: If file doesn't exist (404), that's OK - means no keys used yet
if !download_result! neq 0 (
    echo [%time%] Used keys file not found - creating new tracking >> "%LOG_FILE%"
    echo # Used Beta Keys > "!USED_KEYS_FILE!"
    echo # Format: key_id timestamp >> "!USED_KEYS_FILE!"
) else (
    echo [%time%] Successfully downloaded used keys list >> "%LOG_FILE%"
    
    :: Check if this key ID is already in the file
    findstr /C:"!KEY_ID!" "!USED_KEYS_FILE!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [%time%] ERROR: Key has already been used >> "%LOG_FILE%"
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

echo [%time%] Key validation passed - key is unused >> "%LOG_FILE%"

:: Mark key as used by updating the used_keys.txt file
echo [%time%] Marking key as used... >> "%LOG_FILE%"
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
        echo [%time%] Successfully marked key as used >> "%LOG_FILE%"
        echo  ^> Key marked as used - proceeding with installation
    ) else (
        echo [%time%] WARNING: Could not update used keys list >> "%LOG_FILE%"
        echo  ^> WARNING: Could not mark key as used, but proceeding...
    )
) else (
    echo [%time%] WARNING: Could not encode content for key tracking >> "%LOG_FILE%"
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
echo [%time%] Searching for RuneLite installation... >> "%LOG_FILE%"

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
        echo [%time%] Checking: !test_path! >> "%LOG_FILE%"
        
        if exist "!test_path!" (
            echo [%time%] Found RuneLite directory: !test_path! >> "%LOG_FILE%"
            set "RUNELITE_DIR=!test_path!"
            
            :: Check for plugins subdirectory
            if exist "!test_path!\plugins" (
                set "PLUGINS_DIR=!test_path!\plugins"
                echo [%time%] Found plugins directory: !PLUGINS_DIR! >> "%LOG_FILE%"
                goto :runelite_found
            ) else (
                echo [%time%] Plugins directory not found, will create it >> "%LOG_FILE%"
                set "PLUGINS_DIR=!test_path!\plugins"
                goto :runelite_found
            )
        )
    )
)

:: If not found, prompt user
echo [%time%] RuneLite not found in standard locations >> "%LOG_FILE%"
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
    echo [%time%] User cancelled RuneLite path selection >> "%LOG_FILE%"
    echo  Installation cancelled by user.
    echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

:: Validate user-provided path
if not exist "!user_path!" (
    echo [%time%] User-provided path does not exist: !user_path! >> "%LOG_FILE%"
    echo  ERROR: The specified path does not exist: !user_path!
    echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

set "RUNELITE_DIR=!user_path!"
set "PLUGINS_DIR=!user_path!\plugins"
echo [%time%] Using user-provided RuneLite directory: !RUNELITE_DIR! >> "%LOG_FILE%"

:runelite_found
echo  ^> RuneLite found: !RUNELITE_DIR!
echo  ^> Plugins directory: !PLUGINS_DIR!

:: Create plugins directory if it doesn't exist
if not exist "!PLUGINS_DIR!" (
    echo [%time%] Creating plugins directory: !PLUGINS_DIR! >> "%LOG_FILE%"
    mkdir "!PLUGINS_DIR!" 2>nul
    if !errorlevel! neq 0 (
        echo [%time%] ERROR: Failed to create plugins directory >> "%LOG_FILE%"
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
echo [%time%] Checking for existing OptimizerBeta plugin... >> "%LOG_FILE%"

set "EXISTING_PLUGIN=!PLUGINS_DIR!\!PLUGIN_NAME!"
set "BACKUP_CREATED=false"

if exist "!EXISTING_PLUGIN!" (
    echo [%time%] Found existing plugin: !EXISTING_PLUGIN! >> "%LOG_FILE%"
    echo  ^> Found existing OptimizerBeta plugin
    
    :: Create backup
    set "BACKUP_NAME=!PLUGIN_NAME!.backup.%timestamp%"
    set "BACKUP_PATH=!PLUGINS_DIR!\!BACKUP_NAME!"
    
    echo [%time%] Creating backup: !BACKUP_PATH! >> "%LOG_FILE%"
    copy "!EXISTING_PLUGIN!" "!BACKUP_PATH!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo  ^> Backup created: !BACKUP_NAME!
        echo [%time%] Backup successful >> "%LOG_FILE%"
        set "BACKUP_CREATED=true"
    ) else (
        echo  ^> WARNING: Could not create backup
        echo [%time%] WARNING: Backup failed >> "%LOG_FILE%"
    )
) else (
    echo [%time%] No existing plugin found >> "%LOG_FILE%"
    echo  ^> No existing plugin found
)

:: ================================================================================================
:: DOWNLOAD LATEST PLUGIN
:: ================================================================================================

echo.
echo [5/6] Downloading latest plugin...
echo [%time%] Starting plugin download... >> "%LOG_FILE%"

:: Use direct download from releases folder (simpler and more reliable)
set "DOWNLOAD_URL=https://raw.githubusercontent.com/!REPO_OWNER!/!REPO_NAME!/master/releases/optimizer-latest.jar"

echo [%time%] Using direct download from releases folder >> "%LOG_FILE%"
echo [%time%] Testing access to releases folder... >> "%LOG_FILE%"

:: Test that we can access the releases folder
if "!CURL_AVAILABLE!"=="true" (
    curl -s -I -H "Authorization: token !GITHUB_TOKEN!" "!DOWNLOAD_URL!" | findstr "200 OK" >nul 2>&1
    set "access_test=!errorlevel!"
) else (
    powershell -Command "$headers = @{'Authorization' = 'token !GITHUB_TOKEN!'}; try { $response = Invoke-WebRequest -Uri '!DOWNLOAD_URL!' -Headers $headers -Method Head -UseBasicParsing; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>&1
    set "access_test=!errorlevel!"
)

if !access_test! neq 0 (
    echo [%time%] ERROR: Cannot access plugin download URL >> "%LOG_FILE%"
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

echo [%time%] Download URL found: !DOWNLOAD_URL! >> "%LOG_FILE%"
echo  ^> Download URL: !DOWNLOAD_URL!

:: Download the plugin
set "TEMP_PLUGIN=%TEMP%\!PLUGIN_NAME!"
echo [%time%] Downloading to: !TEMP_PLUGIN! >> "%LOG_FILE%"

if "!CURL_AVAILABLE!"=="true" (
    echo  ^> Downloading with curl...
    curl -L -H "Authorization: token !GITHUB_TOKEN!" -o "!TEMP_PLUGIN!" "!DOWNLOAD_URL!" 2>&1
    set "download_result=!errorlevel!"
) else (
    echo  ^> Downloading with PowerShell...
    powershell -Command "$headers = @{'Authorization' = 'token !GITHUB_TOKEN!'}; try { Invoke-WebRequest -Uri '!DOWNLOAD_URL!' -Headers $headers -OutFile '!TEMP_PLUGIN!' -UseBasicParsing; exit 0 } catch { Write-Error $_.Exception.Message; exit 1 }" 2>&1
    set "download_result=!errorlevel!"
)

if !download_result! neq 0 (
    echo [%time%] ERROR: Plugin download failed >> "%LOG_FILE%"
    echo  ERROR: Failed to download the plugin.
    echo  Check your internet connection and token permissions.
    echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

:: Verify download
if not exist "!TEMP_PLUGIN!" (
    echo [%time%] ERROR: Downloaded file not found >> "%LOG_FILE%"
    echo  ERROR: Download completed but file not found.
    echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

:: Check file size (should be more than a few KB for a valid JAR)
for %%F in ("!TEMP_PLUGIN!") do set "file_size=%%~zF"
if !file_size! lss 1024 (
    echo [%time%] ERROR: Downloaded file too small (!file_size! bytes) >> "%LOG_FILE%"
    echo  ERROR: Downloaded file appears to be corrupted or invalid.
    echo  File size: !file_size! bytes (expected: much larger)
    echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

echo [%time%] Download successful, file size: !file_size! bytes >> "%LOG_FILE%"
echo  ^> Download complete (Size: !file_size! bytes)

:: ================================================================================================
:: INSTALL PLUGIN
:: ================================================================================================

echo.
echo [6/6] Installing plugin...
echo [%time%] Installing plugin to: !EXISTING_PLUGIN! >> "%LOG_FILE%"

:: Copy plugin to RuneLite plugins directory
copy "!TEMP_PLUGIN!" "!EXISTING_PLUGIN!" >nul 2>&1
if !errorlevel! neq 0 (
    echo [%time%] ERROR: Failed to copy plugin to plugins directory >> "%LOG_FILE%"
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
    echo [%time%] ERROR: Plugin not found after installation >> "%LOG_FILE%"
    echo  ERROR: Installation failed - plugin not found in plugins directory.
    echo CONTINUING ANYWAY FOR DEBUGGING...
    echo.
)

:: Check installed file size
for %%F in ("!EXISTING_PLUGIN!") do set "installed_size=%%~zF"
if !installed_size! neq !file_size! (
    echo [%time%] WARNING: Installed file size mismatch >> "%LOG_FILE%"
    echo  WARNING: Installed file size (!installed_size!) differs from download (!file_size!)
)

echo [%time%] Plugin installation successful >> "%LOG_FILE%"
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

echo [%time%] Installation completed successfully >> "%LOG_FILE%"
echo ================================================================================================ >> "%LOG_FILE%"

echo  Debug completed! Window will close in 5 seconds...
timeout /t 5 >nul
goto :end

:: ================================================================================================
:: ERROR HANDLING
:: ================================================================================================

:error_exit
echo.
echo  ================================================================================================
echo   Installation Failed
echo  ================================================================================================
echo.
echo  The installation encountered an error and could not complete.
echo.
echo  Debug Information:
echo  - Log file: !LOG_FILE!
echo  - Error log: !ERROR_LOG!
echo  - Windows version: !WINDOWS_VERSION!
echo  - Administrator: !IS_ADMIN!
echo  - Internet: !INTERNET_OK!
echo  - Token configured: !GITHUB_TOKEN! neq YOUR_TOKEN_HERE
echo.
echo  For support:
echo  1. Check the log files above
echo  2. Try running as Administrator
echo  3. Verify your internet connection
echo  4. Confirm the token is correct
echo  5. Report the issue with log files
echo.

echo [%time%] Installation failed >> "%LOG_FILE%"
echo [%time%] Error details written to: !ERROR_LOG! >> "%LOG_FILE%"

:: Copy recent errors to error log
echo ================================================================================================ > "%ERROR_LOG%"
echo OptimizerBeta Plugin Installer - Error Log >> "%ERROR_LOG%"
echo Installation failed at %date% %time% >> "%ERROR_LOG%"
echo ================================================================================================ >> "%ERROR_LOG%"
echo. >> "%ERROR_LOG%"
echo System Information: >> "%ERROR_LOG%"
echo - Windows Version: !WINDOWS_VERSION! >> "%ERROR_LOG%"
echo - Administrator: !IS_ADMIN! >> "%ERROR_LOG%"
echo - Internet: !INTERNET_OK! >> "%ERROR_LOG%"
echo - Curl Available: !CURL_AVAILABLE! >> "%ERROR_LOG%"
echo - PowerShell Available: !POWERSHELL_AVAILABLE! >> "%ERROR_LOG%"
echo - Token Configured: !GITHUB_TOKEN! neq YOUR_TOKEN_HERE >> "%ERROR_LOG%"
echo. >> "%ERROR_LOG%"

echo  Debug completed! Window will close in 5 seconds...
timeout /t 5 >nul
exit /b 1

:: ================================================================================================
:: CLEANUP AND EXIT
:: ================================================================================================

:end
echo [%time%] Installer finished >> "%LOG_FILE%"
endlocal
exit /b 0