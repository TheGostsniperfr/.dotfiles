#!/usr/bin/env bash

set -e # Stop on error

echo "🔹 Starting LinOffice installation for NixOS..."

# 1. Define paths
INSTALL_DIR="$HOME/.local/bin/linoffice"
TEMP_ZIP="/tmp/linoffice-main.zip"

# 2. Check if dependencies are present in system
if ! command -v xfreerdp &> /dev/null; then
    echo "❌ Error: xfreerdp is not installed."
    echo "   Please add 'freerdp' to your environment.systemPackages in configuration.nix and rebuild."
    exit 1
fi

# 3. Download and Install
echo "⬇️  Downloading LinOffice..."
mkdir -p "$HOME/.local/bin"
wget -O "$TEMP_ZIP" https://github.com/eylenburg/linoffice/archive/refs/heads/main.zip

echo "📂 Extracting..."
unzip -o -q "$TEMP_ZIP" -d "$HOME/.local/bin"
# Handle the folder rename safely
if [ -d "$HOME/.local/bin/linoffice-main" ]; then
    rm -rf "$INSTALL_DIR"
    mv "$HOME/.local/bin/linoffice-main" "$INSTALL_DIR"
fi
rm "$TEMP_ZIP"

cd "$INSTALL_DIR"

# 4. NixOS Patch: Fix Shebangs (The /bin/bash issue)
echo "🔧 Patching Shebangs for NixOS..."
find . -type f -name "*.sh" -exec sed -i 's|#!/bin/bash|#!/usr/bin/env bash|g' {} +
find . -type f -name "*.py" -exec sed -i 's|#!/usr/bin/python3|#!/usr/bin/env python3|g' {} +

# 5. Run the official setup
echo "🚀 Running Setup..."
bash setup.sh

# 6. NixOS Patch: Inject the dynamic FreeRDP path into the config
CONFIG_FILE="$INSTALL_DIR/config/linoffice.conf"

if [ -f "$CONFIG_FILE" ]; then
    echo "🔗 Patching configuration for FreeRDP symlinks..."
    
    # We use grep to check if we already patched it, to avoid duplicates
    if ! grep -q "readlink -f" "$CONFIG_FILE"; then
        # Append the dynamic command to the end of the config file.
        # This overrides any previous definition in the file.
        echo "" >> "$CONFIG_FILE"
        echo "# NixOS Fix: Resolve real path for FreeRDP" >> "$CONFIG_FILE"
        echo 'FREERDP_COMMAND="$(readlink -f $(command -v xfreerdp))"' >> "$CONFIG_FILE"
    fi
else
    echo "⚠️  Warning: Config file not found at $CONFIG_FILE. You might need to run the app once to generate it."
fi

echo "✅ Installation Complete!"
echo "   You can now run: bash ~/.local/bin/linoffice/linoffice.sh powerpoint"