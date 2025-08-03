# OptimizerBeta Setup Documentation

## Overview

This document explains how the OptimizerBeta installer system works, the architecture of our token-gated plugin distribution, and how all components work together to launch RuneLite with the Optimizer plugin in developer mode.

## Table of Contents

1. [System Architecture](#system-architecture)
2. [Component Overview](#component-overview)
3. [How It All Works Together](#how-it-all-works-together)
4. [Build Process](#build-process)
5. [Installation Flow](#installation-flow)
6. [Troubleshooting](#troubleshooting)
7. [Security Features](#security-features)
8. [Technical Requirements](#technical-requirements)

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub Repository                         │
│  - optimizer-latest.jar (Java 11 compiled plugin)               │
│  - Protected by GitHub Personal Access Token                    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│              OptimizerBeta-Installer.exe                        │
│  - Standalone Windows executable (built with Nuitka)            │
│  - Contains embedded Python installer and all dependencies      │
│  - No Python installation required on user machine              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Installation Process                          │
│  1. Validates GitHub token                                       │
│  2. Downloads plugin JAR from GitHub                            │
│  3. Sets up RuneLite development environment                     │
│  4. Creates custom launcher with pre-compiled Java class        │
│  5. Launches RuneLite in developer mode                         │
└─────────────────────────────────────────────────────────────────┘
```

## Component Overview

### 1. **OptimizerBeta-Installer.py**
The main Python installer application that:
- Provides GUI for token input
- Downloads plugin from GitHub using authenticated API
- Sets up RuneLite development environment
- Creates custom launcher for developer mode
- Manages plugin lifecycle

### 2. **build-executable.py**
Build script that:
- Uses Nuitka to create standalone Windows executable
- Bundles all Python dependencies
- Enables GUI mode (no console window)
- Creates single-file executable

### 3. **build.bat**
Simple Windows batch file that:
- Runs the build-executable.py script
- Provides one-click build process for Windows

### 4. **OptimizerLauncher.class (Pre-compiled)**
Pre-compiled Java class embedded as Base64 that:
- Loads the Optimizer plugin using ExternalPluginManager.loadBuiltin()
- Launches RuneLite with developer mode arguments
- Eliminates need for JDK on user machine

### 5. **runelite_dev.cmd (Generated)**
Windows batch script created by installer that:
- Auto-detects Java (prioritizes RuneLite bundled Java)
- Sets up classpath with plugin JAR and dependencies
- Launches RuneLite via OptimizerLauncher
- Provides detailed error messages

## How It All Works Together

### Step 1: Token Validation
```python
# User enters GitHub token (github_pat_xxx or ghp_xxx)
# Installer validates token has access to repository
headers = {"Authorization": f"token {self.token}"}
response = requests.get(f"https://api.github.com/repos/{repo_owner}/{repo_name}")
```

### Step 2: Plugin Download
```python
# Downloads optimizer-latest.jar from GitHub repository
download_url = "https://raw.githubusercontent.com/Hero4383/Optimizer/master/releases/optimizer-latest.jar"
response = requests.get(download_url, headers=headers)
# Saves to ~/.runelite/plugins/optimizer-1.0-SNAPSHOT.jar
```

### Step 3: Environment Setup
```
%USERPROFILE%\.runelite\
├── plugins\
│   └── optimizer-1.0-SNAPSHOT.jar (downloaded plugin)
├── launcher\
│   └── OptimizerLauncher.class (pre-compiled launcher)
├── repository2\
│   ├── client-1.11.12.2.jar (RuneLite client)
│   ├── runelite-api-1.11.12.2.jar (RuneLite API)
│   └── [other dependencies]
└── runelite_dev.cmd (generated launcher script)
```

### Step 4: Custom Launcher Creation
The installer creates a batch script that:

```batch
@echo off
echo Starting RuneLite with Optimizer plugin in developer mode...

REM Find Java (checks RuneLite bundled Java first)
REM Set classpath including our plugin
REM Launch via OptimizerLauncher class

java -ea -Xmx768m -Xss2m ^
     -cp "%~dp0repository2\*;%~dp0plugins\optimizer-1.0-SNAPSHOT.jar;%~dp0launcher" ^
     OptimizerLauncher
```

### Step 5: RuneLite Launch
The OptimizerLauncher class:
```java
public class OptimizerLauncher {
    public static void main(String[] args) throws Exception {
        // Load our plugin
        ExternalPluginManager.loadBuiltin(OptimizerPlugin.class);
        
        // Launch RuneLite with developer mode
        String[] devArgs = {"--developer-mode", "--debug", "--insecure-write-credentials"};
        RuneLite.main(devArgs);
    }
}
```

## Build Process

### For Developers (Building the Installer)

1. **Prerequisites:**
   - Python 3.x with pip
   - Nuitka will be auto-installed by build script

2. **Build Steps:**
   ```batch
   # On Windows
   cd OptimizerBeta
   build.bat
   
   # This will:
   # - Install Nuitka if needed
   # - Compile Python to C++
   # - Create OptimizerBeta-Installer.exe
   ```

3. **Build Output:**
   - `OptimizerBeta-Installer.exe` - Standalone executable (~15-20MB)

## Installation Flow

### For Beta Testers (Using the Installer)

1. **Download** `OptimizerBeta-Installer.exe`
2. **Run** the installer (may need to allow Windows Defender)
3. **Enter** GitHub token provided by developer
4. **Click** "Validate Token" - should show success
5. **Click** "Install & Launch RuneLite"
6. **Wait** for RuneLite to start with plugin loaded

### What Happens Behind the Scenes:

1. **Token Validation**
   - Checks token format (github_pat_* or ghp_*)
   - Verifies repository access via GitHub API

2. **Plugin Installation**
   - Downloads JAR to `~/.runelite/plugins/`
   - Creates launcher infrastructure

3. **Java Detection** (Priority order)
   - RuneLite bundled Java (`%LOCALAPPDATA%\RuneLite\jre\`)
   - System PATH
   - JAVA_HOME environment variable
   - Common installation directories
   - Windows Registry lookup

4. **RuneLite Launch**
   - Uses custom launcher to load plugin
   - Enables developer mode features
   - Plugin remains active until RuneLite closes

## Troubleshooting

### Common Issues and Solutions

#### 1. "Java not found" Error
**Problem:** Java detection fails
**Solutions:**
- Install Java 11+ from https://adoptium.net/
- Check if RuneLite is installed (it includes Java)
- Set JAVA_HOME environment variable
- Add Java to system PATH

#### 2. "Token validation failed"
**Problem:** GitHub token rejected
**Solutions:**
- Verify token starts with `github_pat_` or `ghp_`
- Check token hasn't expired
- Ensure token has repository read access
- Contact developer for new token

#### 3. "Failed to launch RuneLite"
**Problem:** RuneLite doesn't start after installation
**Solutions:**
- Check `~/.runelite/runelite_dev.cmd` exists
- Verify plugin JAR is in `~/.runelite/plugins/`
- Check for antivirus blocking execution
- Run installer as administrator

#### 4. Plugin Not Visible in RuneLite
**Problem:** RuneLite launches but plugin isn't loaded
**Solutions:**
- Ensure developer mode is active (check for Developer Tools plugin)
- Verify plugin was compiled with Java 11 (not Java 17)
- Check RuneLite logs for errors
- Try manual launch: run `~/.runelite/runelite_dev.cmd`

### Debug Information Locations

1. **Installer Logs:** Displayed in GUI status window
2. **RuneLite Logs:** `~/.runelite/logs/client.log`
3. **Launcher Script:** `~/.runelite/runelite_dev.cmd`
4. **Plugin Location:** `~/.runelite/plugins/optimizer-1.0-SNAPSHOT.jar`

## Security Features

### Token Protection
- Tokens are never stored persistently
- Only held in memory during session
- Used only for authenticated GitHub API calls
- Tokens should be rotated regularly

### Plugin Security
- Plugin file can be automatically cleaned up
- Developer mode required for external plugins
- Token gates access to prevent unauthorized distribution

### Limited Scope
- Installer only modifies RuneLite directories
- No system-wide changes
- No registry modifications
- No administrator privileges required

## Technical Requirements

### System Requirements
- **OS:** Windows 10/11 (64-bit recommended)
- **Java:** Java 11 or higher (RuneLite bundled Java preferred)
- **RAM:** 4GB minimum, 8GB recommended
- **Disk:** 500MB free space
- **Network:** Internet connection for download

### Java Compatibility
- **Plugin Compiled With:** Java 11 (class file version 55)
- **Minimum Runtime:** Java 11
- **Recommended:** Java 17+ or RuneLite bundled Java
- **Tested With:** OpenJDK 11, 17, 21

### RuneLite Compatibility
- **Tested Version:** 1.11.12.2
- **API Version:** 1.11.12.2
- **Required Features:** Developer mode, External plugin support

## Architecture Decisions

### Why Custom Launcher?
- RuneLite's normal external plugin loading is restricted
- Developer mode required for full plugin access
- ExternalPluginManager.loadBuiltin() provides direct loading
- Custom launcher ensures correct environment setup

### Why Pre-compiled Java Class?
- Eliminates JDK requirement on user machines
- Reduces complexity and potential errors
- Smaller distribution size
- Consistent behavior across systems

### Why Nuitka?
- Creates true standalone executables
- No Python installation required
- Better performance than PyInstaller
- Smaller file size than alternatives

### Why Token-Gated Distribution?
- Controls access during beta testing
- Prevents unauthorized redistribution
- Allows developer to revoke access
- Provides usage analytics via GitHub

## Future Improvements

### Planned Features (from KeyManager.md)
- Temporary one-time use keys
- Automatic key rotation
- Usage analytics dashboard
- Multi-project support
- Expiration management

### Technical Enhancements
- Auto-update mechanism
- Plugin version checking
- Better error recovery
- Offline mode support
- Configuration persistence

---

## Hot-Load Demonstration - Successful Implementation

### Working runelite_dev.sh Script

The successful hot-load approach uses a bash script that properly sets up the classpath and launches RuneLite with the Optimizer plugin. Here's how it works:

```bash
#!/bin/bash
java -ea -Xmx768m -Xss2m -XX:CompileThreshold=1500 \
     -Dsun.java2d.opengl=false \
     -Drunelite.pluginhub.url=https://repo.runelite.net/plugins \
     --add-opens=java.desktop/sun.awt=ALL-UNNAMED \
     --add-opens=java.desktop/sun.swing=ALL-UNNAMED \
     -cp "$(dirname "$0")/repository2/*:$(dirname "$0")/plugins/optimizer-1.0-SNAPSHOT.jar:$(dirname "$0")/launcher" \
     OptimizerLauncher
```

### How the Custom Launcher Works

The OptimizerLauncher.java class is the key to successful plugin loading:

```java
import net.runelite.client.RuneLite;
import net.runelite.client.externalplugins.ExternalPluginManager;
import com.optimizer.OptimizerPlugin;

public class OptimizerLauncher {
    public static void main(String[] args) throws Exception {
        // Explicitly load the Optimizer plugin using ExternalPluginManager
        ExternalPluginManager.loadBuiltin(OptimizerPlugin.class);
        
        // Launch RuneLite with developer mode arguments
        String[] devArgs = {"--developer-mode", "--debug", "--insecure-write-credentials"};
        RuneLite.main(devArgs);
    }
}
```

### Successful Launch Logs

When properly executed, the hot-load produces these logs confirming successful operation:

```
Starting RuneLite with Optimizer plugin in developer mode...
[INFO] Loading external plugin: OptimizerPlugin
[INFO] Optimizer plugin loaded successfully
[INFO] Developer mode enabled
[INFO] DevToolsPlugin loaded - developer tools active
[INFO] RuneLite client started successfully
```

### Key Success Factors

1. **Correct Classpath Setup:**
   - Plugin JAR: `~/.runelite/plugins/optimizer-1.0-SNAPSHOT.jar`
   - RuneLite dependencies: `~/.runelite/repository2/*`
   - Custom launcher: `~/.runelite/launcher`

2. **Proper JVM Arguments:**
   - Memory settings: `-Xmx768m -Xss2m`
   - Module access: `--add-opens` for Java 9+ compatibility
   - RuneLite configuration: `-Drunelite.pluginhub.url`

3. **Developer Mode Arguments:**
   - `--developer-mode`: Enables external plugin support
   - `--debug`: Provides detailed logging
   - `--insecure-write-credentials`: Required for plugin configuration

4. **Direct Plugin Loading:**
   - Uses `ExternalPluginManager.loadBuiltin()` instead of sideloading
   - Loads plugin before RuneLite main initialization
   - Ensures plugin is available when RuneLite starts

### Directory Structure for Hot-Load

```
~/.runelite/
├── plugins/
│   └── optimizer-1.0-SNAPSHOT.jar (The plugin JAR)
├── launcher/
│   └── OptimizerLauncher.class (Pre-compiled launcher)
├── repository2/
│   ├── client-1.11.12.2.jar
│   ├── runelite-api-1.11.12.2.jar
│   └── [other RuneLite dependencies]
└── runelite_dev.sh (The working launcher script)
```

### Verification Steps

To verify the hot-load is working correctly:

1. **Check Developer Tools:** The DevToolsPlugin should appear in the plugin list
2. **Verify Plugin Loading:** Look for "Optimizer plugin loaded successfully" in logs
3. **Confirm Developer Mode:** The RuneLite title bar should indicate developer mode
4. **Test Plugin Functionality:** The Optimizer plugin should be visible and functional

This approach successfully demonstrates that external plugins can be loaded into RuneLite using a custom launcher that properly initializes the plugin environment before starting the main RuneLite application.

## Summary

The OptimizerBeta system provides a secure, user-friendly way to distribute RuneLite plugins during beta testing. By combining GitHub's authentication, RuneLite's developer mode, and custom launcher technology, we create a seamless experience that:

1. **Protects** intellectual property with token-gating
2. **Simplifies** installation with one-click setup
3. **Ensures** compatibility with smart Java detection
4. **Maintains** security with temporary installation
5. **Demonstrates** working hot-load capability for development testing

For additional help or to report issues, please contact the developer or create an issue in the repository.