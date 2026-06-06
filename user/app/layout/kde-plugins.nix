{ pkgs, ... }:

{
  home.packages = [
    pkgs.kdePackages.wallpaper-engine-plugin
    pkgs.qt6.qtwebsockets 
    pkgs.qt6.qtwebchannel 
    # (pkgs.python3.withPackages (ps: [ ps.websockets ]))
  ];

  home-manager.users.username.services.kdeconnect.enable = true;

  networking.firewall = rec {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };
}