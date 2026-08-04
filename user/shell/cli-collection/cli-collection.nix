<<<<<<< Updated upstream
{ pkgs, systemSettings, make-project-prompt, antigravity, ... }:
=======
{ pkgs, systemSettings, make-project-prompt, antigravity, ... }:
>>>>>>> Stashed changes

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
    pkgs.imagemagick
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
<<<<<<< Updated upstream
    antigravity.packages.${systemSettings.system}.default
    antigravity.packages.${systemSettings.system}.antigravity-desktop
    antigravity.packages.${systemSettings.system}.antigravity-cli

    pkgs.zellij 
    pkgs.kubecolor
=======
    antigravity.packages.${systemSettings.system}.default
>>>>>>> Stashed changes
  ];
}