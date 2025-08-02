# OptimizerBeta - RuneLite Plugin

**Secure Token-Gated Plugin System for Beta Testers**

## 🚀 Quick Start

1. **Download** the installer from this repository:
   - `OptimizerBeta-Installer.exe`

2. **Get your GitHub token** from the developer (fine-grained personal access token)

3. **Double-click** `OptimizerBeta-Installer.exe` to run

4. **In the GUI**:
   - Enter your GitHub token (starts with `github_pat_...`)
   - Click "Validate Token"
   - Click "Install & Launch RuneLite"

5. **The plugin will automatically**:
   - Download and install to RuneLite
   - Launch RuneLite with the plugin active

## 📋 What You Need

- **Windows 10/11** computer
- **RuneLite** installed
- **GitHub token** with access to the private repository
- **Internet connection**

## 🔐 Security Features

- ✅ **Token validation** required every launch
- ✅ **Plugin file removed** after RuneLite loads
- ✅ **No persistent installation** - must use valid token each time
- ✅ **Secure download** from private GitHub repository

## 🖥️ System Requirements

- **Windows 10/11** 
- **RuneLite** installed in standard location

## 🔧 Troubleshooting

**"Token validation failed":**
- Ensure token starts with `github_pat_` or `ghp_`
- Check token hasn't expired
- Verify token has access to Hero4383/Optimizer repository

**"RuneLite not found":**
- Install RuneLite first
- Try running as administrator
- Check that RuneLite is in a standard installation location

**"Download failed":**
- Check internet connection
- Verify token permissions include "Contents: Read"
- Try again (temporary network issues)

**"Plugin not loading in RuneLite":**
- Restart RuneLite if needed
- Check RuneLite's plugin panel
- Ensure you're using the latest RuneLite version

## 🧪 What to Test

- **Quest automation** features and accuracy
- **Task management** system performance
- **Economic optimization** calculations
- **Navigation and routing** efficiency
- **UI/UX** and overall user experience
- **Plugin stability** during extended use

## 📞 Need Help?

Create an issue in this repository with:
- **Detailed description** of the problem
- **Error messages** (full text)
- **Screenshot** if applicable
- **System info**: OS version, Python version, RuneLite version
- **Steps to reproduce** the issue

## 🔄 How It Works

1. **Token Validation**: Authenticates against GitHub API
2. **Secure Download**: Downloads plugin from private repository
3. **Temporary Install**: Installs plugin to RuneLite plugins directory
4. **Auto Launch**: Starts RuneLite with plugin loaded
5. **Security Cleanup**: Removes plugin file (plugin stays in memory)
6. **Session Active**: Plugin works until RuneLite is closed

## ⚠️ Important Notes

- **Keep the installer window open** while using the plugin (optional)
- **Token required each time** you want to use the plugin
- **Plugin disappears** when RuneLite is restarted (by design)
- **No persistent installation** - this is a security feature
- **One token per session** - get new token for each use period

---

**Thank you for beta testing!** 🎮

Your feedback helps improve the Optimizer plugin for the entire RuneLite community.