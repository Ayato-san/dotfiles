#!/bin/sh

set -eu

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
CONFIG_FILE="${CONFIG_FILE:-$DOTFILES_DIR/conf.toml}"

OS=""
CONFIG=""
IS_WSL=false
IS_NIXOS=false

# 1. Verify required commands
command -v git >/dev/null 2>&1 || {
  echo "Error: git is required to install these dotfiles." >&2
  exit 1
}
command -v xz >/dev/null 2>&1 || {
  echo "Error: xz is required to install these dotfiles." >&2
  exit 1
}

# 2. Clone the repo if it's run through curl install and the dotfiles directory doesn't exist
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  if [ -e "$DOTFILES_DIR" ]; then
    echo "Error: '$DOTFILES_DIR' exists but is not a Git repository." >&2
    exit 1
  fi
  git clone "https://github.com/Ayato-san/dotfiles.git" "$DOTFILES_DIR"
fi

# shellcheck source=scripts/utils.sh
. "$DOTFILES_DIR/scripts/utils.sh"

# 3. Determine the OS and set the appropriate configuration
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
  if [ -e /etc/NIXOS ]; then
    IS_NIXOS=true
  elif [ -r /etc/os-release ]; then
    # Standalone Home Manager is intentionally supported on these distributions.
    # shellcheck source=/dev/null
    . /etc/os-release
    case "$ID" in
    debian | fedora | arch) ;;
    *)
      echo "Error: Unsupported Linux distribution '$ID'. Expected Debian, Fedora, Arch, or NixOS." >&2
      exit 1
      ;;
    esac
  fi
  ;;
*)
  echo "Error: Unsupported operating system: $(uname -s)" >&2
  exit 1
  ;;
esac

# 4. Check if the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
  touch "$CONFIG_FILE"
fi

# 5. Set the OS and config values in the configuration file
set_toml_val "computer" "os" "$OS" "$CONFIG_FILE"
if [ "$OS" = "darwin" ]; then
  set_toml_val "computer" "config" "$CONFIG" "$CONFIG_FILE"
else
  if ! exec 3</dev/tty; then
    echo "Error: A terminal is required to select the Linux environment." >&2
    echo "Run this installer from an interactive terminal." >&2
    exit 1
  fi

  echo "Select environment:"
  echo "1) server"
  echo "2) dev"
  echo "3) desktop"

  while true; do
    printf "Enter option [1-3]: "
    read -r choice <&3
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

# 6. Install Nix package manager if not already installed
if ! command -v nix >/dev/null 2>&1; then
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
  if [ "$IS_WSL" = true ]; then
    echo "WSL detected. Enable systemd in /etc/wsl.conf if it is not already enabled."
    set_toml_val "boot" "systemd" "true" "/etc/wsl.conf"
  fi
else
  echo "Nix is already installed."
fi

# 7. Run the update script to apply the configuration
NIX_BIN="$(command -v nix)"
# Home Manager invokes Nix again internally, so make the flake features available
# to child processes as well as to the initial `nix run` command.
NIX_CONFIG="${NIX_CONFIG:+$NIX_CONFIG
}extra-experimental-features = nix-command flakes"
export NIX_CONFIG

case "$OS" in
"darwin")
  sudo "$NIX_BIN" --extra-experimental-features "nix-command flakes" \
    run nix-darwin/master#darwin-rebuild -- switch \
    --flake "$DOTFILES_DIR/.config/nix#$CONFIG-mac"
  ;;
"linux")
  if [ "$IS_NIXOS" = true ]; then
    sudo "$NIX_BIN" --extra-experimental-features "nix-command flakes" \
      run nixpkgs#nixos-rebuild -- switch \
      --flake "$DOTFILES_DIR/.config/nix#$CONFIG"
  else
    "$NIX_BIN" --extra-experimental-features "nix-command flakes" \
      run "$DOTFILES_DIR/.config/nix#home-manager" -- switch \
      --flake "$DOTFILES_DIR/.config/nix#ayato@$CONFIG"
  fi
  ;;
esac

# 8. Sync external resources based on the configuration file
last_phase "$CONFIG"

# 9. Set Zsh as the user's default login shell
if [ -x "$HOME/.nix-profile/bin/zsh" ]; then
  ZSH_BIN="$HOME/.nix-profile/bin/zsh"
else
  ZSH_BIN="$(command -v zsh || true)"
fi

if [ -z "$ZSH_BIN" ]; then
  echo "Error: zsh was installed but could not be found." >&2
  exit 1
fi

if ! grep -qxF "$ZSH_BIN" /etc/shells; then
  sudo sh -c 'printf "%s\n" "$1" >> /etc/shells' sh "$ZSH_BIN"
fi

if [ "${SHELL:-}" != "$ZSH_BIN" ]; then
  echo "Changing the default shell to $ZSH_BIN..."
  chsh -s "$ZSH_BIN" </dev/tty
fi
