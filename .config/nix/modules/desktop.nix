{ pkgs, lib, inputs, ... } :
{
  imports = [ ./dev.nix ]; # Pulls all Dev packages automatically

  # 1. Native Nix GUI apps available on both Linux and macOS
  environment.systemPackages = with pkgs; [
    alacritty
    ffmpeg
    imagemagick
    localsend
    moonlight-qt
    notion-app
    proton-vpn
    spotify
  ]

  # 2. Linux-only GUI applications (installed via Nix)
  ++ lib.optionals (!stdenv.isDarwin) [
    discord
    kicad
    steam
  ];

 # 3. macOS-only GUI applications (installed via Homebrew Casks)
  # Requires nix-darwin's homebrew module
  homebrew = lib.mkIf pkgs.stdenv.isDarwin {
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
      # "font-inter"
      # "font-montserrat"
      # "font-poppins"
      "kicad"
      "proton-mail"
      "proton-drive"
      "steam"
      "zen"
    ];
  };

  # Allow unfree packages for specific applications
  nixpkgs.config.allowUnfreePredicate = pkg : builtins.elem (pkgs.lib.getName pkg) [
    "notion-app"
    "spotify"
    "steam"
    "terraform"
  ];

  # Override specific packages with custom configurations
  nixpkgs.overlays = [
    (final: prev: {
      # Runs on all platforms (Linux & macOS)
      moonlight-qt = prev.moonlight-qt.override {
        ffmpeg = prev.ffmpeg_7;
      };
    } // lib.optionalAttrs prev.stdenv.isDarwin {
      # Runs ONLY on macOS
      alacritty = prev.alacritty.overrideAttrs (old: {
        postInstall =
          (old.postInstall or "")
          + ''
          cp ${../assets/alacritty.icns} $out/Applications/Alacritty.app/Contents/Resources/alacritty.icns
          '';
      });
    })
  ];

  # Fonts installed in system profile
  fonts.packages = with pkgs; [
    inter
    montserrat
    nerd-fonts.jetbrains-mono
    poppins
  ];

  # Add additional paths to link in the system profile for macOS
  environment.pathsToLink = lib.optionals pkgs.stdenv.isDarwin [
    "/share/terminfo"
  ];

  # Set system-specific configurations for macOS
  system = lib.mkIf pkgs.stdenv.isDarwin {
    # Set Git commit hash for darwin-version
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    # Used for backwards compatibility on nix-darwin
    stateVersion = 6;
    # Set the primary user for Homebrew prefix ownership
    primaryUser = "ayato";
  };

  # Hostname configurations separated per OS
  networking = lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isDarwin {
      hostName = "asgard";
      localHostName = "asgard";
      computerName = "asgard";
    })
    (lib.mkIf (!pkgs.stdenv.isDarwin) {
      hostName = "vanaheim";
      # localHostName = "vanaheim";
      # computerName = "vanaheim";
    })
  ];

  # nix settings for garbage collection, optimisation, and flake registry
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
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
    };
  };
}
