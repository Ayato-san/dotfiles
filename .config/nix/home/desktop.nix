{ pkgs, ... }: {
  imports = [ ./dev.nix ];

  home.packages = import ../packages/desktop.nix pkgs;
}
