{ config, pkgs, systemSettings, userSettings, ... }:

let 

  user="brian";

in
{
  imports =
    [ # Include the results of the hardware scan.
      ../base/configuration.nix

      # Apps
      ../../system/app/linoffice/linoffice.nix

      # GPU
      ../../system/hardware/nvidia/nvidia-igpu.nix
      
      # Development tools
      # ../../system/app/language/octave/octave.nix
      # ../../system/app/network/gns3.nix
    ];
}

