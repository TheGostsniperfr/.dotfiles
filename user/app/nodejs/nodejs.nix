{ pkgs, config, libs, ... }:

{
  home.packages = [
    pkgs.nodejs
    pkgs.electron
  ];
}