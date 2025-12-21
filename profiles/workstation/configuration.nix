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
      
      # Development tools
    ];
    
  hardware.firmware = [
    (pkgs.runCommand "custom-edid" {} ''
      mkdir -p $out/lib/firmware/edid
      # On copie le fichier depuis ton dépôt git vers le dossier firmware final
      # Le chemin est relatif à ce fichier configuration.nix
      cp ${../../system/hardware/edid/4k.bin} $out/lib/firmware/edid/4k_fake.bin
    '')
  ];

  # 2. On dit au Kernel d'utiliser ce fichier pour le port HDMI
  boot.kernelParams = [ 
    # Applique l'EDID 4K sur HDMI-A-1
    "drm.edid_firmware=HDMI-A-1:edid/4k_fake.bin" 
    
    # Force le port à être considéré comme "connecté" même si l'écran est éteint
    "video=HDMI-A-1:e" 
  ];
}

