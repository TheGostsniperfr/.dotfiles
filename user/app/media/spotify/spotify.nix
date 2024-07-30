{ config, ... }:

{
  home.packages = [
    # Spotify (no ads)
    config.nur.repos.nltch.spotify-adblock    #for installing spotify-adblock
    config.nur.repos.nltch.ciscoPacketTracer8 #for installing packettracer8 
  ];
}