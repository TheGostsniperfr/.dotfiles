{ pkgs, config, libs, ... }:

{
  home.packages = [
    pkgs.nodejs_22
    pkgs.yarn
    pkgs.glib
    pkgs.electron
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-29.4.6"
  ];
}
