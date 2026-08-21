{ pkgs, ... }: {
  environment.systemPackages = import ../packages/server.nix pkgs;
}
