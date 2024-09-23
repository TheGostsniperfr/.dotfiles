{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    gdb
    valgrind
  ];
}