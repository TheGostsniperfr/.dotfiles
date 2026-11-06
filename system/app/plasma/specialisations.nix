{ userSettings, ... }:

let
  mkThemeSpecialisation = theme: {
    configuration.home-manager.users.${userSettings.username}.plasma.theme = theme;
  };
in
{
  specialisation.breeze-light = mkThemeSpecialisation "breeze-light";
}
