{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.steam-tui
    pkgs.steamcmd
    pkgs.lutris
    pkgs.appimage-run
  ];

  hardware.graphics.enable32Bit = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
}