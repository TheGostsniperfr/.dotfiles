{ pkgs }:

let
  scheme = name: "${pkgs.base16-schemes}/share/themes/${name}.yaml";

  # macOS-like neutrals; no base16 scheme in nixpkgs is close enough.
  whitesurDark = {
    scheme = "WhiteSur Dark"; author = "dotfiles";
    base00 = "1e1e20"; base01 = "2a2a2d"; base02 = "3a3a3d"; base03 = "636366";
    base04 = "aeaeb2"; base05 = "e5e5ea"; base06 = "f2f2f7"; base07 = "ffffff";
    base08 = "ff453a"; base09 = "ff9f0a"; base0A = "ffd60a"; base0B = "32d74b";
    base0C = "64d2ff"; base0D = "0a84ff"; base0E = "bf5af2"; base0F = "ac8e68";
  };
  whitesurLight = {
    scheme = "WhiteSur Light"; author = "dotfiles";
    base00 = "f5f5f7"; base01 = "e8e8ed"; base02 = "d2d2d7"; base03 = "8e8e93";
    base04 = "636366"; base05 = "1d1d1f"; base06 = "111113"; base07 = "000000";
    base08 = "ff3b30"; base09 = "ff9500"; base0A = "b58a00"; base0B = "248a3d";
    base0C = "0a95b5"; base0D = "007aff"; base0E = "af52de"; base0F = "8b6b47";
  };

  # Panel layouts. Widget lists are filled in by panels.nix.
  layout = {
    classic = [{ kind = "full"; floating = true; }];
    fluent = [{ kind = "fluent"; floating = true; }];
    dock = [
      { kind = "topbar"; floating = false; }
      { kind = "dock"; floating = true; }
    ];
  };
in
# radius.panel must stay <= 14: past that the 9-slice corners no longer fit a
# 30px top bar and Plasma silently hides the whole panel.
{
  catppuccin = {
    name = "Catppuccin";
    dark = { scheme = scheme "catppuccin-mocha"; icons = "Tela-dark"; };
    light = { scheme = scheme "catppuccin-latte"; icons = "Tela"; };
    accent = "base0D";
    radius = { window = 14; panel = 14; task = 10; };
    panelAlpha = 0.72;
    panels = layout.classic;
    klassy = { ButtonShape = "ShapeSmallCircle"; ButtonIconStyle = "StyleKite"; TitleAlignment = "AlignLeft"; };
  };

  fluent = {
    name = "Fluent glass";
    dark = { scheme = scheme "windows-10"; icons = "Fluent-dark"; };
    light = { scheme = scheme "windows-10-light"; icons = "Fluent-light"; };
    accent = "base0D";
    radius = { window = 10; panel = 12; task = 8; };
    panelAlpha = 0.62;
    panels = layout.fluent;
    klassy = { ButtonShape = "ShapeFullHeightRectangle"; ButtonIconStyle = "StyleFluent"; TitleAlignment = "AlignLeft"; };
  };

  whitesur = {
    name = "WhiteSur";
    dark = { scheme = whitesurDark; icons = "WhiteSur-dark"; };
    light = { scheme = whitesurLight; icons = "WhiteSur-light"; };
    accent = "base0D";
    radius = { window = 12; panel = 14; task = 10; };
    panelAlpha = 0.5;
    panels = layout.dock;
    klassy = { ButtonShape = "ShapeSmallCircle"; ButtonIconStyle = "StyleKisweet"; TitleAlignment = "AlignCenterFullWidth"; };
  };

  nord = {
    name = "Nord minimal";
    dark = { scheme = scheme "nord"; icons = "Papirus-Dark"; };
    light = { scheme = scheme "nord-light"; icons = "Papirus-Light"; };
    accent = "base0C";
    radius = { window = 8; panel = 2; task = 6; };
    panelAlpha = 0.92;
    panels = layout.classic;
    klassy = { ButtonShape = "ShapeSmallRoundedSquare"; ButtonIconStyle = "StyleKlasse"; TitleAlignment = "AlignLeft"; };
  };
}
