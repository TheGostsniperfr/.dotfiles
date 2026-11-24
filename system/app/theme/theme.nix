{ pkgs, lib, inputs, userSettings, ... }:

{
  imports = [ inputs.stylix.nixosModules.stylix ];

  config = lib.mkMerge [
    {
      stylix = {
        enable = true;
        # System-wide default (SDDM, TTY, Hyprland/niri). The Plasma user
        # session overrides it per preset through the desk module.
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        polarity = "dark";
        image = pkgs.nixos-artwork.wallpapers.nineish-catppuccin-mocha.gnomeFilePath;

        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font";
          };
          sansSerif = {
            package = pkgs.inter;
            name = "Inter";
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

      home-manager.users.${userSettings.username} = {
        stylix.targets = {
          # plasma-manager owns the Plasma look; stylix's KDE target and qtct
          # platform theme would fight it inside the Plasma session.
          kde.enable = false;
          qt.enable = false;
          # Wallpaper comes from swaybg in wayland-session-autostart; the
          # auto-enabled hyprpaper unit would also run (and segfault) in Plasma.
          hyprland.hyprpaper.enable = false;
          # Firefox profiles are not managed by home-manager.
          firefox.enable = false;
          # Base16 palettes are too low-contrast for terminal work; terminals keep Dracula.
          ghostty.enable = false;
        };

        # Plasma's kde-gtk-config rewrites ~/.gtkrc-2.0 as a plain file on every
        # login, so the backup slot is always taken and activation fails.
        gtk.gtk2.force = true;
      };
    }
  ];
}
