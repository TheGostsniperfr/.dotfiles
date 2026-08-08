{ pkgs, userSettings, ... }:

{
  home.packages = [
    pkgs.git
    pkgs.pre-commit
    pkgs.gh
  ];

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "TheGostsniperfr";
        email = "brianperret.pro@gmail.com";
      };
      init.defaultBranch = "main";
      core = {
        sshCommand = "ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes";
      };
      credential."https://github.com" = {
        helper = "${pkgs.gh}/bin/gh auth git-credential";
      };
    };

    signing = {
      signByDefault = false;
      key = "22DEE91446BB48B8";
    };

    includes = [
      {
        condition = "gitdir:~/Documents/aepita/";
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
        condition = "gitdir:~/Documents/aepita/forge/";
        contents = {
          user = {
            name = "Brian Perret";
            email = "brian1.perret@epita.fr";
            signingKey = "22DEE91446BB48B8";
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
            signingKey = "22DEE91446BB48B8";
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
            signingKey = "22DEE91446BB48B8";
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
