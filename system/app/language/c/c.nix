{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    glibc
    clang
    clang-tools

    cmake
    
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

  environment.variables.PATH = "${pkgs.clang-tools}/bin:$PATH";
}