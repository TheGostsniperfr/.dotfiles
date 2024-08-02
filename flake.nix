{
  description = "Flake of TheGostsniper";

  outputs = inputs@{ self, nixpkgs, home-manager, nur, ... }: 
  let 
    systemSettings = {
      profile = "personal";
      system = "x86_64-linux"; 
      timeZone = "Europe/Paris";
      locale = "en_US.UTF-8";
      extraLocale = "fr_FR.UTF-8";
      keyboardLayout = "us";
    };

    userSettings = rec {
      username = "brian";
      email = "brianperret.pro@gmail.com";
      dotfilesDir = "~/.dotfiles";
    };


    lib = nixpkgs.lib;
    
    pkgs = nixpkgs.legacyPackages.${systemSettings.system};

    # Systems that can run tests:
    supportedSystems = [ "aarch64-linux" "i686-linux" "x86_64-linux" ];

    # Function to generate a set based on supported systems:
    forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

    # Attribute set of nixpkgs for each system:
    nixpkgsFor = forAllSystems (system: import inputs.nixpkgs { inherit system; });
  in  
  {
    nixosConfigurations.brian = lib.nixosSystem {
      system = systemSettings.system;
      modules = [ 
        (./. + "/profiles" + ("/" + systemSettings.profile) + "/configuration.nix")
      ];

      specialArgs = {
        inherit systemSettings;
        inherit userSettings;
        inherit inputs;
      };
    };

    homeConfigurations.brian = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ 
        (./. + "/profiles" + ("/" + systemSettings.profile) + "/home.nix")
        nur.nixosModules.nur
      ];

      extraSpecialArgs = {
        inherit systemSettings;
        inherit userSettings;
        inherit inputs;
      };
    };

    packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = self.packages.${system}.install;

          install = pkgs.writeShellApplication {
            name = "install";
            runtimeInputs = with pkgs; [ git ];
            text = ''${./install.sh} "$@"'';
          };
        });

      apps = forAllSystems (system: {
        default = self.apps.${system}.install;

        install = {
          type = "app";
          program = "${self.packages.${system}.install}/bin/install";
        };
      }); 
  };


 inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = github:nix-community/NUR;
  };
}
