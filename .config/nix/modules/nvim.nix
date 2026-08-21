{ pkgs, ... }: {
  environment.systemPackages = import ../packages/nvim.nix pkgs;
}
