{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    ast-grep
    delta
    lazygit
    luarocks
    neovim
    nodejs
    python3
    rust-analyzer
    rustup
  ];
}
