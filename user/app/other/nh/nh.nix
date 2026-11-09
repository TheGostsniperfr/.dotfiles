{ userSettings, ... }:

{
  programs.nh = {
    enable = true;
    flake = "/home/${userSettings.username}/.dotfiles";
  };
}
