{ pkgs, ... }:

{
  home.packages = [
    pkgs.wget
    pkgs.tree
    pkgs.fprintd
    pkgs.libfprint
    pkgs.usbutils
    pkgs.poetry
  ];
}