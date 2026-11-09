{ pkgs, ... }:

let
  wallpaper-engine-plugin = pkgs.kdePackages.callPackage ./wallpaper-engine-plugin.nix { };
in
{
  # Must live in the system profile: plasmashell resolves wallpaper packages
  # and their QML module from /run/current-system/sw.
  environment.systemPackages = [
    wallpaper-engine-plugin
    # Resolved by name at runtime: main.qml instantiates Plasma5Support
    # DataSources, and nothing links them from the .so.
    pkgs.kdePackages.plasma5support
  ];
}
