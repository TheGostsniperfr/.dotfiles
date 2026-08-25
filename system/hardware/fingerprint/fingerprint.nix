{ pkgs, ... }:

let
  libfprint-focaltech = pkgs.callPackage ./libfprint-focaltech.nix { };
in
{
  services.fprintd.package = pkgs.fprintd.override {
    libfprint = libfprint-focaltech;
  };

  # The reader stops answering fprintd after USB autosuspend kicks in.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2808", ATTR{idProduct}=="a658", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
  '';
}
