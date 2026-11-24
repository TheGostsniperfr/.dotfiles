{ inputs, pkgs, ... }:

let
  ext = inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ inputs.vicinae.homeManagerModules.default ];

  # The desk module provides a theme per preset instead.
  stylix.targets.vicinae.enable = false;

  programs.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
      environment.USE_LAYER_SHELL = 1;
    };

    extensions = with ext; [
      github
      bitwarden
      otp
      ssh
      podman
      port-killer
      process-manager
      nix
      jwt
      it-tools
      kde-connect
      kde-system-settings
      kwin-window-layouts
      color-picker
      color-converter
    ];

    settings = {
      close_on_focus_loss = true;
      pop_to_root_on_close = true;
      search_files_in_root = false;
      font.normal = { family = "Inter"; size = 11; };
      # The desk module writes a theme named "desk" for the active preset.
      theme = {
        dark = { name = "desk"; icon_theme = "default"; };
        light = { name = "desk"; icon_theme = "default"; };
      };
      launcher_window.opacity = 0.9;
    };
  };

  programs.plasma = {
    hotkeys.commands.vicinae = {
      name = "Vicinae";
      # Global: apps no longer receive Ctrl+K (bash kill-line, VS Code
      # chords, browser and Discord quick switchers).
      key = "Ctrl+K";
      command = "vicinae toggle";
    };
    # One launcher only: KRunner stays installed but loses its shortcuts.
    shortcuts."services/org.kde.krunner.desktop"._launch = [ ];
    configFile.krunnerrc.General.ActivateWhenTypingOnDesktop = false;
  };
}
