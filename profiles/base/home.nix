{ config, pkgs, userSettings, ... }:

{
  imports = [
    # Base Apps
    ../../user/app/browser/firefox.nix
    ../../user/app/media/spotify/spotify.nix
    ../../user/app/media/vlc/vlc.nix
    # ../../user/app/media/nextcloud/nextcloud.nix
    ../../user/app/other/jap/jap.nix
    ../../user/app/social/discord/discord.nix
    # ../../user/app/social/whatsapp/whatsapp.nix
    ../../user/app/work/microsoft/todo.nix
    # ../../user/app/photo/darktable/darktable.nix
    # ../../user/app/media/obs/obs.nix
    ../../user/shell/cli-collection/cli-collection.nix
    ../../user/shell/sh/sh.nix

    # Development Apps
    ../../user/app/git/git.nix
    ../../user/app/ide/idea.nix
    ../../user/app/ide/vim.nix
    ../../user/app/ide/rider.nix
    ../../user/app/ide/goland.nix
    # ../../user/app/ide/pycharm.nix
    ../../user/app/ide/vscode.nix
    # ../../user/app/other/scenebuilder/scenebuilder.nix
    ../../user/app/nodejs/nodejs.nix
  ];


  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  nixpkgs.config.allowUnfree = true;

  home.stateVersion = "25.11"; # home-manager verison

  home.file = {
  
  };

  # Setup NUR
  # nixpkgs.config.packageOverrides = pkgs: {
  #   nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #     inherit pkgs;
  #   };
  # };

  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
