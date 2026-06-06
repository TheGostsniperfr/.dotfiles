{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    pkgs.spotify-adblocked
  ];

  xdg.configFile."spotify-adblock/config.toml".source = "${pkgs.spotify-adblock}/etc/spotify-adblock/config.toml";
}