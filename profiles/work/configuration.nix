{ config, pkgs, systemSettings, userSettings, ... }:

let 

  user="brian";

in
{
  imports =
    [ # Include the results of the hardware scan.
      ../personal/configuration.nix

      ../../system/app/steam/steam.nix
      ../../system/app/language/docker/docker.nix

      ../../system/app/language/java/java.nix
      ../../system/app/language/dotnet/dotnet.nix
      ../../system/app/language/python/python.nix
      ../../system/app/language/go/go.nix
      ../../system/app/language/c/c.nix
      ../../system/app/language/php/php.nix
      ../../system/app/language/rust/rust.nix
      ../../system/app/gns3/gns3.nix
      ../../system/app/sql/postgresql.nix
      ../../system/app/unity/unity.nix
      ../../system/app/language/octave/octave.nix
    ];
}

