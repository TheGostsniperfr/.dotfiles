{ config, pkgs, userSettings, ... }:

{
  imports = [
    ../base/home.nix
    ../../user/app/zellij/zellij-remote.nix
  ];
}
