{ pkgs, ... }:
{
  services.dnsmasq = {
    enable = true;
    settings = {
      address = [ "/nfra.majoutes.fr/10.42.40.23" ];
      listen-address = [ "127.0.0.1" ];
      bind-interfaces = true;
    };
  };

  environment.systemPackages = [ pkgs.sshuttle ];
}
