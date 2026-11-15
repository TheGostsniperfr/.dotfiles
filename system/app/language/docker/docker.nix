{ config, pkgs, userSettings, ... }:

{
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };

  users.users.${userSettings.username} = {
    isNormalUser = true;
    extraGroups = [ "docker" ];
  }; 
}
