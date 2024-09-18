{ pkgs, userSettings, ... }:

{
  home.packages = [
    pkgs.git
  ];

  programs.git = {
    enable = true;
    # userName = "TheGostsniperfr";
    userName = "brian.perret";
    # userEmail = userSettings.email;
    userEmail = "brian.perret@epita.fr";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}