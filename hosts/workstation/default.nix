{ config, pkgs, userSettings, ... }:

{
  imports = [
    # Host Hardware-configuration
    ./hardware-configuration.nix

    # Selected Configuration
    ../../profiles/workstation/configuration.nix
  ];

  # Selected Home Manager Configuration
  home-manager.users.${userSettings.username} = import ../../profiles/workstation/home.nix;
}