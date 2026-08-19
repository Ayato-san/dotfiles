#!/bin/sh

set -eu

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
CONFIG_FILE="${CONFIG_FILE:-$DOTFILES_DIR/conf.toml}"

# shellcheck source=scripts/utils.sh
. "$DOTFILES_DIR/scripts/utils.sh"

# 1. Check if the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Configuration file '$CONFIG_FILE' not found." >&2
  exit 1
fi

# 2. Extract values under the [computer] section using awk
OS=$(get_toml_val "computer" "os")
CONFIG=$(get_toml_val "computer" "config")

# 3. Validate os ("darwin" or "linux")
case "$OS" in
darwin | linux) ;;
*)
  echo "Error: Invalid computer.os '$OS'. Must be 'darwin' or 'linux'." >&2
  exit 1
  ;;
esac

# 4. Validate config ("server", "dev", or "desktop")
case "$CONFIG" in
server | dev | desktop) ;;
*)
  echo "Error: Invalid computer.config '$CONFIG'. Must be 'server', 'dev', or 'desktop'." >&2
  exit 1
  ;;
esac

# 5. Pull the latest changes from the dotfiles repository
git -C "$DOTFILES_DIR" pull --ff-only || {
  echo "Error: Failed to pull latest changes from the dotfiles repository." >&2
  exit 1
}

# 6. Update the nix flake configuration based on the OS and config values
case "$OS" in
darwin)
  sudo darwin-rebuild switch --flake "$DOTFILES_DIR/.config/nix#$CONFIG-mac"
  ;;
linux)
  sudo nixos-rebuild switch --flake "$DOTFILES_DIR/.config/nix#$CONFIG"
  ;;
esac

# 7. Sync external resources based on the configuration file
last_phase "$CONFIG"
