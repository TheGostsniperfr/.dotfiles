{ config, pkgs, userSettings, ... }:

let
  sunshine-prep = pkgs.writeShellScriptBin "sunshine-prep" ''
    LOG="/tmp/sunshine-script.log"
    echo "--- $(date) ---" >> "$LOG"

    ACTION="$1"
    WIDTH="''${SUNSHINE_CLIENT_WIDTH:-2880}"
    HEIGHT="''${SUNSHINE_CLIENT_HEIGHT:-1620}"
    FPS="''${SUNSHINE_CLIENT_FPS:-120}"

    KSCREEN="${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor"
    TARGET="DP-3"

    echo "Action: $ACTION | $WIDTH x $HEIGHT @ $FPS" >> "$LOG"

    if [ "$ACTION" = "do" ]; then
      $KSCREEN output.$TARGET.enable >> "$LOG" 2>&1
      sleep 1
      # Add as custom mode first in case resolution isn't in the EDID (e.g. 4K TV, phone)
      $KSCREEN output.$TARGET.mode.add.''${WIDTH}x''${HEIGHT}@''${FPS} >> "$LOG" 2>&1
      $KSCREEN output.$TARGET.mode.''${WIDTH}x''${HEIGHT}@''${FPS} \
               output.$TARGET.scale.1 >> "$LOG" 2>&1
    elif [ "$ACTION" = "undo" ]; then
      # Reset to native EDID resolution but keep enabled so Sunshine finds it on next startup
      $KSCREEN output.$TARGET.mode.2880x1620@120 \
               output.$TARGET.scale.1 >> "$LOG" 2>&1
    fi
  '';

in
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;

    package = pkgs.sunshine.override {
      cudaSupport = true;
    };

    settings = {
      output_name = 3;
      enable_hdr = "true";
      video_format = "p010";
      encoder_preset = "P7";
      nvenc_preset = "P7";
      rate_control = "CBR";
      tune = "ull";
      color_range = "JPEG";
      min_bitrate = 50000;

      global_prep_cmd = builtins.toJSON [
        {
          do = "${sunshine-prep}/bin/sunshine-prep do";
          undo = "${sunshine-prep}/bin/sunshine-prep undo";
        }
      ];
    };
  };

  # Enable DP-3 before Sunshine starts so its startup encoder test finds an active CRTC.
  # Without this, DP-3 is "connected" (EDID present) but has no framebuffer allocated yet,
  # causing KMS capture to fail even though Wayland enumeration sees the output.
  systemd.user.services.sunshine.serviceConfig.ExecStartPre =
    "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-3.enable output.DP-3.mode.2880x1620@120";

  users.users.${userSettings.username}.extraGroups = [ "input" "video" "render" ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 47984 47989 47990 48010 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
      { from = 8000; to = 8010; }
    ];
  };
}
