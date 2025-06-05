{ config, pkgs, userSettings, ... }:

{
  imports = [
    ../../user/app/browser/firefox.nix
    ../../user/app/ide/vscode.nix
    ../../user/shell/sh/sh.nix
  ];


  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  nixpkgs.config.allowUnfree = true;

  home.stateVersion = "25.05"; # home-manager verison

  home.file = {
  
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
