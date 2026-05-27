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

  nixpkgs.config.allowUnfree = true;

  home.stateVersion = "25.11"; # home-manager verison

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
