{ pkgs, lib, inputs, userSettings, ... }:

let
  mkPalette = setPriority: { scheme, polarity, wallpaper, plasmaTheme }: {
    stylix = {
      base16Scheme = setPriority "${pkgs.base16-schemes}/share/themes/${scheme}.yaml";
      polarity = setPriority polarity;
      image = setPriority pkgs.nixos-artwork.wallpapers.${wallpaper}.gnomeFilePath;
    };
    home-manager.users.${userSettings.username}.plasma.theme = setPriority plasmaTheme;
  };
in
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  config = lib.mkMerge [
    {
      stylix = {
        enable = true;

        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font";
          };
          sansSerif = {
            package = pkgs.dejavu_fonts;
            name = "DejaVu Sans";
          };
          serif = {
            package = pkgs.dejavu_fonts;
            name = "DejaVu Serif";
          };
          sizes = {
            terminal = 12;
            applications = 11;
          };
        };

        cursor = {
          package = pkgs.kdePackages.breeze;
          name = "breeze_cursors";
          size = 24;
        };
      };

      home-manager.users.${userSettings.username}.stylix.targets = {
        # plasma-manager owns the Plasma look; stylix's KDE target and qtct
        # platform theme would fight it inside the Plasma session.
        kde.enable = false;
        qt.enable = false;
        # Wallpaper comes from swaybg in wayland-session-autostart; the
        # auto-enabled hyprpaper unit would also run (and segfault) in Plasma.
        hyprland.hyprpaper.enable = false;
        # Firefox profiles are not managed by home-manager.
        firefox.enable = false;
      };
    }

    (mkPalette lib.mkDefault {
      scheme = "catppuccin-mocha";
      polarity = "dark";
      wallpaper = "nineish-catppuccin-mocha";
      plasmaTheme = "breeze-dark";
    })

    {
      specialisation.light.configuration = mkPalette lib.mkForce {
        scheme = "catppuccin-latte";
        polarity = "light";
        wallpaper = "nineish-catppuccin-latte";
        plasmaTheme = "breeze-light";
      };
    }
  ];
}
