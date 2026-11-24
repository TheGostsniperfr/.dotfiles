{ ... }:

{
  services.mediamtx = {
    enable = true;
    settings = {
      logLevel = "info";

      rtsp = false;
      rtmp = false;
      hls = false;
      srt = false;
      api = false;
      metrics = false;
      pprof = false;
      playback = false;

      webrtc = true;
      webrtcAddress = ":8889";
      webrtcLocalUDPAddress = ":8189";
      webrtcLocalTCPAddress = "";
      # The public IP is dynamic and the repo is public, so let STUN discover it
      # instead of pinning webrtcAdditionalHosts.
      webrtcICEServers2 = [
        { url = "stun:stun.l.google.com:19302"; }
      ];

      authMethod = "internal";
      # Any path name works: the stream name chosen in OBS is the secret link,
      # so it never lands in this public repo.
      authInternalUsers = [
        {
          user = "any";
          pass = "";
          ips = [ "127.0.0.1" "::1" ];
          permissions = [ { action = "publish"; } { action = "read"; } ];
        }
        {
          user = "any";
          pass = "";
          ips = [ ];
          permissions = [ { action = "read"; } ];
        }
      ];

      paths.all_others = { };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 8889 ];
    allowedUDPPorts = [ 8189 ];
  };
}
