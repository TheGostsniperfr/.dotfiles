{ config, lib, pkgs, ... }:

let
  cfg = config.desk;
  presets = import ./presets.nix { inherit pkgs; };
  preset = presets.${cfg.preset};
  variant = preset.${cfg.polarity};
  combo = "${cfg.preset}-${cfg.polarity}";
  colors = config.lib.stylix.colors;

  plasmaStyle = id: p:
    pkgs.runCommand "plasma-style-${id}" { nativeBuildInputs = [ pkgs.python3 ]; } ''
      python3 ${./plasma-style.py} $out/share/plasma/desktoptheme/${id} ${id} "Desk ${p.name}" \
        ${toString p.radius.panel} ${toString p.panelAlpha} ${toString p.radius.task}
    '';

  styleId = "desk-${cfg.preset}";
  schemeId = "Desk-${combo}";

  deskCli = pkgs.callPackage ./cli { };

  palette = pkgs.runCommand "desk-palette-${combo}" {
    nativeBuildInputs = [ pkgs.python3 ];
    spec = builtins.toJSON {
      id = schemeId;
      name = "Desk ${preset.name} (${cfg.polarity})";
      inherit (cfg) polarity;
      inherit (preset) accent;
      colors = lib.genAttrs (map (i: "base0${lib.toHexString i}") (lib.range 0 15)) (slot: colors.${slot});
    };
    passAsFile = [ "spec" ];
  } "python3 -I ${./palette.py} $specPath $out";


  allCombos = lib.concatMap (p: map (pol: { preset = p; polarity = pol; }) [ "dark" "light" ])
    (lib.attrNames presets);
in
{
  options.desk = {
    preset = lib.mkOption {
      type = lib.types.enum (lib.attrNames presets);
      default = "catppuccin";
      description = "Desktop style preset applied at login. Others are switchable at runtime with `desk`.";
    };
    polarity = lib.mkOption {
      type = lib.types.enum [ "dark" "light" ];
      default = "dark";
    };
    isSpecialisation = lib.mkOption {
      type = lib.types.bool;
      default = false;
      internal = true;
    };
  };

  config = {
    stylix.base16Scheme = variant.scheme;
    stylix.polarity = cfg.polarity;
    stylix.opacity.terminal = 0.9;

    home.packages = [
      deskCli
      (plasmaStyle styleId preset)
      pkgs.tela-icon-theme
      pkgs.fluent-icon-theme
      pkgs.whitesur-icon-theme
      pkgs.papirus-icon-theme
      pkgs.inter
      (pkgs.makeDesktopItem {
        name = "desk-toggle";
        desktopName = "Clair / sombre";
        comment = "Bascule le thème du bureau entre clair et sombre";
        exec = "desk toggle";
        icon = if cfg.polarity == "dark" then "weather-clear" else "weather-clear-night";
        categories = [ "Settings" ];
      })
    ];

    # Plasma's GTK sync rewrites these as plain files whenever the color
    # scheme changes, which would block every later activation.
    xdg.configFile."gtk-3.0/gtk.css".force = true;
    xdg.configFile."gtk-4.0/gtk.css".force = true;

    xdg.configFile."autostart/desk-restore.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Restore desk style
      Exec=${lib.getExe deskCli} restore
      X-KDE-autostart-phase=2
    '';

    # Applied by `desk`, not programs.plasma.panels: see panels.nix.
    xdg.dataFile."desk/panels.js".text = import ./panels.nix { inherit lib preset; };

    xdg.dataFile."color-schemes/${schemeId}.colors".source = "${palette}/kde.colors";

    programs.plasma = {
      workspace = {
        colorScheme = schemeId;
        theme = styleId;
        iconTheme = variant.icons;
        widgetStyle = "Klassy";
        windowDecorations = { library = "org.kde.klassy"; theme = "Klassy"; };
      };

      fonts = let inter = size: { family = "Inter"; pointSize = size; }; in {
        general = inter 10;
        menu = inter 10;
        toolbar = inter 10;
        small = inter 8;
        windowTitle = inter 10;
        fixedWidth = { family = "JetBrainsMono Nerd Font"; pointSize = 10; };
      };

      shortcuts."services/desk-toggle.desktop"._launch = "Meta+Shift+L";

      configFile = {
        kwinrc.Plugins = {
          blurEnabled = false;
          glassEnabled = true;
          kwin4_effect_shapecornersEnabled = true;
        };
        kwinrc."Effect-blurplus" = {
          BlurStrength = 8;
          BlurDocks = true;
          BlurMenus = true;
          TransparentBlur = true;
          BlurNonMatching = true;
          BlurDecorations = true;
          TopCornerRadius = preset.radius.window;
          BottomCornerRadius = preset.radius.window;
          MenuCornerRadius = 8;
          DockCornerRadius = preset.radius.panel;
          Saturation = 1.3;
          NoiseStrength = 1;
        };
        kwinrc."Round-Corners" = {
          Size = preset.radius.window;
          InactiveCornerRadius = preset.radius.window;
          OutlineColor = colors.withHashtag.${preset.accent};
          ActiveOutlineAlpha = 110;
          InactiveOutlineColor = colors.withHashtag.base03;
          InactiveOutlineAlpha = 70;
          SecondOutlineThickness = 0;
          InactiveSecondOutlineThickness = 0;
        };
        "klassy/klassyrc".Windeco = preset.klassy // {
          WindowCornerRadius = preset.radius.window;
          RoundAllCornersWhenNoBorders = true;
        };
        "klassy/klassyrc".TitleBarOpacity = {
          ActiveTitleBarOpacity = 88;
          InactiveTitleBarOpacity = 80;
          BlurTransparentTitleBars = true;
        };
      };
    };

    programs.vicinae.themes.desk = let c = colors.withHashtag; in {
      meta = {
        version = 1;
        name = "Desk ${preset.name}";
        description = "Follows the active desk preset";
        variant = cfg.polarity;
        inherits = "vicinae-${cfg.polarity}";
      };
      colors = {
        core = {
          background = c.base00;
          foreground = c.base05;
          secondary_background = c.base01;
          border = c.base02;
          accent = c.${preset.accent};
        };
        accents = {
          blue = c.base0D; green = c.base0B; magenta = c.base0E; orange = c.base09;
          purple = c.base0E; red = c.base08; yellow = c.base0A; cyan = c.base0C;
        };
      };
    };

    xdg.dataFile."konsole/${schemeId}.colorscheme".source = "${palette}/konsole.colorscheme";

    # setupKonsole copies a profile pinned to Dracula on every activation.
    home.activation.deskKonsole = lib.hm.dag.entryAfter [ "setupKonsole" ] ''
      run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file "$HOME/.local/share/konsole/Brian.profile" \
        --group Appearance --key ColorScheme ${schemeId}
    '';

    # The desk CLI switches combos by running a specialisation's activation;
    # it needs the base generation, which specialisations do not link back to.
    home.activation.deskState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      state="${config.xdg.stateHome}/desk"
      run mkdir -p "$state"
      ${lib.optionalString (!cfg.isSpecialisation) ''
        run ln -sfn "$newGenPath" "$state/base"
        echo "${combo}" > "$state/default"
      ''}
      echo "${combo}" > "$state/applied"
    '';

    specialisation = lib.mkIf (!cfg.isSpecialisation) (lib.listToAttrs (map
      (c: {
        name = "${c.preset}-${c.polarity}";
        value.configuration = {
          desk = {
            preset = lib.mkForce c.preset;
            polarity = lib.mkForce c.polarity;
            isSpecialisation = true;
          };
        };
      })
      (lib.filter (c: c.preset != cfg.preset || c.polarity != cfg.polarity) allCombos)));
  };
}
