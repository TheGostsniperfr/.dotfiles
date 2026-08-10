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

  # K3s Worker Config 
  # TODO Set to the real IP of the node 
  services.k3s.serverAddr = "https://192.168.1.0:6443"; # Only for other node (from the clusterInit) 

  networking.interfaces.eno1.ipv4.addresses =[{
    address = "192.168.1.11"; # TODO Set to the real IP of the node 
    prefixLength = 24;
  }];
}