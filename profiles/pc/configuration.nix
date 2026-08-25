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
      ../../system/app/video/davinci-resolve.nix
      ../../system/app/network/cisco-packet-tracer.nix

      # GPU
      ../../system/hardware/nvidia/nvidia-igpu.nix

      # Fingerprint reader (FocalTech 2808:a658)
      ../../system/hardware/fingerprint/fingerprint.nix
      
      # Development tools
      # ../../system/app/language/octave/octave.nix
      # ../../system/app/network/gns3.nix
    ];
}

