{
  description = "Multi-tier cross-platform system setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs @ { self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew } : {
    # --- macOS Configurations ---
    darwinConfigurations = {
      "desktop-mac" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [ 
          ./modules/desktop.nix
          mac-app-util.darwinModules.default # Enables trampoline app generation automatically
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Enable Homebrew support in Nix-managed macOS systems
              enable = true;
              # Apple Silicon Only
              enableRosetta = false;
              # User owning the homebrew prefix
              user = "ayato";
              # Automatically migrate existing Homebrew packages to Nix-managed Homebrew
              autoMigrate = true;
            };
           }
        ];
      };
    };

    # --- Linux Configurations ---
    nixosConfigurations = {
      "server" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ ./modules/server.nix ];
      };

      "dev" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ ./modules/min.nix ];
      };

      "desktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ ./modules/desktop.nix ];
      };
    };
  };
}
