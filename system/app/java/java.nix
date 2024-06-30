{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.javaPackages.openjfx17
    pkgs.libGL
    pkgs.xorg.libXtst
  ];

  programs.java = {
    enable = true;
    package = (pkgs.jdk17.override { enableJavaFX = true; });
  };
}