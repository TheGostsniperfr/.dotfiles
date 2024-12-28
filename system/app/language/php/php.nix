{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    php83
    php83Packages.composer
    mysql84
  ];

  services.mysql = {
    enable = true;
    package = pkgs.mysql84;
  };
}
