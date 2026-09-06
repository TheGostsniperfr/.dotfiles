{ pkgs, userSettings, ... }:

{
  home.packages = [
    pkgs.git
    pkgs.pre-commit
    pkgs.gh
    pkgs.glab
  ];

  services.ssh-agent.enable = true;

  programs.git = {
    enable = true;

    aliases = {
      pull-all = "!for d in */ ; do [ -d \"$d/.git\" ] && echo \"=== Pulling $d ===\" && git -C \"$d\" pull; done";
    };

    settings = {
      user = {
        name = "TheGostsniperfr";
        email = "brianperret.pro@gmail.com";
      };
      init.defaultBranch = "main";
      core = {
        sshCommand = "ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes -o AddKeysToAgent=yes";
      };
      credential."https://github.com" = {
        helper = "${pkgs.gh}/bin/gh auth git-credential";
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
            sshCommand = "ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes -o AddKeysToAgent=yes";
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