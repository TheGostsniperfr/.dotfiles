{ pkgs, config, libs, ... }:

{
  home.packages = [
    pkgs.nodejs_22
    pkgs.yarn
    pkgs.glib
    pkgs.electron
    pkgs.pnpm
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-38.8.4"
  ];
}
