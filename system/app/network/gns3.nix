{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.gns3-server
    pkgs.gns3-gui
    pkgs.dynamips
    pkgs.ubridge
  ];
}