#!/bin/sh

# Automated script to install my dotfiles 
# script from librephoenix 

# Clone dotfiles
if [ $# -gt 0 ]
  then
    SCRIPT_DIR=$1
  else
    SCRIPT_DIR=~/.dotfiles
fi
nix-shell -p git --command "git clone https://github.com/TheGostsniperfr/.dotfiles $SCRIPT_DIR"

# Generate hardware config for new system
sudo nixos-generate-config --show-hardware-config > $SCRIPT_DIR/system/hardware-configuration.nix

# Check if uefi or bios
# if [ -d /sys/firmware/efi/efivars ]; then
#     sed -i "0,/bootMode.*=.*\".*\";/s//bootMode = \"uefi\";/" $SCRIPT_DIR/flake.nix
# else
#     sed -i "0,/bootMode.*=.*\".*\";/s//bootMode = \"bios\";/" $SCRIPT_DIR/flake.nix
#     grubDevice=$(findmnt / | awk -F' ' '{ print $2 }' | sed 's/\[.*\]//g' | tail -n 1 | lsblk -no pkname | tail -n 1 )
#     sed -i "0,/grubDevice.*=.*\".*\";/s//grubDevice = \"\/dev\/$grubDevice\";/" $SCRIPT_DIR/flake.nix
# fi

# Open up editor to manually edit flake.nix before install
if [ -z "$EDITOR" ]; then
    EDITOR=nano;
fi
$EDITOR $SCRIPT_DIR/flake.nix;

# Permissions for files that should be owned by root
sudo bash $SCRIPT_DIR/harden.sh $SCRIPT_DIR;

# Rebuild system
sudo nixos-rebuild switch --flake $SCRIPT_DIR#brian;

# Install and build home-manager configuration
nix run home-manager/release-24.11 --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake $SCRIPT_DIR#brian;