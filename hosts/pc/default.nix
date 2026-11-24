{ config, pkgs, userSettings, ... }:

{
  imports = [
    # Host Hardware-configuration
    ./hardware-configuration.nix

    # Selected Configuration
    ../../profiles/pc/configuration.nix
  ];

  packetTracer.enable = true;

  # Selected Home Manager Configuration
  home-manager.users.${userSettings.username} = import ../../profiles/pc/home.nix;
}