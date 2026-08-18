{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    curl
    fd
    fzf
    git
    gzip
    htop
    oh-my-posh
    ripgrep
    stow
    tmux
    unzip
    wget
    zsh
  ];
}
