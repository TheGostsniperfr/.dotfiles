{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.python312
    pkgs.python312Packages.pip
  ];
}