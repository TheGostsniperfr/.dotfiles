{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = github:nix-community/NUR;

  };
  outputs = { self, nixpkgs, home-manager, nur, ... }: 
  let 
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in  
  {
    nixosConfigurations.brian = lib.nixosSystem {
      inherit system;
      modules = [ 
        ./configuration.nix
        
      ];
    };

    homeConfigurations.brian = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ 
        ./home.nix 
        nur.nixosModules.nur
      ];
    }; 
  };
}
