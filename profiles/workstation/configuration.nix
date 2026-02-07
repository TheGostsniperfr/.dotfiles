{ config, pkgs, systemSettings, userSettings, ... }:

let 

  user="brian";

in
{
  imports =
    [ # Include the results of the hardware scan.
      ../base/configuration.nix

      # GPU
      ../../system/hardware/nvidia/nvidia-gpu.nix

      # Apps
      # ../../user/app/layout/kde-plugins.nix # TODO fix wallpaper engine plugin
      ../../system/app/sunshine/sunshine.nix
      ../../system/app/openssh/openssh.nix
      ../../system/app/linoffice/linoffice.nix
      
      # Development tools
    ];
    
  hardware.firmware = [
    (pkgs.runCommand "custom-edid" {} ''
      mkdir -p $out/lib/firmware/edid
      cp ${../../system/hardware/edid/2880x1620-120.bin} $out/lib/firmware/edid/2880x1620-120_fake.bin
    '')
  ];

  # boot.kernelParams = [ 
  #   "drm.edid_firmware=DP-2:edid/2880x1620-120_fake.bin" 
    
  #   "video=DP-2:e" 
  # ];
}

