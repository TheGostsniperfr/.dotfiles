{ pkgs, userSettings, ... }:

{
  home.packages = [
    pkgs.git
  ];

  programs.git = {
    enable = true;
    userName = "TheGostsniperfr";
    userEmail = userSettings.email;
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}