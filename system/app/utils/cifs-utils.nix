{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.cifs-utils
  ];

  # fileSystems."/media/nas" = {
  #   device = "";
  #   fsType = "cifs";
  #   options = [ "username=" "password=" ];
  # };
}
