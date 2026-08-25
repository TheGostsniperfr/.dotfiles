{ config, pkgs, userSettings, ... }:

{
  imports = [
    ../base/home.nix
    # ../../user/app/zellij/zellij-remote.nix # auto-attach zellij wrapper on terminal open, unused
    ../../user/app/video/davinci-resolve.nix
  ];

  # Physical-output rendering regression (kwin_wayland spamming
  # GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT after login instead of painting to
  # HDMI-A-1/DP-1/DP-2) was traced to the nvidiaPackages.beta branch — see
  # system/hardware/nvidia/nvidia-gpu.nix. Neither a readback kick
  # (spectacle screenshot) nor a compositor restart (kwin_wayland --replace,
  # which also races the session's kwin_wayland_wrapper respawn and
  # Sunshine's own DP-3 modeset) fix it client-side; it needs the driver fix.
}
