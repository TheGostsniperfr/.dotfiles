{ pkgs, ... }:

let
  wallpaper-engine-plugin = pkgs.kdePackages.callPackage ./wallpaper-engine-plugin.nix { };
  sceneviewer = pkgs.callPackage ./wallpaper-sceneviewer.nix { inherit wallpaper-engine-plugin; };
in
{
  # Must live in the system profile: plasmashell resolves wallpaper packages
  # and their QML module from /run/current-system/sw.
  environment.systemPackages = [
    wallpaper-engine-plugin
    # Resolved by name at runtime: main.qml instantiates Plasma5Support
    # DataSources, and nothing links them from the .so.
    pkgs.kdePackages.plasma5support
    # Used by scripts/we-diag.sh to compare against the plasmashell render.
    sceneviewer
  ];
}
