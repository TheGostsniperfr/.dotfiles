{ config, pkgs, userSettings, ... }:

{
  imports = [
    ../base/home.nix
    ../../user/app/zellij/zellij-remote.nix
    ../../user/app/video/davinci-resolve.nix
  ];
}
