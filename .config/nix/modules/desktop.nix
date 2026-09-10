{
  pkgs,
  lib,
  inputs,
  isDarwin,
  ...
}:
{
  imports = [ ./dev.nix ]; # Pulls all Dev packages automatically

  # 1. Native Nix GUI apps available on both Linux and macOS
  environment.systemPackages =
    with pkgs;
    [
      alacritty
      ffmpeg
      imagemagick
      localsend
      moonlight-qt
      obsidian
      proton-vpn
      spotify
      syncthing
    ]

    # 2. Linux-only GUI applications (installed via Nix)
    ++ lib.optionals (!isDarwin) [
      discord
      kicad
      orca-slicer
      steam
    ]

    # Notion's nixpkgs package currently supports Apple Silicon only.
    ++ lib.optionals isDarwin [
      notion-app
    ];

  # 3. Allow unfree packages for specific applications
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "notion-app"
      "obsidian"
      "spotify"
      "steam"
      "terraform"
    ];

  # 4. Override specific packages with custom configurations
  nixpkgs.overlays = [
    (
      final: prev:
      {
        # Runs on all platforms (Linux & macOS)
        # moonlight-qt = prev.moonlight-qt.override {
        #   ffmpeg = prev.ffmpeg_8;
        # };
      }
      // lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
        # Runs ONLY on macOS
        alacritty = prev.alacritty.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            cp ${../assets/alacritty.icns} $out/Applications/Alacritty.app/Contents/Resources/alacritty.icns
          '';
        });
      }
    )
  ];

  # 5. Fonts installed in system profile
  fonts.packages = with pkgs; [
    inter
    montserrat
    nerd-fonts.jetbrains-mono
    poppins
  ];

  # 6. Add additional paths to link in the system profile for macOS
  environment.pathsToLink = lib.optionals isDarwin [
    "/share/terminfo"
  ];

  # 7. nix settings for garbage collection, optimisation, and flake registry
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    }
    // lib.optionalAttrs isDarwin {
      interval = {
        Hour = 3;
        Minute = 15;
        Weekday = 7;
      };
    }
    // lib.optionalAttrs (!isDarwin) {
      dates = "weekly";
    };
    optimise.automatic = true;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
    };
  };
}
// lib.optionalAttrs isDarwin {
  # macOS-only GUI applications installed via Homebrew Casks.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    brews = [ ];
    casks = [
      "discord"
      "docker-desktop"
      "kicad"
      "orcaslicer"
      "proton-mail"
      "proton-drive"
      "steam"
      "zen"
    ];
  };

  # Start Syncthing for the desktop user at login.
  launchd.user.agents.syncthing.serviceConfig = {
    ProgramArguments = [
      "${pkgs.syncthing}/bin/syncthing"
      "serve"
      "--no-browser"
      "--no-restart"
      "--no-upgrade"
    ];
    KeepAlive = {
      Crashed = true;
      SuccessfulExit = false;
    };
    ProcessType = "Background";
    RunAtLoad = true;
  };

  system = {
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    stateVersion = 6;
    primaryUser = "ayato";
    defaults = {
      dock = {
        autohide = true;
        show-recents = false;
        mru-spaces = false;
      };
      finder = {
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "clmv";
        FXRemoveOldTrashItems = true;
      };
      loginwindow.LoginwindowText = "asgard";
      screencapture.location = "~/Pictures/screenshots";
    };
  };

  networking = {
    hostName = "asgard";
    localHostName = "asgard";
    computerName = "asgard";
  };
}
// lib.optionalAttrs (!isDarwin) {
  # Start Syncthing as a systemd service on NixOS desktops.
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
  };

  networking.hostName = "vanaheim";
}
