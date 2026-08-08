{ config, pkgs, systemSettings, userSettings, ... }:

let

  user="brian";

in
{
  imports =
    [
      # Secrets management
      ../../system/app/secrets/secrets-management.nix

      # Development tools
      ../../system/app/language/docker/docker.nix
      ../../system/app/sql/postgresql.nix
      ../../system/app/utils/kube.nix

      # K3s
      ../../system/app/kubernetes/k3s/k3s.nix

      # VPN:
      ../../system/app/vpn/wireguard.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = systemSettings.timeZone;

  # Select internationalisation properties.
  i18n.defaultLocale = systemSettings.locale;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = systemSettings.extraLocale;
    LC_IDENTIFICATION = systemSettings.extraLocale;
    LC_MEASUREMENT = systemSettings.extraLocale;
    LC_MONETARY = systemSettings.extraLocale;
    LC_NAME = systemSettings.extraLocale;
    LC_NUMERIC = systemSettings.extraLocale;
    LC_PAPER = systemSettings.extraLocale;
    LC_TELEPHONE = systemSettings.extraLocale;
    LC_TIME = systemSettings.extraLocale;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      # Read authorized_keys at connection time (not at build time) so the key
      # lives on each machine without being tracked in git.
      AuthorizedKeysFile = "%h/.ssh/authorized_keys /etc/nixos/authorized_keys";
    };
  };

  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.username;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  programs.nix-ld.enable = true;

  system.stateVersion = "25.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
