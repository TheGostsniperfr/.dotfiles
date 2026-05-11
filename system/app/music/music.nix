{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    sfizz 
    ardour
    carla
    lilv
  ];

  environment.pathsToLink = [
    "/lib/lv2"
    "/lib/vst"
    "/lib/vst3"
    "/lib/lxvst"
    "/lib/ladspa"
    "/lib/dssi"
  ];

  environment.variables = {
    LV2_PATH = "/run/current-system/sw/lib/lv2:${pkgs.sfizz}/lib/lv2:$HOME/.nix-profile/lib/lv2";
    VST3_PATH = "/run/current-system/sw/lib/vst3:${pkgs.sfizz}/lib/vst3:$HOME/.nix-profile/lib/vst3";
    VST_PATH = "/run/current-system/sw/lib/vst:$HOME/.nix-profile/lib/vst";
  };
}