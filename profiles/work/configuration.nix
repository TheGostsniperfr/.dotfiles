{ config, pkgs, systemSettings, userSettings, ... }:

let 

  user="brian";

in
{
  imports =
    [ # Include the results of the hardware scan.
      ../personal/configuration.nix

      ../../system/app/java/java.nix
      ../../system/app/steam/steam.nix
      
      ../../system/app/language/python/python.nix
    ];
}

