{ config, lib, ... }:

lib.mkIf (config.plasma.theme == "breeze-light") {
  programs.plasma.workspace = {
    lookAndFeel = "org.kde.breeze.desktop";
    iconTheme = "breeze";
  };
}
