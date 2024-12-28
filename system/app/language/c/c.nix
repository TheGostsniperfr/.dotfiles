{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    gdb
    valgrind
    meson
    ninja
    openssl.dev
    pkg-config

    autoconf
    automake
    libtool
    autoconf-archive
  ];
}