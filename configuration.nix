{ config, pkgs, ... }:

let 

  user="brian";

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "${user}"; # Define your hostname.
  
  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    libinput.enable = true;   

    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };      
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.${user} = {
    isNormalUser = true;
    description = "Brian";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # Install firefox.
  programs.firefox.enable = true;


  services.fprintd.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
        # Cmd tools:
        wget

        # Devs app:
        pkgs.git

        # IDE:
        pkgs.vscode
        pkgs.neovim
        pkgs.jetbrains.rider
        pkgs.jetbrains.idea-ultimate

        #App:
        pkgs.discord
        pkgs.vlc
        pkgs.kuro
        pkgs.whatsapp-for-linux

        # Game:
        steam-tui
        steamcmd

        #Other:
        pkgs.fprintd
        libfprint

        usbutils

        #Lib for Idea
        javaPackages.openjfx17
        libGL
        xorg.libXtst
  ];

  programs.nix-ld.enable = true;

  programs.java = {
    enable = true;
    package = (pkgs.jdk17.override { enableJavaFX = true; });
  };
  



 system.stateVersion = "24.05"; # Did you read the comment?

#   home-manager.users.${user} = { pkgs, ... }: {
#     home.stateVersion = "24.05";
#     home.packages = [ pkgs.htop ];
#   };



  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
 
  # enable flakes:
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}

