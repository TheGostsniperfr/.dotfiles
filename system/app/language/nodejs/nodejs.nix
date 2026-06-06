{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.nodejs_22
    pkgs.yarn
    pkgs.glib
    pkgs.electron
    pkgs.pnpm
  ];
}