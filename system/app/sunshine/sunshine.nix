{ config, pkgs, userSettings, ... }:

let
  sunshine-prep = pkgs.writeShellScriptBin "sunshine-prep" ''
    LOG="/tmp/sunshine-script.log"
    echo "--- $(date) ---" >> $LOG
    
    ACTION="$1"
    
    WIDTH="''${SUNSHINE_CLIENT_WIDTH:-1920}"
    HEIGHT="''${SUNSHINE_CLIENT_HEIGHT:-1080}"
    FPS="''${SUNSHINE_CLIENT_FPS:-60}"
    
    KSCREEN="${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor"
    GREP="${pkgs.gnugrep}/bin/grep"
    AWK="${pkgs.gawk}/bin/awk"

    # Get patched HDMI with edid file
    TARGET_OUTPUT=$($KSCREEN -o | $GREP "LNX" -B 10 | $GREP "Output:" | $AWK '{print $3}')
    if [ -z "$TARGET_OUTPUT" ]; then TARGET_OUTPUT="HDMI-A-1"; fi

    echo "Action: $ACTION | Port: $TARGET_OUTPUT | Cible: $WIDTH x $HEIGHT @ $FPS" >> $LOG

    if [ "$ACTION" = "do" ]; then
      echo ">>> STREAM ACTIVATION" >> $LOG

      $KSCREEN output.$TARGET_OUTPUT.enable \
               output.$TARGET_OUTPUT.mode.''${WIDTH}x''${HEIGHT}@''${FPS} \
               output.$TARGET_OUTPUT.priority.1 \
               output.$TARGET_OUTPUT.scale.1 >> $LOG 2>&1
      
      if [ $? -ne 0 ]; then
          echo "Failed with extact resolution: ($WIDTH x $HEIGHT). Fallback on 1440p..." >> $LOG
          # On tente du 1440p 60Hz (supporté par l'EDID 4K)
          $KSCREEN output.$TARGET_OUTPUT.mode.2560x1440@60 \
                   output.$TARGET_OUTPUT.priority.1 \
                   output.$TARGET_OUTPUT.scale.1 >> $LOG 2>&1
      fi
      
      # Force scale x1
      sleep 1
      $KSCREEN output.$TARGET_OUTPUT.scale.1 >> $LOG 2>&1
      sleep 2

    elif [ "$ACTION" = "undo" ]; then
      echo ">>> DEACTIVATION" >> $LOG
      $KSCREEN output.DP-2.priority.1 \
               output.$TARGET_OUTPUT.mode.1920x1080@60 \
               output.$TARGET_OUTPUT.priority.2 >> $LOG 2>&1
    fi
    
    echo "Done." >> $LOG
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
      output_name = 0;

      global_prep_cmd = builtins.toJSON [
        {
          do = "${sunshine-prep}/bin/sunshine-prep do";
          undo = "${sunshine-prep}/bin/sunshine-prep undo";
        }
      ];
    };
  };

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