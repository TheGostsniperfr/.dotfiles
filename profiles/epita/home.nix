{ config, pkgs, userSettings, ... }:

{
  imports = [
    ../../user/app/browser/firefox.nix
    ../../user/app/git/git.nix
    ../../user/app/ide/vscode.nix
    ../../user/app/media/spotify/spotify.nix
    ../../user/app/social/discord/discord.nix
    ../../user/shell/sh/sh.nix
  ];


  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  nixpkgs.config.allowUnfree = true;

  home.stateVersion = "24.05"; # home-manager verison

  home.file = {
  
  };

  # Setup NUR
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
