{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "brian";
  home.homeDirectory = "/home/brian";

  programs.git = {
    enable = true;
    userName = "TheGostsniperfr";
    userEmail = "brianperret.pro@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    htop
    # Spotify (no ads)
    config.nur.repos.nltch.spotify-adblock    #for installing spotify-adblock
    config.nur.repos.nltch.ciscoPacketTracer8 #for installing packettracer8 
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/brian/etc/profile.d/hm-session-vars.sh
  #
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


  nixpkgs.config.allowUnfree = true;
  

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
