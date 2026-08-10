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

  environment.systemPackages = [ pkgs.ethtool ]; 
  
  systemd.services.enable-wol = {
    description = "Enable Wake-on-LAN for enp34s0";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s enp34s0 wol g";
      RemainAfterExit = true;
    };
  };
}
