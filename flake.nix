{
  description = "Flake of TheGostsniper";

  outputs = inputs@{ self, nixpkgs, home-manager, nur, ... }: 
  let 
    systemSettings = {
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
  in  
  {
    nixosConfigurations.brian = lib.nixosSystem {
      modules = [ 
        ./configuration.nix
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
        ./home.nix 
        nur.nixosModules.nur
      ];

      extraSpecialArgs = {
        inherit systemSettings;
        inherit userSettings;
        inherit inputs;
      };
    }; 
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
