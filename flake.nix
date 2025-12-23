{
  description = "Flake of TheGostsniper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    make-project-prompt.url = "github:briossant/make-project-prompt";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nur, nixos-hardware, make-project-prompt, sops-nix, ... }: 
  let 
    # Global Settings
    systemSettings = {
      system = "x86_64-linux"; 
      timeZone = "Europe/Paris";
      locale = "en_US.UTF-8";
      extraLocale = "fr_FR.UTF-8";
      keyboardLayout = "us";
    };

    userSettings = {
      username = "brian";
      email = "brianperret.pro@gmail.com";
      dotfilesDir = "~/.dotfiles";
    };

    lib = nixpkgs.lib;

    # Logic to detect directories in ./hosts
    hosts = builtins.attrNames (lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./hosts));

    # Function to create the configuration
    mkHost = hostName: lib.nixosSystem {
      system = systemSettings.system;
      
      # Pass inputs and settings to all modules
      specialArgs = {
        inherit inputs systemSettings userSettings;
      };

      modules = [
        # 1. Global Home Manager Setup
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = {
            inherit inputs systemSettings userSettings;
            make-project-prompt = inputs.make-project-prompt;
          };
          # Global NUR import for Home Manager
          home-manager.users.${userSettings.username}.imports = [ 
            nur.modules.homeManager.default 
          ];
        }

        # 2. Global Sops Setup
        sops-nix.nixosModules.sops

        # 3. Import the Host Specific File (The "Bind")
        (./hosts + "/${hostName}/default.nix")

        # 4. Force Hostname and Allow Unfree globally
        { 
          networking.hostName = hostName; 
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };

  in  
  {
    # Generate configurations for every folder found in ./hosts
    nixosConfigurations = lib.genAttrs hosts mkHost;

    # Keep your formatter/packages logic if needed
    packages.x86_64-linux.install = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in pkgs.writeShellApplication {
        name = "install";
        runtimeInputs = with pkgs; [ git ];
        text = ''${./install.sh} "$@"'';
    };
  };
}