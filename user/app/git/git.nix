{ pkgs, userSettings, ... }:

{
  home.packages = [
    pkgs.git
    pkgs.pre-commit
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