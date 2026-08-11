# Configuring macOS with Nix and GNU Stow

## Installation

### Package manager installation

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

### Synchornize dotfiles with GNU Stow

```bash
stow .
```

### Tmux initialization

Once everything has been installed it's time to run TPM, install first:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then run `prefix + I`

### Retrieve alacritty themes

```bash
curl -LO --output-dir ~/.config/alacritty/themes https://github.com/catppuccin/alacritty/raw/main/catppuccin-macchiato.toml
```

## If any changes is done to `.config/nix/flake.nix` or want to update the system

```bash
nix flake update
sudo darwin-rebuild switch --flake ~/.config/nix#asgard
```
