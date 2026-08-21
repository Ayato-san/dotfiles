{ pkgs, ... }: {
  home.packages = import ../packages/server.nix pkgs;
}
