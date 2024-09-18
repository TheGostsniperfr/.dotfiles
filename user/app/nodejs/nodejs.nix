{ pkgs, config, libs, ... }:

{
  home.packages = [
    pkgs.nodejs
    pkgs.yarn
    pkgs.glib
  ];
}