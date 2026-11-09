{ pkgs, lib, ... }:

{
  programs.hyprland.enable = true;

  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  # niri turns gnome-keyring on by default; it would race KWallet for
  # org.freedesktop.secrets inside the Plasma session.
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  # Registers the PAM service hyprlock needs to unlock.
  programs.hyprlock.enable = true;

  environment.systemPackages = [ pkgs.xwayland-satellite ];
}
