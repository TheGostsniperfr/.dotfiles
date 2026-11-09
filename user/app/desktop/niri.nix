{ config, lib, ... }:

let
  colors = config.lib.stylix.colors.withHashtag;

  workspaceBinds = lib.concatMapStrings (n:
    let key = toString (lib.mod n 10); in ''
      Mod+${key} { focus-workspace ${toString n}; }
      Mod+Shift+${key} { move-column-to-workspace ${toString n}; }
    '') (lib.range 1 10);
in
{
  imports = [ ./wayland-common.nix ];

  xdg.configFile."niri/config.kdl".text = ''
    input {
      keyboard {
        xkb { layout "us"; }
      }
      touchpad {
        tap
        natural-scroll
      }
      focus-follows-mouse max-scroll-amount="0%"
    }

    environment {
      QT_QPA_PLATFORMTHEME "kde"
    }

    layout {
      gaps 12
      center-focused-column "on-overflow"
      always-center-single-column
      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
      }
      default-column-width { proportion 0.5; }
      focus-ring {
        width 2
        active-color "${colors.base0D}"
        inactive-color "${colors.base03}"
      }
      border { off; }
      shadow {
        on
        softness 30
        spread 4
        color "#0007"
      }
    }

    window-rule {
      geometry-corner-radius 12
      clip-to-geometry true
    }

    window-rule {
      match is-active=false
      opacity 0.94
    }

    window-rule {
      match app-id=r#"^(pavucontrol|org\.pulseaudio\.pavucontrol)$"#
      open-floating true
    }

    prefer-no-csd
    screenshot-path "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png"
    hotkey-overlay { skip-at-startup; }

    spawn-at-startup "wayland-session-autostart" "niri"

    binds {
      Mod+Shift+Slash { show-hotkey-overlay; }
      Mod+Return { spawn "ghostty"; }
      Mod+Space { spawn "fuzzel"; }
      Mod+E { spawn "dolphin"; }
      Mod+L { spawn "loginctl" "lock-session"; }
      Mod+Q { close-window; }
      Mod+Shift+E { quit; }
      Mod+O { toggle-overview; }

      Mod+Left { focus-column-left; }
      Mod+Right { focus-column-right; }
      Mod+Up { focus-window-or-workspace-up; }
      Mod+Down { focus-window-or-workspace-down; }
      Mod+Shift+Left { move-column-left; }
      Mod+Shift+Right { move-column-right; }
      Mod+Shift+Up { move-window-up-or-to-workspace-up; }
      Mod+Shift+Down { move-window-down-or-to-workspace-down; }
      Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
      Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
      Mod+WheelScrollRight { focus-column-right; }
      Mod+WheelScrollLeft { focus-column-left; }

      Mod+BracketLeft { consume-or-expel-window-left; }
      Mod+BracketRight { consume-or-expel-window-right; }
      Mod+R { switch-preset-column-width; }
      Mod+M { maximize-column; }
      Mod+F { fullscreen-window; }
      Mod+C { center-column; }
      Mod+V { toggle-window-floating; }
      Mod+W { toggle-column-tabbed-display; }
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }

      ${workspaceBinds}

      Print { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print { screenshot-window; }

      XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "-l" "1" "@DEFAULT_AUDIO_SINK@" "5%+"; }
      XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
      XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
      XF86AudioPlay allow-when-locked=true { spawn "playerctl" "play-pause"; }
      XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "s" "5%+"; }
      XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "s" "5%-"; }
    }
  '';
}
