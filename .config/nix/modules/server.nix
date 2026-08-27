{ pkgs, ... }: {
  environment.systemPackages = import ../packages/server.nix pkgs;

  time.timeZone = "Europe/Paris";
}
