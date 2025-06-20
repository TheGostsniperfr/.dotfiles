{
  description = "Flake of TheGostsniper";

  outputs = inputs@{ self, nixpkgs, home-manager, nur, nixos-hardware, make-project-prompt, ... }: 
  let 
    systemSettings = {
      profile = "work";
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

    supportedSystems = [ "aarch64-linux" "i686-linux" "x86_64-linux" ];

    forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

    nixpkgsFor = forAllSystems (system: import inputs.nixpkgs { inherit system; });
  in  
  {
    nixosConfigurations.brian = lib.nixosSystem {
      system = systemSettings.system;
      modules = [ 
        (./. + "/profiles" + ("/" + systemSettings.profile) + "/configuration.nix")
        nixos-hardware.nixosModules.common-gpu-nvidia
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
        nur.modules.homeManager.default
      ];

      extraSpecialArgs = {
        inherit systemSettings;
        inherit userSettings;
        inherit inputs;
        make-project-prompt = inputs.make-project-prompt;
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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    make-project-prompt.url = "github:briossant/make-project-prompt";
  };
}
