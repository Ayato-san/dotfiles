{ pkgs, ... }: {
  imports = [ ./server.nix ];

  home.packages = (import ../packages/nvim.nix pkgs) ++ (import ../packages/dev.nix pkgs);
}
