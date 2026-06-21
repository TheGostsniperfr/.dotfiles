{ pkgs, systemSettings, make-project-prompt, antigravity2, ... }:

{
  home.packages = [
    pkgs.wget
    pkgs.tree
    pkgs.fprintd
    pkgs.libfprint
    pkgs.usbutils
    pkgs.poetry
    pkgs.file
    pkgs.jq
    pkgs.traceroute
    pkgs.openssl

    # Secrets management
    pkgs.age
    pkgs.sops

    # Yaml tools
    pkgs.yq
    pkgs.yamllint

    # Man pages
    pkgs.man-pages
    pkgs.linux-manual
    pkgs.man-pages-posix

    # MPP
    pkgs.wl-clipboard
    make-project-prompt.packages.${systemSettings.system}.default

    # Antigravity
    antigravity2.packages.${systemSettings.system}.default
    antigravity2.packages.${systemSettings.system}.antigravity-desktop
    antigravity2.packages.${systemSettings.system}.antigravity-cli

    pkgs.zellij 
    pkgs.kubecolor
  ];
}