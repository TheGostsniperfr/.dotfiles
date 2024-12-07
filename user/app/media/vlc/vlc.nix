{ pkgs, ... }:

{
  home.packages = [
    pkgs.vlc
    pkgs.ffmpeg-full
  ];
}