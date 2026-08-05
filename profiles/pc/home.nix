{ config, pkgs, userSettings, ... }:

{
  imports = [
    ../base/home.nix
    ../../user/app/ssh/ssh.nix
  ];
}
