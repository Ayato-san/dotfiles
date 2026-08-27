{ pkgs, ... }: {
  home.packages = import ../packages/server.nix pkgs;

  # Standalone Home Manager cannot change the system timezone (for example on WSL),
  # so expose it to the user's session instead.
  home.sessionVariables.TZ = "Europe/Paris";
}
