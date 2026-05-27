{ pkgs, userSettings, ... }:

{
  home.packages = [
    pkgs.git
    pkgs.pre-commit
  ];

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "brian.perret";
        email = "brian.perret@epita.fr";
      };
      init.defaultBranch = "main";
    };

    signing = {
      signByDefault = false; 
      key = "318BD4D2D1ED7837";
    };

    includes = [
      {
        condition = "gitdir:~/Documents/aepita/forge/";
        contents = {
          user = {
            name = "Brian Perret";
            email = "brian1.perret@epita.fr";
            signingKey = "318BD4D2D1ED7837";
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
      {
        condition = "gitdir:~/Documents/aepita/ing2/pae/";
        contents = {
          user = {
            name = "Brian Perret";
            email = "brian.perret@epita.fr";
            signingKey = "318BD4D2D1ED7837";
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
      {
        condition = "gitdir:~/Documents/arffornia/";
        contents = {
          user = {
            name = "TheGostsniperfr";
            email = "brianperret.pro@gmail.com";
            signingKey = "318BD4D2D1ED7837";
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