{ config, pkgs, ... }:

{
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

  environment.systemPackages = with pkgs; [
    networkmanager-openvpn
  ];
}
