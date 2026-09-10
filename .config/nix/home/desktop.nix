{ pkgs, ... }: {
  imports = [ ./dev.nix ];

  home.packages = import ../packages/desktop.nix pkgs;

  # Home Manager creates a systemd user service on standalone Linux desktops.
  services.syncthing.enable = true;
}
