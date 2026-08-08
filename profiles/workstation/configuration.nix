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
      ../../system/app/music/music.nix

      ../../system/app/network/cisco-packet-tracer.nix
      
      # Development tools
    ];
    
  # Permanently expose DP-3 (unused physical port) as a virtual streaming display.
  # No dummy plug needed — the kernel enumerates the connector from the firmware EDID.
  hardware.firmware = [
    (pkgs.runCommand "streaming-edid" {} ''
      mkdir -p $out/lib/firmware/edid
      cp ${../../system/hardware/edid/2880x1620-120.bin} $out/lib/firmware/edid/streaming.bin
    '')
  ];

  boot.kernelParams = [
    "drm.edid_firmware=DP-3:edid/streaming.bin"
    "video=DP-3:e"
    # Required for Sunshine KMS capture: without this, nvidia-drm returns 0x0 framebuffer
    # sizes via drmModeGetFB(), preventing Sunshine from matching any display connector.
    "nvidia-drm.fbdev=1"
  ];
}

