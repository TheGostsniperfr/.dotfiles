{ config, pkgs, systemSettings, userSettings, ... }:

let 

  user="brian";

in
{
  imports =
    [ # Include the results of the hardware scan.
      ../../system/hardware-configuration.nix

      # Secrets management
      ../../system/app/secrets/secrets-management.nix

      # Add jp keyboard layout
      ../../system/app/layout/jp-ime.nix

      #config for simba server link
      ../../system/app/utils/cifs-utils.nix

      ../../system/app/gparted/gparted.nix
      # ../../system/app/java/java.nix

      # Development tools
      ../../system/app/language/docker/docker.nix
      ../../system/app/sql/postgresql.nix
      ../../system/app/utils/kube.nix
      # ../../system/app/unity/unity.nix

      # Language runtimes and tools
      ../../system/app/language/java/java.nix
      ../../system/app/language/dotnet/dotnet.nix
      ../../system/app/language/python/python.nix
      ../../system/app/language/go/go.nix
      ../../system/app/language/c/c.nix
      ../../system/app/language/r/r.nix
      ../../system/app/language/php/php.nix
      ../../system/app/language/rust/rust.nix

      # Games: 
      ../../system/app/steam/steam.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "${userSettings.username}"; # Define your hostname.
  
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

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    libinput.enable = true;   

    xserver = {
      enable = true;
      xkb = {
        layout = systemSettings.keyboardLayout;
        variant = "";
      };
    };      
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.flatpak.enable = true;

  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.username;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  nixpkgs.config.allowUnfree = true;

  services.fprintd.enable = true;
  
  # Enable Run unpatched dynamic binaries on NixOS:
  programs.nix-ld.enable = true;

 system.stateVersion = "25.11"; # Did you read the comment?
 
  # enable flakes:
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}

