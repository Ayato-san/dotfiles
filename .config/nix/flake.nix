{
  description = "Multi-tier cross-platform system setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      mac-app-util,
      nix-homebrew,
      home-manager,
    }:
    let
      linuxSystem = "x86_64-linux";
      linuxPkgs = import nixpkgs {
        system = linuxSystem;
        config.allowUnfree = true;
      };
      mkHome =
        profile:
        home-manager.lib.homeManagerConfiguration {
          pkgs = linuxPkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home/${profile}.nix
            {
              home = {
                username = "ayato";
                homeDirectory = "/home/ayato";
                stateVersion = "26.05";
              };
              programs.home-manager.enable = true;
            }
          ];
        };
    in
    {
      packages.${linuxSystem}.home-manager = home-manager.packages.${linuxSystem}.home-manager;

      # Standalone Home Manager configurations for non-NixOS Linux distributions.
      homeConfigurations = {
        "ayato@server" = mkHome "server";
        "ayato@dev" = mkHome "dev";
        "ayato@desktop" = mkHome "desktop";
      };

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
          modules = [ ./modules/dev.nix ];
        };

        "desktop" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./modules/desktop.nix ];
        };
      };
    };
}
