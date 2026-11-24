{ ... }:

{
  imports = [
    ./common.nix
    ./desk
    ./vicinae.nix
    ./infra.nix
  ];

  programs.plasma = {
    enable = true;
    overrideConfig = false;
  };
}
