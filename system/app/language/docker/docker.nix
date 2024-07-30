{ config, pkgs, userSettings, ... }:

{
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  users.users.${userSettings.username} = {
    isNormalUser = true;
    extraGroups = [ "docker" ];
  }; 
}
