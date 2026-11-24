{ config, pkgs, userSettings, ... }:

{
  imports = [
    ../base/home.nix
    ../../user/app/ide/goland.nix
  ];
}
