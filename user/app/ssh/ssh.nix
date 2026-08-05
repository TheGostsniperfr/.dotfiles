{ ... }:

{
  programs.ssh = {
    enable = true;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };
      "home-server-lab" = {
        Hostname = "192.168.1.52";
        User = "brian";
        ForwardAgent = "yes";
      };
    };
  };
}
