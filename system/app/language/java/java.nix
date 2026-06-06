{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.javaPackages.openjfx17
    pkgs.libGL
    pkgs.xorg.libXtst

    pkgs.zulu
    pkgs.quarkus
    pkgs.maven
  ];

  programs.java = {
    enable = true;
    package = (pkgs.jdk17.override { enableJavaFX = true; });
  };
}