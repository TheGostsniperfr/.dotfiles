{ config, pkgs, userSettings, ... }:

{
  imports = [
    ../base/home.nix
    ../../user/app/ssh/ssh.nix
    ../../user/app/photo/darktable/darktable.nix
    ../../user/app/plasma/hosts/pc.nix
  ];
}
