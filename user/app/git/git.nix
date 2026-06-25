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
        name = "TheGostsniperfr";
        email = "brianperret.pro@gmail.com";
      };
      init.defaultBranch = "main";
      core = {
        sshCommand = "ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes";
      };
    };

    signing = {
      signByDefault = false; 
      key = "318BD4D2D1ED7837";
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
            signingKey = "318BD4D2D1ED7837";
          };

          core = {
            sshCommand = "ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes";
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