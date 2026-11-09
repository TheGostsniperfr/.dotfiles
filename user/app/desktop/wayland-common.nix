{ config, pkgs, lib, ... }:

let
  colors = config.lib.stylix.colors.withHashtag;
  fonts = config.stylix.fonts;

  waybarModules = {
    "clock" = {
      format = "{:%a %d %b  %H:%M}";
      tooltip-format = "<tt>{calendar}</tt>";
    };
    "cpu" = { format = "  {usage}%"; interval = 5; };
    "memory" = { format = "  {percentage}%"; interval = 5; };
    "pulseaudio" = {
      format = "{icon}  {volume}%";
      format-muted = "  muted";
      format-icons.default = [ "" "" "" ];
      on-click = "pavucontrol";
    };
    "network" = {
      format-wifi = "  {signalStrength}%";
      format-ethernet = "󰈀  {ipaddr}";
      format-disconnected = "󰖪  offline";
      tooltip-format = "{ifname} {ipaddr}/{cidr}";
    };
    "tray" = { spacing = 8; };
  };

  mkWaybarConfig = workspaceModule: builtins.toJSON (waybarModules // {
    layer = "top";
    position = "top";
    height = 32;
    margin-top = 6;
    margin-left = 10;
    margin-right = 10;
    modules-left = [ workspaceModule ];
    modules-center = [ "clock" ];
    modules-right = [ "tray" "network" "cpu" "memory" "pulseaudio" ];
  });

  # Launched by each compositor rather than as systemd user units: units
  # bound to graphical-session.target would also start inside Plasma, and
  # mako would steal org.freedesktop.Notifications from plasmashell.
  sessionAutostart = pkgs.writeShellScriptBin "wayland-session-autostart" ''
    compositor="$1"
    ${pkgs.swaybg}/bin/swaybg -m fill -i ${config.stylix.image} &
    ${pkgs.waybar}/bin/waybar -c "$HOME/.config/waybar/$compositor.jsonc" &
    ${pkgs.mako}/bin/mako &
    ${pkgs.hypridle}/bin/hypridle &
    ${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1 &
    fcitx5 -d --replace &
  '';

  screenshotRegion = pkgs.writeShellScriptBin "screenshot-region" ''
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
in
{
  home.packages = [
    sessionAutostart
    screenshotRegion
    pkgs.brightnessctl
    pkgs.playerctl
    pkgs.pavucontrol
    pkgs.wl-clipboard
  ];

  programs.fuzzel = {
    enable = true;
    settings.main = {
      terminal = "ghostty";
      layer = "overlay";
      width = 40;
      lines = 12;
    };
    settings.border = { radius = 12; width = 2; };
  };

  programs.waybar = {
    enable = true;
    style = lib.mkAfter ''
      * { font-family: "${fonts.monospace.name}"; font-size: 13px; }
      window#waybar { background: transparent; }
      .modules-left, .modules-center, .modules-right {
        background: alpha(@base00, 0.85);
        border: 2px solid @base02;
        border-radius: 12px;
        padding: 0 10px;
      }
      #workspaces button { padding: 0 6px; color: @base04; }
      #workspaces button.active, #workspaces button.focused { color: @base0D; }
      #clock, #cpu, #memory, #pulseaudio, #network, #tray { padding: 0 8px; }
    '';
  };

  xdg.configFile = {
    "waybar/hyprland.jsonc".text = mkWaybarConfig "hyprland/workspaces";
    "waybar/niri.jsonc".text = mkWaybarConfig "niri/workspaces";

    "mako/config".text = ''
      font=${fonts.sansSerif.name} 11
      background-color=${colors.base00}
      text-color=${colors.base05}
      border-color=${colors.base0D}
      border-radius=12
      border-size=2
      padding=12
      margin=10
      default-timeout=6000

      [urgency=high]
      border-color=${colors.base08}
      default-timeout=0
    '';

    "hypr/hypridle.conf".text = ''
      general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = loginctl lock-session
      }
      listener {
        timeout = 600
        on-timeout = loginctl lock-session
      }
    '';
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general.hide_cursor = true;
      label = [{
        text = "$TIME";
        font_size = 72;
        position = "0, 120";
        halign = "center";
        valign = "center";
      }];
    };
  };
}
