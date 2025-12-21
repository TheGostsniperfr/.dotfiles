{ pkgs, ... }:

{
  home.packages = [
    pkgs.kdePackages.wallpaper-engine-plugin
    pkgs.qt6.qtwebsockets 
    pkgs.qt6.qtwebchannel 
    # (pkgs.python3.withPackages (ps: [ ps.websockets ]))
  ];
}