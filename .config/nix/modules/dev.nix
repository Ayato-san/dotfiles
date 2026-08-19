{ pkgs, ... }: {
  imports = [ 
    ./server.nix # Pulls all Server packages automatically
    ./nvim.nix # Pulls all NeoVim packages automatically
  ];

  environment.systemPackages = with pkgs; [
    ansible
    bat
    codex
    eza
    gh
    kubectl
    proton-pass-cli
    tealdeer
    terraform
    yarn-berry
  ];

  nixpkgs.config.allowUnfreePredicate = pkg : builtins.elem (pkgs.lib.getName pkg) [
    "terraform"
  ];
}
