{
  description = "ZenFul nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs @ { 
    self, 
    nix-darwin, 
    nixpkgs, 
    mac-app-util,
    nix-homebrew
  }: let
    configuration = { pkgs, config, ... }: {
      # Custom Overlays
      nixpkgs.overlays = [
        (final: prev: {
          alacritty = prev.alacritty.overrideAttrs (old: {
            postInstall =
              (old.postInstall or "")
              + ''
                cp ${./assets/alacritty.icns} $out/Applications/Alacritty.app/Contents/Resources/alacritty.icns
              '';
          });
        })
      ];

      system.primaryUser = "ayato";

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          pkgs.alacritty
          pkgs.eza
          pkgs.fd
          pkgs.ffmpeg
          pkgs.fzf
          pkgs.gh
          pkgs.git
          pkgs.imagemagick
          pkgs.localsend
          pkgs.moonlight-qt
          pkgs.neovim
          pkgs.nodejs
          pkgs.notion-app
          pkgs.oh-my-posh
          pkgs.proton-pass-cli
          pkgs.proton-vpn
          pkgs.python3
          pkgs.ripgrep
          pkgs.spotify
          pkgs.stow
          pkgs.tealdeer
          pkgs.tmux
        ];

      # Homebrew packages installed in system profile.
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "zap";
        };
        brews = [];
        casks = [
          "discord"
          "docker-desktop"
          "font-inter"
          "font-montserrat"
          "font-poppins"
          "proton-mail"
          "proton-drive"
          "steam"
          "zen"
        ];
      };

      # List fonts installed in system profile.
      fonts.packages =
        [
          pkgs.nerd-fonts.jetbrains-mono
        ];

      environment.pathsToLink= [
        "/share/terminfo"
      ];

      # Set the hostname of the system. This is used by the systemd service manager and other tools to identify the machine.
      networking.hostName = "asgard";
      networking.localHostName = "asgard";
      networking.computerName = "asgard";

      # Necessary for using flakes on this system.
      nix = {
        gc = {
          automatic = true;
          interval = {
            Hour = 3;
            Minute = 15;
            Weekday = 7;
          };
          options = "--delete-older-than 14d";
        };
        optimise.automatic = true;
        registry.nixpkgs.flake = nixpkgs;
        settings = {
          auto-optimise-store = true;
          experimental-features = "nix-command flakes";
        };
      };

      # set the allowUnfreePredicate to allow specific unfree packages
      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (pkgs.lib.getName pkg) [
          "notion-app"
          "spotify"
        ];

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake
    darwinConfigurations."asgard" = nix-darwin.lib.darwinSystem {
      modules = 
        [ 
          mac-app-util.darwinModules.default # Enables trampoline app generation automatically
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              # Apple Silicon Only
              enableRosetta = false;
              # User owning the homebrew prefix
              user = "ayato";
              
              autoMigrate = true;
            };
           }
        ];
    };

    # Expose the packages set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."asgard".pkgs;
  };
}
