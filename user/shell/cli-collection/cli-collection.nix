{ pkgs, systemSettings, make-project-prompt, antigravity2, ... }:

let
  antigravity-cli-updated = antigravity2.packages.${systemSettings.system}.antigravity-cli.overrideAttrs (old: {
    version = "1.3.1";
    src = pkgs.fetchurl {
      url = if systemSettings.system == "aarch64-linux" then
        "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.1-4582356770750464/linux-arm/cli_linux_arm64.tar.gz"
      else
        "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.1-4582356770750464/linux-x64/cli_linux_x64.tar.gz";
      hash = if systemSettings.system == "aarch64-linux" then
        "sha256-+W7+yZyL2g0xaGdiLmX3kgugwrdKYtafzU7RPg6EEZ0="
      else
        "sha256-DjE7MJ6ljHFDHOhruCCTajcA4X5E6rznvyJkYX3IIts=";
    };
  });
in
{
  home.packages = [
    pkgs.wget
    pkgs.tree
    pkgs.htop
    pkgs.fprintd
    pkgs.libfprint
    pkgs.usbutils
    pkgs.poetry
    pkgs.file
    pkgs.jq
    pkgs.traceroute
    pkgs.imagemagick
    pkgs.openssl
    pkgs.net-tools
    pkgs.dnsutils
    pkgs.tcpdump
    pkgs.wireshark
    pkgs.nmap
    pkgs.iftop    # monitoring per connection
    pkgs.nethogs  # monitoring per process
    pkgs.iperf3   # performance test
    pkgs.fastfetch

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
    antigravity2.packages.${systemSettings.system}.antigravity-desktop
    antigravity-cli-updated

    pkgs.zellij
    pkgs.kubecolor
  ];
}
