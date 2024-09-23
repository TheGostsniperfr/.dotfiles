{ pkgs, config, libs, ... }:

{
  home.packages = [
    pkgs.nodejs
    pkgs.yarn
    pkgs.glib
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-29.4.6"
  ];
}
