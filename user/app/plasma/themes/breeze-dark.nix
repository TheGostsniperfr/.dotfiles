{ config, lib, ... }:

lib.mkIf (config.plasma.theme == "breeze-dark") {
  programs.plasma.workspace = {
    lookAndFeel = "org.kde.breezedark.desktop";
    iconTheme = "Tela-dark";
  };
}
