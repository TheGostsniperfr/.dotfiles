#!/usr/bin/env bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default setup
INSTALL_DIR="$HOME/.dotfiles"
REPO_URL="https://github.com/TheGostsniperfr/.dotfiles"

# Helper function for logs
log() { echo -e "${GREEN}[INSTALL]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- 1. Arguments Parsing ---
HOST_NAME="$1"
PROFILE_NAME="$2"

if [ -z "$HOST_NAME" ]; then
    echo -n "Enter the Hostname for this machine: "
    read HOST_NAME
fi

# --- 2. Clone Repository ---
if [ -d "$INSTALL_DIR" ]; then
    log "Directory $INSTALL_DIR already exists. Pulling latest changes..."
    cd "$INSTALL_DIR" && git pull
else
    log "Cloning repository to $INSTALL_DIR..."
    nix-shell -p git --command "git clone $REPO_URL $INSTALL_DIR"
fi

cd "$INSTALL_DIR"

# --- 3. Host Logic ---
HOST_DIR="hosts/$HOST_NAME"

if [ -d "$HOST_DIR" ]; then
    # --- SCENARIO A: Host exists ---
    log "Host '$HOST_NAME' found in configuration."
    log "Skipping hardware generation to preserve existing config."
    
    # Check if a profile argument was uselessly provided
    if [ ! -z "$PROFILE_NAME" ]; then
        warn "Profile argument '$PROFILE_NAME' ignored because host '$HOST_NAME' already exists."
    fi

else
    # --- SCENARIO B: New Host ---
    log "Host '$HOST_NAME' does not exist. Creating new configuration..."

    # Ask for profile if missing
    if [ -z "$PROFILE_NAME" ]; then
        echo "Available profiles:"
        ls profiles/
        echo -n "Which profile do you want to assign to $HOST_NAME? "
        read PROFILE_NAME
    fi

    # Validate profile
    if [ ! -d "profiles/$PROFILE_NAME" ]; then
        err "Profile '$PROFILE_NAME' does not exist in profiles/ directory."
    fi

    # Create directory
    mkdir -p "$HOST_DIR"

    # Generate Hardware Config
    log "Generating hardware-configuration.nix..."
    if command -v nixos-generate-config &> /dev/null; then
        sudo nixos-generate-config --show-hardware-config > "$HOST_DIR/hardware-configuration.nix"
    else
        warn "nixos-generate-config not found. Are you on a NixOS installer?"
        # Fallback empty file to avoid crash, user must fill it manually if not on NixOS
        echo "{ ... }: { }" > "$HOST_DIR/hardware-configuration.nix"
    fi

    # Generate default.nix (The Linker)
    log "Creating default.nix binding to profile '$PROFILE_NAME'..."
    cat > "$HOST_DIR/default.nix" <<EOF
{ config, pkgs, userSettings, ... }:

{
  imports = [
    # Host Hardware-configuration
    ./hardware-configuration.nix

    # Selected Configuration
    ../../profiles/$PROFILE_NAME/configuration.nix
  ];

  # Selected Home Manager Configuration
  home-manager.users.\${userSettings.username} = import ../../profiles/$PROFILE_NAME/home.nix;
}
EOF

    # Add new files to git so Flake sees them
    log "Adding new host files to Git index..."
    git add "$HOST_DIR"
fi

# --- 4. Permissions ---
# Apply hardening if script exists
if [ -f "harden.sh" ]; then
    log "Applying permissions..."
    sudo bash harden.sh "$INSTALL_DIR"
fi

# --- 5. Installation / Switch ---
log "Building and switching to configuration: $HOST_NAME..."

sudo nixos-rebuild switch --flake ".#$HOST_NAME"

log "Done! Welcome to your new NixOS setup."