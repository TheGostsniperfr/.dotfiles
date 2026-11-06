{ pkgs, ... }:

let
  libfprint-focaltech = pkgs.callPackage ./libfprint-focaltech.nix { };
in
{
  services.fprintd.package = pkgs.fprintd.override {
    libfprint = libfprint-focaltech;
  };

  # Suspending mid-verify (lockscreen) leaves a stale claim, so every later
  # Claim fails with "already claimed". fprintd is D-Bus activated and comes
  # back fresh on resume.
  systemd.services.fprintd = {
    conflicts = [ "sleep.target" ];
    before = [ "sleep.target" ];
  };

  # The reader stops answering fprintd after USB autosuspend kicks in.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2808", ATTR{idProduct}=="a658", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
  '';
}
