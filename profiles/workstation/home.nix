{ config, pkgs, userSettings, ... }:

{
  imports = [
    ../base/home.nix

    ../../user/app/ai/gemini.nix
  ];
}
