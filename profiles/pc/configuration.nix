{ config, pkgs, systemSettings, userSettings, ... }:

let 

  user="brian";

in
{
  imports =
    [ # Include the results of the hardware scan.
      ../base/configuration.nix

      # GPU
      ../../system/hardware/nvidia/nvidia-igpu.nix
      
      # Development tools
      # ../../system/app/language/octave/octave.nix
      # ../../system/app/gns3/gns3.nix
    ];
}

