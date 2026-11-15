{ pkgs-unstable, ... }:

{
  # Stable lags behind Discord's server-side DAVE E2EE changes, breaking incoming video.
  home.packages = [
    pkgs-unstable.discord
  ];
}
