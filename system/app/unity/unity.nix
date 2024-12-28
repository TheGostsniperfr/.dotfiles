{ config, pkgs, ... }:

{
    environment.systemPackages = [
      pkgs.unityhub
  ];
}
