{ config, pkgs, userSettings, ... }:

{
  environment.systemPackages = with pkgs; [
    sfizz-ui
    ardour
    carla
    lilv
    surge-XT
    vital
    odin2
    yoshimi
    alsa-utils
    qpwgraph
    (callPackage ./salamander-piano.nix { })
  ];

  users.users.${userSettings.username}.extraGroups = [ "audio" ];

  security.pam.loginLimits = [
    { domain = "@audio"; item = "rtprio"; type = "-"; value = "95"; }
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
  ];

  environment.pathsToLink = [
    "/share/sounds"
    "/lib/lv2"
    "/lib/vst"
    "/lib/vst3"
    "/lib/lxvst"
    "/lib/ladspa"
    "/lib/dssi"
  ];

  environment.variables = {
    LV2_PATH = "/run/current-system/sw/lib/lv2:$HOME/.nix-profile/lib/lv2";
    VST3_PATH = "/run/current-system/sw/lib/vst3:$HOME/.nix-profile/lib/vst3";
    VST_PATH = "/run/current-system/sw/lib/vst:$HOME/.nix-profile/lib/vst";
  };
}