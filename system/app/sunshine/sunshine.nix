{ config, pkgs, lib, userSettings, ... }:

let
  # Patches libnvidia-fbc.so at service startup to unlock NvFBC on GeForce.
  # The patched copy lives in $RUNTIME_DIRECTORY (cleared on reboot) and is
  # injected via LD_LIBRARY_PATH so Sunshine picks it up via dlopen.
  sunshine-fbc-patch = pkgs.writeShellScriptBin "sunshine-fbc-patch" ''
    set -euo pipefail
    LOG="/tmp/sunshine-fbc-patch.log"
    echo "--- $(date) ---" >> "$LOG"

    SRC=$(ls /run/opengl-driver/lib/libnvidia-fbc.so.*.*.* 2>/dev/null | head -1)
    if [ -z "$SRC" ]; then
      echo "ERROR: libnvidia-fbc.so not found in /run/opengl-driver/lib/" | tee -a "$LOG" >&2
      exit 1
    fi
    VERSION=$(basename "$SRC" | sed 's/libnvidia-fbc\.so\.//')
    LIBDIR="$RUNTIME_DIRECTORY"
    DEST="$LIBDIR/libnvidia-fbc.so.$VERSION"

    cp -f "$SRC" "$DEST"
    chmod +w "$DEST"

    ${pkgs.python3Minimal}/bin/python3 - "$DEST" <<'PYEOF'
import sys
path = sys.argv[1]
data = open(path, 'rb').read()
search  = b'\x85\xc0\x0f\x85\xd4\x00\x00\x00\x48'
replace = b'\x85\xc0\x90\x90\x90\x90\x90\x90\x48'
count = data.count(search)
if count != 1:
    raise RuntimeError(f'Expected 1 match, found {count}')
patched = data.replace(search, replace)
open(path, 'wb').write(patched)
print(f'Patched {path}: offset {hex(data.index(search))}', flush=True)
PYEOF

    ln -sf "$DEST" "$LIBDIR/libnvidia-fbc.so.1"
    ln -sf "$DEST" "$LIBDIR/libnvidia-fbc.so"
    echo "NvFBC patch applied: $DEST" >> "$LOG"
  '';

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
      # Unload any active Ollama models to free VRAM for NVENC.
      # Lists running models then unloads each; safe to call even if Ollama is idle.
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

      $KSCREEN output.$TARGET.enable \
               output.$TARGET.hdr.enable \
               output.$TARGET.wcg.enable >> "$LOG" 2>&1
      sleep 1
      # kscreen-doctor can only switch to modes declared in the EDID.
      # For clients requesting non-EDID resolutions (e.g. 4K TV, phone), this will
      # fail and DP-3 stays at native 2880x1620@120; Sunshine scales on encode.
      $KSCREEN output.$TARGET.mode.''${WIDTH}x''${HEIGHT}@''${FPS} \
               output.$TARGET.scale.1 >> "$LOG" 2>&1 || \
        echo "Mode ''${WIDTH}x''${HEIGHT}@''${FPS} not in EDID, streaming at native 2880x1620@120" >> "$LOG"
    elif [ "$ACTION" = "undo" ]; then
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
      # Advertise HEVC Main + Main10 (HDR) and AV1 8-bit + 10-bit (HDR) to clients.
      # RTX 5080 supports both NVENC HEVC and AV1; client picks what it supports.
      hevc_mode = 3;
      av1_mode = 3;
      # Maximum quality NVENC preset. Sunshine auto-selects NVENC→VAAPI→software;
      # this preset only applies when NVENC is available (requires free VRAM).
      nvenc_preset = "P7";
      # Empty string = use Sunshine's built-in null audio sink.
      # Prevents the pw.thread-loop EINVAL loop when PipeWire can't set up a loopback.
      audio_sink = "";

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
  # sunshine-fbc-patch runs second: copies+patches libnvidia-fbc.so into the runtime dir
  # so NvFBC is available on GeForce (unlocked via the keylase/nvidia-patch byte patch).
  # plasma-xdg-desktop-portal-kde is D-Bus activated and normally starts after
  # plasma-core.target, but xdg-desktop-portal initializes its backend list at
  # startup. If the KDE portal isn't running yet, ScreenCast/RemoteDesktop are
  # unavailable and Sunshine (which uses XDG portal on pure NVIDIA) can't capture.
  # Force the ordering: KDE portal → xdg-desktop-portal frontend → Sunshine.
  systemd.user.services.xdg-desktop-portal.wants = [ "plasma-xdg-desktop-portal-kde.service" ];
  systemd.user.services.xdg-desktop-portal.after = lib.mkAfter [ "plasma-xdg-desktop-portal-kde.service" ];
  systemd.user.services.sunshine.wants = [ "plasma-xdg-desktop-portal-kde.service" "xdg-desktop-portal.service" ];
  systemd.user.services.sunshine.after = lib.mkAfter [ "plasma-xdg-desktop-portal-kde.service" "xdg-desktop-portal.service" ];

  systemd.user.services.sunshine.serviceConfig.ExecStartPre = [
    "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-3.enable output.DP-3.hdr.enable output.DP-3.wcg.enable output.DP-3.mode.2880x1620@120"
    "${sunshine-fbc-patch}/bin/sunshine-fbc-patch"
  ];
  systemd.user.services.sunshine.serviceConfig.RuntimeDirectory = "sunshine-libs";
  # LD_LIBRARY_PATH is useless here: the sunshine wrapper script replaces it entirely.
  # LD_PRELOAD is not touched by the wrapper, so it wins over RUNPATH (/run/opengl-driver/lib)
  # and forces dlopen("libnvidia-fbc.so.1") to return our patched copy.
  systemd.user.services.sunshine.serviceConfig.Environment = [ "LD_PRELOAD=%t/sunshine-libs/libnvidia-fbc.so.1" ];

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
