{ lib, osConfig, ... }:

let
  nvidiaIsPrimary =
    builtins.elem "nvidia" osConfig.services.xserver.videoDrivers
    && !osConfig.hardware.nvidia.prime.offload.enable
    && !osConfig.hardware.nvidia.prime.sync.enable;

  workspaceBinds = lib.concatMap (n:
    let key = toString (lib.mod n 10); in [
      "SUPER, ${key}, workspace, ${toString n}"
      "SUPER SHIFT, ${key}, movetoworkspace, ${toString n}"
    ]) (lib.range 1 10);
in
{
  imports = [ ./wayland-common.nix ];

  wayland.windowManager.hyprland = {
    enable = true;
    # Use the binaries from programs.hyprland so the session and the portal match.
    package = null;
    portalPackage = null;
    configType = "hyprlang";

    settings = {
      monitor = [ ",preferred,auto,1" ];

      env = [
        "QT_QPA_PLATFORMTHEME,kde"
        "XCURSOR_SIZE,24"
      ] ++ lib.optionals nvidiaIsPrimary [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "NVD_BACKEND,direct"
      ];

      exec-once = [ "wayland-session-autostart hyprland" ];

      general = {
        gaps_in = 5;
        gaps_out = 12;
        border_size = 2;
        layout = "dwindle";
      };

      decoration = {
        rounding = 12;
        active_opacity = 1.0;
        inactive_opacity = 0.94;
        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          vibrancy = 0.2;
        };
        shadow = {
          enabled = true;
          range = 20;
          render_power = 3;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "snappy, 0.05, 0.9, 0.1, 1.05"
          "smooth, 0.25, 1, 0.5, 1"
        ];
        animation = [
          "windows, 1, 5, snappy, popin 80%"
          "windowsOut, 1, 4, smooth, popin 80%"
          "border, 1, 8, default"
          "fade, 1, 5, smooth"
          "workspaces, 1, 5, smooth, slidefade 20%"
        ];
      };

      dwindle.preserve_split = true;

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };

      gesture = [ "3, horizontal, workspace" ];

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      windowrule = [
        "float on, match:class ^(pavucontrol|org.pulseaudio.pavucontrol)$"
        "float on, match:class ^(org.kde.polkit-kde-authentication-agent-1)$"
      ];

      bind = [
        "SUPER, Return, exec, ghostty"
        "SUPER, Space, exec, fuzzel"
        "SUPER, E, exec, dolphin"
        "SUPER, L, exec, loginctl lock-session"
        "SUPER, Q, killactive"
        "SUPER, F, fullscreen"
        "SUPER, V, togglefloating"
        "SUPER, P, pseudo"
        "SUPER, J, layoutmsg, togglesplit"
        "SUPER SHIFT, E, exit"
        ", Print, exec, screenshot-region"

        "SUPER, left, movefocus, l"
        "SUPER, right, movefocus, r"
        "SUPER, up, movefocus, u"
        "SUPER, down, movefocus, d"
        "SUPER SHIFT, left, movewindow, l"
        "SUPER SHIFT, right, movewindow, r"
        "SUPER SHIFT, up, movewindow, u"
        "SUPER SHIFT, down, movewindow, d"

        "SUPER, S, togglespecialworkspace, scratch"
        "SUPER SHIFT, S, movetoworkspace, special:scratch"
        "SUPER, mouse_down, workspace, e+1"
        "SUPER, mouse_up, workspace, e-1"
      ] ++ workspaceBinds;

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl s 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
    };
  };
}
