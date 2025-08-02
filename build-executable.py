#!/usr/bin/env python3
"""
Build script to compile OptimizerBeta-Installer.py to standalone executable using Nuitka
"""

import subprocess
import sys
import os
from pathlib import Path

def install_nuitka():
    """Install Nuitka if not already installed"""
    try:
        import nuitka
        print("✓ Nuitka is already installed")
        return True
    except ImportError:
        print("Installing Nuitka...")
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install", "nuitka"])
            print("✓ Nuitka installed successfully")
            return True
        except subprocess.CalledProcessError as e:
            print(f"✗ Failed to install Nuitka: {e}")
            return False

def build_executable():
    """Build the executable using Nuitka"""
    
    # Check if source file exists
    source_file = "OptimizerBeta-Installer.py"
    if not Path(source_file).exists():
        print(f"✗ Source file {source_file} not found!")
        return False
    
    print(f"Building executable from {source_file}...")
    
    # Nuitka compilation command
    nuitka_cmd = [
        sys.executable, "-m", "nuitka",
        "--standalone",              # Create standalone executable
        "--onefile",                # Single file output
        "--windows-disable-console", # Hide console window (GUI app)
        "--enable-plugin=tk-inter",  # Include tkinter
        "--windows-company-name=OptimizerBeta",
        "--windows-product-name=OptimizerBeta Plugin Installer",
        "--windows-file-version=1.0.0.0",
        "--windows-product-version=1.0.0",
        "--windows-file-description=Secure token-gated plugin installer for RuneLite",
        "--output-filename=OptimizerBeta-Installer.exe",
        source_file
    ]
    
    # Add icon if available
    icon_file = "installer_icon.ico"
    if Path(icon_file).exists():
        nuitka_cmd.extend(["--windows-icon-from-ico", icon_file])
        print(f"✓ Using icon: {icon_file}")
    
    try:
        print("Compiling with Nuitka... (this may take a few minutes)")
        print("Command:", " ".join(nuitka_cmd))
        print("-" * 60)
        
        result = subprocess.run(nuitka_cmd, check=True, capture_output=False)
        
        print("-" * 60)
        print("✓ Compilation successful!")
        
        # Check if executable was created
        exe_file = "OptimizerBeta-Installer.exe"
        if Path(exe_file).exists():
            file_size = Path(exe_file).stat().st_size / (1024 * 1024)  # MB
            print(f"✓ Executable created: {exe_file} ({file_size:.1f} MB)")
            print("")
            print("🚀 Ready for distribution!")
            print("Users can now run the .exe file without Python installed.")
            return True
        else:
            print("✗ Executable file not found after compilation")
            return False
            
    except subprocess.CalledProcessError as e:
        print(f"✗ Compilation failed: {e}")
        return False
    except Exception as e:
        print(f"✗ Unexpected error: {e}")
        return False

def main():
    """Main build process"""
    print("=" * 60)
    print("OptimizerBeta Installer - Nuitka Build Script")
    print("=" * 60)
    
    # Step 1: Install dependencies
    print("Installing build dependencies...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests", "nuitka"])
    
    # Step 2: Build executable
    if not build_executable():
        print("❌ Build failed: Compilation error")
        return 1
    
    print("=" * 60)
    print("✅ BUILD COMPLETE!")
    print("")
    print("Next steps:")
    print("1. Test the .exe file on your system")
    print("2. Test on a system without Python installed")
    print("3. Upload to your OptimizerBeta repository")
    print("4. Beta testers can download and run the .exe")
    print("=" * 60)
    
    return 0

if __name__ == "__main__":
    sys.exit(main())