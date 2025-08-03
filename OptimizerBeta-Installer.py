#!/usr/bin/env python3
"""
OptimizerBeta Plugin Installer
Token-gated RuneLite plugin distribution system with developer mode integration
"""

import os
import sys
import json
import requests
import subprocess
import threading
import datetime
from pathlib import Path
import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext

class OptimizerBetaInstaller:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("OptimizerBeta Plugin Installer")
        self.root.geometry("600x500")
        self.root.resizable(True, True)
        
        # Set window icon if optimizer.png exists
        try:
            icon_path = Path(__file__).parent / "optimizer.png"
            if icon_path.exists():
                from PIL import Image, ImageTk
                icon_image = Image.open(icon_path)
                icon_photo = ImageTk.PhotoImage(icon_image.resize((32, 32)))
                self.root.iconphoto(False, icon_photo)
        except Exception:
            # If PIL not available or icon not found, continue without icon
            pass
        
        # Configuration
        self.github_repo_owner = "Hero4383"
        self.github_repo_name = "Optimizer"
        self.plugin_download_url = "https://raw.githubusercontent.com/Hero4383/Optimizer/master/releases/optimizer-latest.jar"
        
        # State variables
        self.token = None
        self.runelite_dir = None
        self.plugins_dir = None
        self.sideloaded_plugins_dir = None
        self.repository_dir = None
        self.runelite_process = None
        
        # Setup GUI
        self.setup_gui()
        
        # Auto-detect RuneLite installation
        self.detect_runelite()
        
    def setup_gui(self):
        """Create the GUI interface"""
        # Main frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configure grid weights
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
        
        # Title
        title_label = ttk.Label(main_frame, text="OptimizerBeta Plugin Installer", font=("Arial", 16, "bold"))
        title_label.grid(row=0, column=0, columnspan=2, pady=(0, 20))
        
        # Beta Key section
        ttk.Label(main_frame, text="Beta Key:").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.token_entry = ttk.Entry(main_frame, width=50, show="*")
        self.token_entry.grid(row=1, column=1, sticky=(tk.W, tk.E), pady=5, padx=(10, 0))
        
        # Validate Key button
        self.validate_btn = ttk.Button(main_frame, text="Validate Key", command=self.validate_token)
        self.validate_btn.grid(row=2, column=1, sticky=tk.W, pady=5, padx=(10, 0))
        
        # Status section
        ttk.Label(main_frame, text="Status:").grid(row=3, column=0, sticky=tk.W, pady=(20, 5))
        self.status_label = ttk.Label(main_frame, text="Enter Beta Key to begin", foreground="orange")
        self.status_label.grid(row=3, column=1, sticky=tk.W, pady=(20, 5), padx=(10, 0))
        
        # Install & Launch button
        self.install_btn = ttk.Button(main_frame, text="Install & Launch RuneLite", 
                                    command=self.install_and_launch, state="disabled")
        self.install_btn.grid(row=4, column=0, columnspan=2, pady=20)
        
        # Log section
        ttk.Label(main_frame, text="Installation Log:").grid(row=5, column=0, sticky=tk.W, pady=(10, 5))
        
        # Log text area
        self.log_text = scrolledtext.ScrolledText(main_frame, width=70, height=15, wrap=tk.WORD)
        self.log_text.grid(row=6, column=0, columnspan=2, sticky=(tk.W, tk.E, tk.N, tk.S), pady=5)
        
        # Configure grid weights for resizing
        main_frame.rowconfigure(6, weight=1)
        
        # Initial log message
        self.log("OptimizerBeta Plugin Installer Started")
        self.log("=" * 50)
        
    def log(self, message):
        """Add a message to the log display"""
        timestamp = datetime.datetime.now().strftime("%H:%M:%S")
        log_entry = f"[{timestamp}] {message}"
        
        self.log_text.insert(tk.END, log_entry + "\n")
        self.log_text.see(tk.END)
        self.root.update_idletasks()
        
        # Also write to file
        try:
            log_file = Path(__file__).parent / "log.txt"
            with open(log_file, "a", encoding="utf-8") as f:
                f.write(log_entry + "\n")
        except:
            pass
            
    def detect_runelite(self):
        """Auto-detect RuneLite installation"""
        self.log("Detecting RuneLite installation...")
        
        # Common RuneLite installation locations
        possible_locations = [
            Path.home() / ".runelite",
            Path(os.environ.get('APPDATA', '')) / "RuneLite",
            Path(os.environ.get('LOCALAPPDATA', '')) / "RuneLite"
        ]
        
        for location in possible_locations:
            if location.exists() and location.is_dir():
                self.runelite_dir = location
                self.plugins_dir = location / "plugins"
                self.sideloaded_plugins_dir = location / "sideloaded-plugins"
                self.repository_dir = location / "repository2"
                
                # Create directories if they don't exist
                self.plugins_dir.mkdir(exist_ok=True)
                self.sideloaded_plugins_dir.mkdir(exist_ok=True)
                
                self.log(f"OK: RuneLite found: {self.runelite_dir}")
                self.log(f"OK: Plugins directory: {self.plugins_dir}")
                return
                
        self.log("ERROR: RuneLite installation not found!")
        self.log("Please install RuneLite first from https://runelite.net/")
        
    def validate_token(self):
        """Validate the GitHub token"""
        self.token = self.token_entry.get().strip()
        
        if not self.token:
            messagebox.showerror("Error", "Please enter a Beta Key")
            return
            
        if not (self.token.startswith("github_pat_") or self.token.startswith("ghp_")):
            messagebox.showerror("Error", "Invalid key format. Key should start with 'github_pat_' or 'ghp_'")
            return
            
        self.log("Validating Beta Key...")
        
        try:
            headers = {"Authorization": f"token {self.token}"}
            response = requests.get(f"https://api.github.com/repos/{self.github_repo_owner}/{self.github_repo_name}", 
                                  headers=headers, timeout=10)
            
            if response.status_code == 200:
                self.log("OK: Beta Key validation successful!")
                self.log("OK: Repository access confirmed")
                self.status_label.config(text="Beta Key valid - Ready to install", foreground="green")
                self.install_btn.config(state="normal")
            else:
                self.log(f"ERROR: Beta Key validation failed (HTTP {response.status_code})")
                self.status_label.config(text="Invalid Beta Key", foreground="red")
                messagebox.showerror("Error", f"Beta Key validation failed: {response.status_code}")
                
        except requests.RequestException as e:
            self.log(f"ERROR: Network error during validation: {e}")
            messagebox.showerror("Error", f"Network error: {e}")
            
    def install_and_launch(self):
        """Install plugin and launch RuneLite"""
        if not self.runelite_dir:
            messagebox.showerror("Error", "RuneLite installation not found!\nPlease install RuneLite first.")
            return
            
        # Disable button during installation
        self.install_btn.config(state="disabled")
        
        # Run installation in background thread
        thread = threading.Thread(target=self._install_and_launch_thread)
        thread.daemon = True
        thread.start()
        
    def _install_and_launch_thread(self):
        """Install and launch in background thread"""
        try:
            # Step 1: Download plugin
            self.log("Downloading plugin from GitHub...")
            if not self._download_plugin():
                return
                
            # Step 2: Setup RuneLite development environment
            self.log("Setting up RuneLite development environment...")
            if not self._setup_development_environment():
                return
                
            # Step 3: Launch RuneLite with developer mode
            self.log("Launching RuneLite in developer mode...")
            if not self._launch_runelite():
                return
                
            self.log("Installation completed successfully!")
            self.log("Plugin should be loaded and developer tools active")
            
        except Exception as e:
            self.log(f"ERROR: Installation failed: {e}")
        finally:
            # Re-enable button
            self.root.after(0, lambda: self.install_btn.config(state="normal"))
            
    def _download_plugin(self):
        """Download the plugin JAR file"""
        try:
            headers = {"Authorization": f"token {self.token}"}
            response = requests.get(self.plugin_download_url, headers=headers, timeout=30)
            
            if response.status_code == 200:
                # Save to both plugins and sideloaded-plugins directories
                plugin_file = self.plugins_dir / "optimizer-1.0-SNAPSHOT.jar"
                sideloaded_file = self.sideloaded_plugins_dir / "optimizer-1.0-SNAPSHOT.jar"
                
                # Write to plugins directory
                with open(plugin_file, "wb") as f:
                    f.write(response.content)
                    
                # Copy to sideloaded-plugins directory (where RuneLite actually loads from)
                with open(sideloaded_file, "wb") as f:
                    f.write(response.content)
                
                self.log(f"OK: Plugin downloaded ({len(response.content):,} bytes)")
                self.log(f"OK: Plugin installed to: {plugin_file}")
                self.log(f"OK: Plugin copied to: {sideloaded_file}")
                
                # Create backup
                backup_name = f"optimizer-1.0-SNAPSHOT.jar.backup.{datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}"
                backup_file = self.plugins_dir / backup_name
                with open(backup_file, "wb") as f:
                    f.write(response.content)
                self.log(f"OK: Backup created: {backup_name}")
                
                return True
            else:
                self.log(f"ERROR: Failed to download plugin (HTTP {response.status_code})")
                return False
                
        except Exception as e:
            self.log(f"ERROR: Plugin download failed: {e}")
            return False
            
    def _setup_development_environment(self):
        """Setup RuneLite development environment"""
        try:
            # Required JAR files for RuneLite
            required_jars = [
                "client-1.11.12.2.jar",
                "runelite-api-1.11.12.2-runtime.jar", 
                "logback-classic-1.2.9.jar",
                "logback-core-1.2.9.jar",
                "slf4j-api-1.7.25.jar",
                "guice-4.1.0-no_aop.jar",
                "guava-23.2-jre.jar"
            ]
            
            # Check if repository directory exists
            if not self.repository_dir.exists():
                self.log(f"WARNING: Repository directory not found: {self.repository_dir}")
                self.log("This may indicate RuneLite is not properly installed")
                return False
                
            # Check for required JAR files
            missing_jars = []
            for jar in required_jars:
                jar_path = self.repository_dir / jar
                if jar_path.exists():
                    self.log(f"OK: {jar} already exists")
                else:
                    missing_jars.append(jar)
                    
            if missing_jars:
                self.log(f"WARNING: Missing JAR files: {missing_jars}")
                self.log("Please ensure RuneLite is properly installed and has been run at least once")
                return False
                
            self.log("OK: RuneLite development environment ready")
            return True
            
        except Exception as e:
            self.log(f"ERROR: Failed to setup development environment: {e}")
            return False
            
    def _launch_runelite(self):
        """Launch RuneLite with developer mode"""
        try:
            # Find RuneLite bundled Java
            java_executable = self._find_java()
            if not java_executable:
                self.log("ERROR: Java executable not found")
                return False
                
            self.log(f"Using Java: {java_executable}")
            
            # Check for existing Jagex credentials and preserve them
            self._preserve_jagex_credentials()
            
            # Build the direct Java command (the working approach)
            java_cmd = [
                java_executable,
                "-ea", "-Xmx768m", "-Xss2m", "-XX:CompileThreshold=1500",
                "-Dsun.java2d.opengl=false",
                "-Drunelite.pluginhub.url=https://repo.runelite.net/plugins",
                "--add-opens=java.desktop/sun.awt=ALL-UNNAMED",
                "--add-opens=java.desktop/sun.swing=ALL-UNNAMED",
                "-cp", str(self.repository_dir / "*"),
                "net.runelite.client.RuneLite",
                "--developer-mode", "--debug", "--insecure-write-credentials"
            ]
            
            # Get Jagex Launcher environment variables if available
            jagex_env = self._get_jagex_environment()
            process_env = os.environ.copy()
            if jagex_env:
                process_env.update(jagex_env)
                self.log("Using Jagex Launcher environment variables for credential access")
                
                # Also write credentials to file if we have tokens
                if 'JX_REFRESH_TOKEN' in jagex_env and 'JX_ACCESS_TOKEN' in jagex_env:
                    self._write_jagex_credentials(jagex_env)
            
            self.log("Launching RuneLite with developer mode and external plugin support...")
            
            # Launch RuneLite with environment variables
            if os.name == 'nt':
                self.runelite_process = subprocess.Popen(java_cmd, env=process_env, creationflags=subprocess.CREATE_NEW_PROCESS_GROUP)
            else:
                self.runelite_process = subprocess.Popen(java_cmd, env=process_env)
                
            self.log("OK: RuneLite launched successfully!")
            self.log("Developer mode is active with:")
            self.log("  - External plugin support enabled")
            self.log("  - Developer tools available")
            self.log("  - Debug logging enabled")
            self.log("  - Insecure credential writing enabled")
            
            return True
            
        except Exception as e:
            self.log(f"ERROR: Failed to launch RuneLite: {e}")
            return False
            
    def _find_java(self):
        """Find Java executable, preferring RuneLite bundled version"""
        java_locations = [
            # RuneLite bundled Java (highest priority)
            Path(os.environ.get('LOCALAPPDATA', '')) / 'RuneLite' / 'jre' / 'bin' / 'java.exe',
            Path(os.environ.get('APPDATA', '')) / 'RuneLite' / 'jre' / 'bin' / 'java.exe',
            Path(os.environ.get('PROGRAMFILES', '')) / 'RuneLite' / 'jre' / 'bin' / 'java.exe',
            Path(os.environ.get('PROGRAMFILES(X86)', '')) / 'RuneLite' / 'jre' / 'bin' / 'java.exe',
        ]
        
        # Check for RuneLite bundled Java first
        for java_path in java_locations:
            if java_path.exists():
                self.log(f"Found RuneLite bundled Java: {java_path.parent.parent}")
                return str(java_path)
                
        # Fall back to system Java
        try:
            result = subprocess.run(['where', 'java'], capture_output=True, text=True, check=True)
            java_path = result.stdout.strip().split('\n')[0]
            self.log(f"Found system Java: {java_path}")
            return java_path
        except subprocess.CalledProcessError:
            pass
            
        # Check JAVA_HOME
        java_home = os.environ.get('JAVA_HOME')
        if java_home:
            java_path = Path(java_home) / 'bin' / 'java.exe'
            if java_path.exists():
                self.log(f"Found Java via JAVA_HOME: {java_home}")
                return str(java_path)
                
        return None
        
    def _preserve_jagex_credentials(self):
        """Preserve existing Jagex credentials if they exist"""
        try:
            credentials_file = self.runelite_dir / "credentials.properties"
            if credentials_file.exists():
                with open(credentials_file, 'r') as f:
                    content = f.read()
                    
                # Check if we have valid Jagex tokens
                if "JX_REFRESH_TOKEN=" in content and "JX_ACCESS_TOKEN=" in content:
                    # Look for non-empty values
                    lines = content.split('\n')
                    has_refresh = any(line.startswith("JX_REFRESH_TOKEN=") and len(line.split('=', 1)[1].strip()) > 0 for line in lines)
                    has_access = any(line.startswith("JX_ACCESS_TOKEN=") and len(line.split('=', 1)[1].strip()) > 0 for line in lines)
                    
                    if has_refresh and has_access:
                        self.log("Found existing Jagex credentials - preserving for login")
                    else:
                        self.log("Found empty Jagex credentials - may need to login via Jagex Launcher first")
                else:
                    self.log("No Jagex credentials found - using standard login")
        except Exception as e:
            self.log(f"Could not check credentials: {e}")
            
    def _get_jagex_environment(self):
        """Get Jagex Launcher environment variables from running process"""
        # First try to install psutil if not available
        try:
            import psutil
        except ImportError:
            self.log("Installing psutil for Jagex credential detection...")
            try:
                import subprocess
                subprocess.check_call([sys.executable, "-m", "pip", "install", "psutil"])
                import psutil
                self.log("psutil installed successfully")
            except Exception as e:
                self.log(f"Could not install psutil: {e}")
                return None
                
        try:
            # Based on RuneLite's documented approach
            key1 = 'JX_CHARACTER_ID'
            key2 = 'JX_SESSION_ID'
            key3 = 'JX_DISPLAY_NAME'
            key4 = 'JX_REFRESH_TOKEN'
            key5 = 'JX_ACCESS_TOKEN'
            env_dict = {}
            
            # Look for JagexLauncher.exe process
            for proc in psutil.process_iter():
                try:
                    if "JagexLauncher.exe" in proc.name():
                        env = proc.environ()
                        # Check for the main three environment variables
                        if env.get(key1):
                            env_dict[key1] = env.get(key1)
                            env_dict[key2] = env.get(key2)
                            env_dict[key3] = env.get(key3)
                            # Also check for token variables if they exist
                            if env.get(key4):
                                env_dict[key4] = env.get(key4)
                            if env.get(key5):
                                env_dict[key5] = env.get(key5)
                            break
                except (psutil.NoSuchProcess, psutil.AccessDenied):
                    continue
                    
            if key1 in env_dict and key2 in env_dict and key3 in env_dict:
                self.log("Found Jagex Launcher environment variables:")
                self.log(f"  - Character ID: {env_dict[key1][:10]}...")
                self.log(f"  - Session ID: {env_dict[key2][:10]}...")
                self.log(f"  - Display Name: {env_dict[key3]}")
                return env_dict
            else:
                self.log("Could not find Jagex environment variables. Make sure:")
                self.log("  1. Jagex Launcher is running")
                self.log("  2. You've logged in through Jagex Launcher")
                self.log("  3. Try launching RuneLite from Jagex Launcher once first")
                
        except Exception as e:
            self.log(f"Error getting Jagex environment: {e}")
            
        return None
        
    def _write_jagex_credentials(self, jagex_env):
        """Write Jagex credentials to credentials.properties file"""
        try:
            credentials_file = self.runelite_dir / "credentials.properties"
            
            # Read existing content if file exists
            existing_lines = []
            if credentials_file.exists():
                with open(credentials_file, 'r') as f:
                    existing_lines = f.readlines()
            
            # Update or add credential lines
            updated = False
            new_lines = []
            
            for line in existing_lines:
                if line.startswith('JX_REFRESH_TOKEN='):
                    new_lines.append(f"JX_REFRESH_TOKEN={jagex_env.get('JX_REFRESH_TOKEN', '')}\n")
                    updated = True
                elif line.startswith('JX_ACCESS_TOKEN='):
                    new_lines.append(f"JX_ACCESS_TOKEN={jagex_env.get('JX_ACCESS_TOKEN', '')}\n")
                    updated = True
                else:
                    new_lines.append(line)
            
            # If not updated, append the credentials
            if not updated and 'JX_REFRESH_TOKEN' in jagex_env:
                if not any(line.strip() for line in new_lines):  # If file is empty or only has header
                    new_lines.append(f"JX_REFRESH_TOKEN={jagex_env.get('JX_REFRESH_TOKEN', '')}\n")
                    new_lines.append(f"JX_ACCESS_TOKEN={jagex_env.get('JX_ACCESS_TOKEN', '')}\n")
                else:
                    new_lines.append(f"JX_REFRESH_TOKEN={jagex_env.get('JX_REFRESH_TOKEN', '')}\n")
                    new_lines.append(f"JX_ACCESS_TOKEN={jagex_env.get('JX_ACCESS_TOKEN', '')}\n")
            
            # Write back to file
            with open(credentials_file, 'w') as f:
                f.writelines(new_lines)
                
            self.log("Wrote Jagex credentials to credentials.properties")
            
        except Exception as e:
            self.log(f"Error writing credentials: {e}")
        
    def run(self):
        """Start the GUI application"""
        self.root.mainloop()

if __name__ == "__main__":
    try:
        app = OptimizerBetaInstaller()
        app.run()
    except Exception as e:
        print(f"Fatal error: {e}")
        input("Press Enter to exit...")