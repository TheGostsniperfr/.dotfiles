{ config, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages;

  environment.systemPackages = with pkgs; [
    obs-studio
    v4l-utils
  ];

  boot.kernelModules = [ "v4l2loopback" ];

  boot.extraModulePackages = [
    config.boot.kernelPackages.v4l2loopback
  ];

  boot.extraModprobeConfig = ''
    options v4l2loopback \
      devices=1 \
      video_nr=42 \
      card_label="OBS Virtual Camera" \
      exclusive_caps=1
  '';
}
