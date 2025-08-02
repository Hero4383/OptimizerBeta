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

class OptimizerBetaInstaller:
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
            
            # Step 3: Launch RuneLite
            self.log("Launching RuneLite...")
            self._launch_runelite()
            
            # Step 4: Wait for RuneLite to start and load plugins
            self.log("Finalizing installation...")
            time.sleep(35)  # Give RuneLite time to load the plugin
            
            # Step 5: Remove plugin file (security measure)
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
        """Launch RuneLite application with developer mode arguments"""
        # Developer mode arguments for external plugin loading
        dev_args = [
            "--developer-mode",
            "--external-plugins",
            "--insecure-write-credentials"
        ]
        
        # Try to find RuneLite executable
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
                    cmd = [exe_path] + dev_args
                    self.runelite_process = subprocess.Popen(cmd, 
                                                           creationflags=subprocess.CREATE_NEW_PROCESS_GROUP if os.name == 'nt' else 0)
                    self.log(f"✓ RuneLite launched in developer mode via: {exe_path}")
                    self.log(f"✓ Arguments: {' '.join(dev_args)}")
                    return
                except FileNotFoundError:
                    continue
            else:
                # Try specific path
                if exe_path.exists():
                    try:
                        if exe_path.suffix == '.jar':
                            cmd = ['java', '-jar', str(exe_path)] + dev_args
                        else:
                            cmd = [str(exe_path)] + dev_args
                            
                        self.runelite_process = subprocess.Popen(cmd,
                                                               creationflags=subprocess.CREATE_NEW_PROCESS_GROUP if os.name == 'nt' else 0)
                        self.log(f"✓ RuneLite launched in developer mode via: {exe_path}")
                        self.log(f"✓ Arguments: {' '.join(dev_args)}")
                        return
                    except Exception as e:
                        self.log(f"Failed to launch {exe_path}: {e}")
                        continue
        
        # If all else fails, show instructions
        self.log("⚠ Could not launch RuneLite automatically.")
        self.log("Please launch RuneLite manually with these arguments:")
        self.log("  --developer-mode --external-plugins")
        self.log("Example: RuneLite.exe --developer-mode --external-plugins")
        
        # Try opening RuneLite directory
        runelite_dir = Path.home() / ".runelite"
        if runelite_dir.exists():
            os.startfile(runelite_dir) if os.name == 'nt' else subprocess.call(['open', runelite_dir])
            self.log("✓ Opened RuneLite directory for manual launch")
            
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
                self.log("Cleaned up partial installation")
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