#!/bin/sh

set -e

# shellcheck source=scripts/utils.sh
. "$HOME/dotfiles/scripts/utils.sh"

OS=""
CONFIG=""
IS_WSL=false

# 1. Clone the repo if it's run through curl install and the dotfiles directory doesn't exist
if [ ! -d "$HOME/dotfiles" ]; then
  git clone "https://github.com/Ayato-san/dotfiles.git" "$HOME/dotfiles"
fi

# 2. Determine the OS and set the appropriate configuration
case "$(uname -s)" in
Darwin*)
  OS="darwin"
  CONFIG="desktop"
  ;;
Linux*)
  if [ -f /proc/version ] && grep -qi "microsoft" /proc/version; then
    IS_WSL=true
  fi

  OS="linux"
  ;;
*)
  echo "Invalid OS"
  exit 1
  ;;
esac

# 3. Check if the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
  touch "$CONFIG_FILE"
fi

# 4. Set the OS and config values in the configuration file
set_toml_val "computer" "os" "$OS" "$CONFIG_FILE"
if [ "$OS" = "darwin" ]; then
  set_toml_val "computer" "config" "$CONFIG" "$CONFIG_FILE"
else
  echo "Select environment:"
  echo "1) server"
  echo "2) dev"
  echo "3) desktop"

  while true; do
    printf "Enter option [1-3]: "
    read -r choice
    case "$choice" in
    1 | server)
      CONFIG="server"
      break
      ;;
    2 | dev)
      CONFIG="dev"
      break
      ;;
    3 | desktop)
      CONFIG="desktop"
      break
      ;;
    *)
      echo "Invalid choice. Try again."
      exit 1
      ;;
    esac
  done

  set_toml_val "computer" "config" "$CONFIG" "$CONFIG_FILE"
fi

# 5. Install Nix package manager if not already installed
if [ ! -x "$(command -v nix)" ]; then
  echo "Installing Nix package manager..."
  # Install Nix package manager
  case "$OS" in
  "darwin")
    curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
    ;;
  "linux")
    curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon
    ;;
  esac
  if [ $IS_WSL ]; then
    set_toml_val "boot" "systemd" "true" "/etc/wsl.conf"
  fi
else
  echo "Nix is already installed."
fi

# 6. Run the update script to apply the configuration
case "$OS" in
"darwin")
  sudo nix run nix-darwin/master#darwin-rebuild --extra-experimental-features \
    "nix-command flakes" -- switch --flake "$HOME/dotfiles/.config/nix#$CONFIG-mac"
  ;;
"linux")
  sudo nixos-rebuild switch --flake "$HOME/dotfiles/.config/nix#$CONFIG"
  ;;
esac

# 7. Sync external resources based on the configuration file
last_phase "$CONFIG"
