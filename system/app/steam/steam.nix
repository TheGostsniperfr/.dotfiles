{ pkgs, ... }:

{
  services.envfs.enable = true;

  environment.sessionVariables = {
    WEBKIT_DISABLE_COMPOSITING_MODE = "1";
    JSC_useJIT = "0";
  };

  environment.systemPackages = [
    pkgs.steam-tui
    pkgs.steamcmd
    pkgs.appimage-run
    pkgs.protonup-qt
    pkgs.heroic
    
    (pkgs.lutris.override {
      extraLibraries = pkgs: [
        pkgs.vulkan-loader
        pkgs.vulkan-tools
        pkgs.libGL
        pkgs.libGLU
        pkgs.mesa
      ];
    })
  ];

  hardware.graphics.enable32Bit = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
}