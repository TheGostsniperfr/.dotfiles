{ config, pkgs, ... }:

{
  home.username = "brian";
  home.homeDirectory = "/home/brian";

  nixpkgs.config.allowUnfree = true;

  programs.git = {
    enable = true;
    userName = "TheGostsniperfr";
    userEmail = "brianperret.pro@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  home.stateVersion = "24.05"; # home-manager verison

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    htop


    # Spotify (no ads)
    config.nur.repos.nltch.spotify-adblock    #for installing spotify-adblock
    config.nur.repos.nltch.ciscoPacketTracer8 #for installing packettracer8 
  ];


  home.file = {
  
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      # Path shortcut
      NC = "cd /etc/nixos";
      HC = "cd && cd .config/home-manager";

      # Bash commands
      BC = "nvim ~/.bashrc";
      SC = "source ~/.bashrc";
      CC = "clear";

      ll = "ls -l";
      ".." = "cd ..";
      ep = "xdg-open ."; # open paht in file explorer

      update = "sudo nixos-rebuild switch --flake ~/.dotfiles"; # update configuration file using flake
      hupdate = "home-manager switch --flake ~/.dotfiles"; # update home-manager file using flake
      fupdate = "nix flake update"; #update flake file
      allupdate = "fupdate && update && fupdate"; # update all

      # Git commands
      gs = "git status";
    };
  };



  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
