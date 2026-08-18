#!/bin/sh

set -e

# shellcheck source=scripts/utils.sh
. "$HOME/dotfiles/scripts/utils.sh"

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

# 5. Update the nix flake configuration based on the OS and config values
case "$OS" in
darwin)
  sudo darwin-rebuild switch --flake "$HOME/.config/nix#$CONFIG-mac"
  ;;
linux)
  sudo nixos-rebuild switch --flake "$HOME/.config/nix#$CONFIG"
  ;;
esac

# 6. Sync external resources based on the configuration file
last_phase "$CONFIG"
