{ pkgs, config, libs, ... }:

{
  home.packages = [
    pkgs.openstackclient-full
  ];
}
