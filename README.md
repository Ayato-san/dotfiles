# Configuring macOS with Nix and GNU Stow

## Package manager installation

```bash
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
```

```bash
nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"
```

```bash
sudo nix run nix-darwin/master#darwin-rebuild --extra-experimental-features \
    "nix-command flakes" -- switch --flake ~/dotfiles/.config/nix#asgard
```

then restart your terminal to make the command `darwin-rebuild` available.

## Synchornize dotfiles with GNU Stow

```bash
stow .
```

## Retrieve alacritty themes

```bash
curl -LO --output-dir ~/.config/alacritty/themes https://github.com/catppuccin/alacritty/raw/main/catppuccin-macchiato.toml
```

## If any changes is done to `.config/nix/flake.nix`

```bash
sudo darwin-rebuild switch --flake ~/.config/nix#asgard
```

