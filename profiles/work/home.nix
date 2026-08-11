{ config, pkgs, userSettings, ... }:

{
  imports = [
    ../personal/home.nix
    ../../user/app/ide/goland.nix
  ];
}
