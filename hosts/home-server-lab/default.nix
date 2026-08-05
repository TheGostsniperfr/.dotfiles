{ config, pkgs, userSettings, ... }:

{
  imports = [
    # Host Hardware-configuration
    ./hardware-configuration.nix

    # Selected Configuration
    ../../profiles/k3s/configuration.nix
  ];

  # Selected Home Manager Configuration
  home-manager.users.${userSettings.username} = import ../../profiles/k3s/home.nix;
}
