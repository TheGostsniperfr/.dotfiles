{ lib, preset }:

# Plasma desktop script that replaces only the panels. plasma-manager's panel
# option deletes plasma-org.kde.plasma.desktop-appletsrc first, which would
# also wipe per-screen wallpapers (Wallpaper Engine) and desktop containments.
let
  launchers = [
    "applications:systemsettings.desktop"
    "preferred://filemanager"
    "preferred://browser"
    "applications:spotify.desktop"
    "applications:desk-toggle.desktop"
  ];

  kickoff = { name = "org.kde.plasma.kickoff"; config.General.icon = "nix-snowflake-white"; };
  pager = "org.kde.plasma.pager";
  tasks = {
    name = "org.kde.plasma.icontasks";
    config.General = {
      launchers = lib.concatStringsSep "," launchers;
      iconSpacing = 2;
    };
  };
  spacer = "org.kde.plasma.panelspacer";
  tray = "org.kde.plasma.systemtray";
  clock = {
    name = "org.kde.plasma.digitalclock";
    config.Appearance = { showDate = true; dateDisplayFormat = "BelowTime"; };
  };
  showDesktop = "org.kde.plasma.showdesktop";
  appMenu = "org.kde.plasma.appmenu";
  separator = "org.kde.plasma.marginsseparator";

  common = {
    location = "bottom";
    height = 46;
    alignment = "center";
    lengthMode = "fill";
  };

  kinds = {
    full.widgets = [ kickoff pager tasks separator tray clock showDesktop ];
    fluent.widgets = [ spacer kickoff tasks spacer tray clock showDesktop ];
    topbar = { location = "top"; height = 30; widgets = [ kickoff appMenu spacer tray clock ]; };
    dock = { lengthMode = "fit"; height = 58; widgets = [ tasks ]; };
  };

  js = builtins.toJSON;

  widgetJs = w:
    let
      widget = if builtins.isString w then { name = w; config = { }; } else w;
      groups = lib.mapAttrsToList (group: entries:
        "w.currentConfigGroup = ${js [ group ]};\n"
        + lib.concatStrings (lib.mapAttrsToList (k: v: "w.writeConfig(${js k}, ${js v});\n") entries))
        widget.config;
    in
    "var w = p.addWidget(${js widget.name});\n" + lib.concatStrings groups;

  panelJs = spec:
    let p = common // kinds.${spec.kind}; in ''
      for (var s = 0; s < screenCount; s++) {
        var p = new Panel("org.kde.panel");
        p.location = ${js p.location};
        p.height = ${toString p.height};
        p.alignment = ${js p.alignment};
        p.lengthMode = ${js p.lengthMode};
        p.floating = ${lib.boolToString spec.floating};
        p.hiding = "none";
        p.opacity = "translucent";
        p.writeConfig("lastScreen[$i]", s);
        ${lib.concatMapStrings widgetJs p.widgets}
      }
    '';
in
''
  panels().forEach(function (p) { p.remove(); });
  ${lib.concatMapStrings panelJs preset.panels}
''
