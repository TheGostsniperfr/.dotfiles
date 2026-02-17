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

    signing = {
      signByDefault = false; 
      key = "brian.perret@epita.fr";
    };

    extraConfig = {
      init.defaultBranch = "main";
    };

    includes = [
      {
        condition = "gitdir:~/Documents/aepita/forge/";
        contents = {
          user = {
            name = "Brian Perret";
            email = "brian1.perret@epita.fr";
            signingKey = "brian1.perret@epita.fr";
          };

          commit = {
            gpgsign = true;
          };

          pull = {
            rebase = true;
          };

          tag = {
            gpgsign = true;
          };
        };
      }
    ];
  };
}