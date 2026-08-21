{ pkgs, ... }: {
  imports = [ 
    ./server.nix # Pulls all Server packages automatically
    ./nvim.nix # Pulls all NeoVim packages automatically
  ];

  environment.systemPackages = import ../packages/dev.nix pkgs;

  nixpkgs.config.allowUnfreePredicate = pkg : builtins.elem (pkgs.lib.getName pkg) [
    "terraform"
  ];
}
