{ pkgs, systemSettings, make-project-prompt, ... }:

{
  home.packages = [
    pkgs.wget
    pkgs.tree
    pkgs.fprintd
    pkgs.libfprint
    pkgs.usbutils
    pkgs.poetry
    pkgs.file

    # Yaml tools
    pkgs.yq
    pkgs.yamllint

    # Man pages
    pkgs.man-pages
    pkgs.linux-manual
    pkgs.man-pages-posix

    # MPP
    pkgs.xsel
    make-project-prompt.packages.${systemSettings.system}.default
  ];
}