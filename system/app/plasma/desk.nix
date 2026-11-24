{ lib, pkgs, inputs, userSettings, ... }:

let
  # Built against this system's KWin; must be rebuilt on every Plasma bump,
  # which the flake handles since it uses our kdePackages.
  kwin-glass = (pkgs.kdePackages.callPackage "${inputs.kwin-effects-glass}/nix/package/kwin-glass.nix" { }).overrideAttrs (old: {
    # Upstream dropped the *_core shader variants for KWin 6.7, but KWin 6.6
    # still loads "<name>_core.<ext>" on any GLSL >= 1.40 context, so every
    # shader fails to link and closed windows stay painted on screen.
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/CMakeLists.txt --replace-fail \
        'file(WRITE "generated/''${output_base}''${ARGN}" "''${COMPAT_CORE}\n''${SHADER_SRC_EXPANDED}")' \
        'file(WRITE "generated/''${output_base}''${ARGN}" "''${COMPAT_CORE}\n''${SHADER_SRC_EXPANDED}")
        file(WRITE "generated/''${output_base}_core''${ARGN}" "''${COMPAT_CORE}\n''${SHADER_SRC_EXPANDED}")'
      sed -Ei 's#(<file>generated/([a-z_]+)\.(vert|frag)</file>)#\1<file>generated/\2_core.\3</file>#' src/blur.qrc
    '';
  });

  sddmTheme = pkgs.sddm-astronaut.override { embeddedTheme = "black_hole"; };
in
{
  # KWin loads effects and decorations from the system profile only.
  environment.systemPackages = [
    kwin-glass
    pkgs.kde-rounded-corners
    pkgs.klassy
    sddmTheme
  ];

  services.displayManager.sddm = {
    theme = "sddm-astronaut-theme";
    extraPackages = [ sddmTheme ];
    # The X11 greeter stacks every output at 0,0, so the theme is drawn
    # several times on top of itself. KWin places them like the session does.
    wayland = {
      enable = true;
      compositor = "kwin";
    };
  };

  # What Plasma's "Apply to login screen" button does: give the greeter's KWin
  # the user's monitor layout. Refreshed on each boot from the live session.
  systemd.services.sddm-output-layout = {
    description = "Copy the Plasma monitor layout to the SDDM greeter";
    wantedBy = [ "display-manager.service" ];
    before = [ "display-manager.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      src=/home/${userSettings.username}/.config/kwinoutputconfig.json
      [ -f "$src" ] || exit 0
      install -d -o sddm -g sddm /var/lib/sddm/.config
      install -m 644 -o sddm -g sddm "$src" /var/lib/sddm/.config/kwinoutputconfig.json
    '';
  };

  # Plasma's lock screen is not themable by SDDM themes; reuse the artwork.
  home-manager.users.${userSettings.username}.programs.plasma.kscreenlocker.appearance.wallpaper = lib.mkDefault
    "${sddmTheme}/share/sddm/themes/sddm-astronaut-theme/Backgrounds/black_hole.png";
}
