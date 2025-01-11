{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Spotify (no ads)
    nur.repos.nltch.spotify-adblock    #for installing spotify-adblock
    nur.repos.nltch.ciscoPacketTracer8 #for installing packettracer8 
  ];
}