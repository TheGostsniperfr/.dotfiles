{ pkgs, ... }:

{
  home.packages = [
    pkgs.drawio
    # noodle diagrams are styled in JetBrains Mono; without it draw.io exports fall back to another monospace.
    pkgs.jetbrains-mono
  ];

  # Lets fontconfig see fonts installed through home.packages.
  fonts.fontconfig.enable = true;
}
