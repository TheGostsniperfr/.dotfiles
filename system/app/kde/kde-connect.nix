{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.kdePackages.kdeconnect-kde
  ];
}