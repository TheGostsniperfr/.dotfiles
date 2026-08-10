{ config, pkgs, lib, userSettings, ... }:

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
      OLLAMA_MODELS=$(${pkgs.curl}/bin/curl -sf http://localhost:11434/api/ps 2>/dev/null \
        | ${pkgs.python3}/bin/python3 -c "
import sys,json
d=json.load(sys.stdin)
for m in d.get('models',[]): print(m['name'])
" 2>/dev/null || true)
      for MODEL in $OLLAMA_MODELS; do
        echo "Unloading Ollama model: $MODEL" >> "$LOG"
        ${pkgs.curl}/bin/curl -sf -X POST http://localhost:11434/api/generate \
          -d "{\"model\":\"$MODEL\",\"keep_alive\":0}" >> "$LOG" 2>&1 || true
      done

      $KSCREEN output.$TARGET.enable output.$TARGET.hdr.enable output.$TARGET.wcg.enable >> "$LOG" 2>&1
      sleep 1
      $KSCREEN output.$TARGET.mode.''${WIDTH}x''${HEIGHT}@''${FPS} output.$TARGET.scale.1 >> "$LOG" 2>&1 || \
        echo "Mode ''${WIDTH}x''${HEIGHT}@''${FPS} not in EDID, streaming at native" >> "$LOG"
    elif [ "$ACTION" = "undo" ]; then
      $KSCREEN output.$TARGET.mode.2880x1620@120 output.$TARGET.scale.1 >> "$LOG" 2>&1
    fi
  '';

in
{
  hardware.uinput.enable = true;

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = false;
    openFirewall = true;

    package = pkgs.sunshine.override {
      cudaSupport = false;
    };

    settings = {
      output_name = "DP-3";
       capture = "kwin";
      hevc_mode = 3;
      av1_mode = 3;
      nvenc_preset = "P7";
      audio_sink = "";

      global_prep_cmd = builtins.toJSON [
        {
          do = "${sunshine-prep}/bin/sunshine-prep do";
          undo = "${sunshine-prep}/bin/sunshine-prep undo";
        }
      ];
    };
  };

  systemd.user.services.sunshine = {
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
      
      ExecStartPre = [
        "${pkgs.coreutils}/bin/sleep 5"
        "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-3.enable output.DP-3.hdr.enable output.DP-3.wcg.enable output.DP-3.mode.2880x1620@120"
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