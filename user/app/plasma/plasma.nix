{ config, lib, ... }:

{
  imports = [
    ./common.nix
    ./themes/breeze-dark.nix
    ./themes/breeze-light.nix
  ];

  options.plasma.theme = lib.mkOption {
    type = lib.types.enum [ "breeze-dark" "breeze-light" ];
    default = "breeze-dark";
  };

  config.programs.plasma = {
    enable = true;
    overrideConfig = false;
  };
}
