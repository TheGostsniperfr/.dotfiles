{ config, pkgs, userSettings, ... }:

{
  imports = [
    ../../user/app/browser/firefox.nix
    ../../user/app/ide/vscode.nix
    ../../user/shell/sh/sh.nix
  ];


  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  home.stateVersion = "26.05"; # home-manager verison

  home.file = {
  
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
