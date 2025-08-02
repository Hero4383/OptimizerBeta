# OptimizerBeta - RuneLite Plugin

**Easy One-Click Installation for Beta Testers**

## 🚀 Quick Start

1. **Download** both files from this repository:
   - `README.md` (this file)
   - `OptimizerBeta-Installer.bat`

2. **Get your access token** from the developer

3. **Edit the installer**:
   - Right-click `OptimizerBeta-Installer.bat` → "Edit"
   - Find: `set "GITHUB_TOKEN=YOUR_TOKEN_HERE"`
   - Replace `YOUR_TOKEN_HERE` with the token provided by the developer
   - Save the file (Ctrl+S)

4. **Double-click** `OptimizerBeta-Installer.bat` to run

5. **Follow the prompts** - the installer does everything automatically

6. **Restart RuneLite** and enable the "Optimizer" plugin

## 📋 What You Need

- Windows computer
- RuneLite installed
- Beta access token (provided by developer)
- **Note**: Each token can only be used once

## 🔧 If Something Goes Wrong

The installer has detailed error messages and creates log files to help troubleshoot issues.

**Common fixes:**
- Run as Administrator (right-click installer → "Run as administrator")
- Make sure RuneLite is closed during installation
- Check that your token is copied correctly (no extra spaces)
- **"Key already used" error**: Each beta key can only be used once - contact developer for a new key

## 🧪 What to Test

- Quest automation features
- Task management system
- Economic optimization tools
- Navigation and routing
- Overall stability and performance

## 📞 Need Help?

Create an issue in this repository with:
- What went wrong
- The error message (if any)
- Screenshot of the problem
- Your Windows version

---

**Thank you for beta testing!** 🎮





Setup:

  - Optimizer repo (private) - contains source code
  - OptimizerBeta repo (public) - contains installer for beta testers
  - Beta testers get unique keys that work only once

  Solution: GitHub Release with Token Authentication

  Step 1: Create Release in Private Optimizer Repo

  1. Build your JAR: optimizer-1.0-SNAPSHOT.jar
  2. Create release in private Optimizer repo
  3. Upload JAR as release asset

  Step 2: Generate Fine-Grained Token

  - Repository: Hero4383/Optimizer (private repo)
  - Permissions: Contents: Read only
  - Expiration: Set based on beta testing period

  Step 3: Updated Installer (.bat file)

  set "GITHUB_TOKEN=ghp_xxxxxxxxxxxx"
  set "DOWNLOAD_URL=https://api.github.com/repos/Hero4383/Optimizer/release
  s/latest/assets"

  The installer will:
  1. Use token to access private repo releases
  2. Download the JAR from the latest release
  3. Install it to RuneLite plugins folder

  Step 4: Beta Key System

  For one-time use keys, you'd need:
  - Server endpoint that validates keys
  - Each key can only download once
  - Installer checks key before downloading

  Would you like me to create this updated installer with token
  authentication?

