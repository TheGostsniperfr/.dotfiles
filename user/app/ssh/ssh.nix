{ ... }:

{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "home-server-lab" = {
        hostname = "192.168.1.52";
        user = "brian";
        forwardAgent = true;
      };
    };
  };
}
