{ config, pkgs, userSettings, ... }:

{
  imports = [
    # Base Apps
    ../../user/app/browser/firefox.nix
    ../../user/shell/cli-collection/cli-collection.nix
    ../../user/shell/sh/sh.nix

    # Development Apps
    ../../user/app/git/git.nix
    ../../user/app/ide/vim.nix
    ../../user/app/ide/vscode.nix
  ];

  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
