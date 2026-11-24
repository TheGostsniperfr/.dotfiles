#!/usr/bin/env bash
# Wallpaper Engine particle-artifact diagnosis on the host.
# Usage: we-diag.sh {status|purge|present <0-4>|view [workshop-id] [present-mode]}
#   present: 0=Auto 1=Fifo 2=FifoRelaxed 3=Mailbox 4=Immediate
#   view:    renders the scene with the standalone viewer, outside plasmashell.
#            Artifacts there come from the renderer; artifacts only on the
#            desktop come from the frame handoff to Plasma.
set -euo pipefail

appletsrc="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
plugin="com.github.captsilver.wallpaperEngineKde"

# Containment ids whose wallpaper is the WE plugin
containments() {
  grep -oE "^\[Containments\]\[[0-9]+\]\[Wallpaper\]\[$plugin\]\[General\]" "$appletsrc" | grep -oE '[0-9]+' | sort -u
}

value() { kreadconfig6 --file "$appletsrc" --group Containments --group "$1" --group Wallpaper --group "$plugin" --group General --key "$2"; }

restart_shell() { systemctl --user restart plasma-plasmashell; }

case "${1:-status}" in
  status)
    for c in $(containments); do
      printf 'containment %s  present=%s  fps=%s  source=%s\n' "$c" "$(value "$c" PresentMode)" "$(value "$c" Fps)" "$(value "$c" WallpaperSource)"
    done
    ;;
  purge)
    rm -rf "$HOME/.cache/wescene-renderer" "$HOME/.cache/wallpaper-scene-renderer"
    restart_shell
    echo "shader caches cleared, plasmashell restarted"
    ;;
  present)
    mode="${2:?present mode 0-4 required}"
    for c in $(containments); do
      kwriteconfig6 --file "$appletsrc" --group Containments --group "$c" --group Wallpaper --group "$plugin" --group General --key PresentMode "$mode"
    done
    restart_shell
    echo "PresentMode=$mode on $(containments | tr '\n' ' ')"
    ;;
  view)
    src="$(value "$(containments | head -n1)" WallpaperSource)"
    lib="$(value "$(containments | head -n1)" SteamLibraryPath)"
    lib="${lib#file://}"
    if [ -n "${2:-}" ]; then
      scene="$lib/steamapps/workshop/content/431960/$2/scene.pkg"
    else
      scene="$(dirname "${src#file://}")/scene.pkg"
    fi
    exec sceneviewer --present-mode "${3:-0}" --resolution 1920x1080 \
      "$lib/steamapps/common/wallpaper_engine/assets" "$scene"
    ;;
  *)
    sed -n 3,8p "$0" >&2; exit 2
    ;;
esac
