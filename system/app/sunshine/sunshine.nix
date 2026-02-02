{ config, pkgs, userSettings, ... }:

let
  sunshine-prep = pkgs.writeShellScriptBin "sunshine-prep" ''
    LOG="/tmp/sunshine-script.log"
    echo "--- $(date) ---" >> $LOG
    
    ACTION="$1"
    
    # Tes paramètres
    WIDTH="''${SUNSHINE_CLIENT_WIDTH:-2880}"
    HEIGHT="''${SUNSHINE_CLIENT_HEIGHT:-1620}"
    FPS="''${SUNSHINE_CLIENT_FPS:-60}"
    
    KSCREEN="${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor"
    
    TARGET_OUTPUT="DP-2"

    echo "Action: $ACTION | Output: $TARGET_OUTPUT | Cible: $WIDTH x $HEIGHT @ $FPS" >> $LOG

    if [ "$ACTION" = "do" ]; then
      echo ">>> ACTIVATION" >> $LOG
      
      $KSCREEN output.$TARGET_OUTPUT.enable \
               output.$TARGET_OUTPUT.priority.1 \
               output.$TARGET_OUTPUT.scale.1.5 >> $LOG 2>&1
      
      sleep 1
      
      $KSCREEN output.$TARGET_OUTPUT.mode.''${WIDTH}x''${HEIGHT}@''${FPS} >> $LOG 2>&1

    elif [ "$ACTION" = "undo" ]; then
      $KSCREEN output.$TARGET_OUTPUT.disable >> $LOG 2>&1
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
      output_name = 2;
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