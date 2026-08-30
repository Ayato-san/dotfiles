#!/bin/sh

# Variables
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
CONFIG_FILE="${CONFIG_FILE:-$DOTFILES_DIR/conf.toml}"

# Extract a value from a TOML file given a section and variable name
get_toml_val() {
  _section="$1"
  _varname="$2"
  _file="${3:-$CONFIG_FILE}"

  if [ ! -f "$_file" ]; then
    echo ""
    return
  fi

  awk -F '=' -v sec="$_section" -v key="$_varname" '
    /^\[/ {
      current_sec = $0
      gsub(/^\[|[[:space:]]|\].*$/, "", current_sec)
      in_sec = (current_sec == sec)
      next
    }
    in_sec && $1 ~ "^[[:space:]]*" key "[[:space:]]*$" {
      val = $2
      gsub(/[[:space:]"'\''\r]/, "", val)
      print val
      found = 1
      exit
    }
    END {
      if (!found) print ""
    }
  ' "$_file"
}

# Set a value in a TOML file given a section and variable name
set_toml_val() {
  _section="$1"
  _varname="$2"
  _value="$3"
  _file="${4:-$CONFIG_FILE}"

  if [ ! -f "$_file" ]; then
    echo "Error: File '$_file' not found." >&2
    return 1
  fi

  _tmp_file="${_file}.tmp"

  awk -F '=' -v sec="$_section" -v key="$_varname" -v val="$_value" '
    BEGIN {
      sec_header = "[" sec "]"
      in_sec = 0
      sec_found = 0
      key_found = 0
    }
    /^\[/ {
      current_sec = $0
      gsub(/^\[|[[:space:]]|\].*$/, "", current_sec)
      if (in_sec && !key_found) {
        print key " = \"" val "\""
        key_found = 1
      }
      in_sec = (current_sec == sec)
      if (in_sec) sec_found = 1
    }
    in_sec && $1 ~ "^[[:space:]]*" key "[[:space:]]*$" {
      print key " = \"" val "\""
      key_found = 1
      next
    }
    { print $0 }
    END {
      if (in_sec && !key_found) {
        print key " = \"" val "\""
        key_found = 1
      }
      if (!sec_found) {
        if (NR > 0) print ""
        print sec_header
        print key " = \"" val "\""
      }
    }
  ' "$_file" >"$_tmp_file" && mv "$_tmp_file" "$_file"
}

# Set a top-level TOML value while preserving all app-managed sections.
set_root_toml_val() {
  _varname="$1"
  _value="$2"
  _file="$3"
  _tmp_file=$(mktemp "${_file}.tmp.XXXXXX") || return 1

  awk -F '=' -v key="$_varname" -v val="$_value" '
    BEGIN {
      in_root = 1
      key_found = 0
    }
    /^\[/ {
      if (in_root && !key_found) {
        print key " = " val
        key_found = 1
      }
      in_root = 0
    }
    in_root && $1 ~ "^[[:space:]]*" key "[[:space:]]*$" {
      print key " = " val
      key_found = 1
      next
    }
    { print $0 }
    END {
      if (!key_found) print key " = " val
    }
  ' "$_file" >"$_tmp_file" && chmod 600 "$_tmp_file" && mv "$_tmp_file" "$_file"
}

# Set a raw TOML value in a section while preserving all other settings.
set_section_toml_val() {
  _section="$1"
  _varname="$2"
  _value="$3"
  _file="$4"
  _tmp_file=$(mktemp "${_file}.tmp.XXXXXX") || return 1

  awk -F '=' -v sec="$_section" -v key="$_varname" -v val="$_value" '
    BEGIN {
      in_sec = 0
      sec_found = 0
      key_found = 0
    }
    /^\[/ {
      if (in_sec && !key_found) {
        print key " = " val
        key_found = 1
      }
      current_sec = $0
      gsub(/^\[|[[:space:]]|\].*$/, "", current_sec)
      in_sec = (current_sec == sec)
      if (in_sec) sec_found = 1
    }
    in_sec && $1 ~ "^[[:space:]]*" key "[[:space:]]*$" {
      print key " = " val
      key_found = 1
      next
    }
    { print $0 }
    END {
      if (in_sec && !key_found) print key " = " val
      if (!sec_found) {
        if (NR > 0) print ""
        print "[" sec "]"
        print key " = " val
      }
    }
  ' "$_file" >"$_tmp_file" && chmod 600 "$_tmp_file" && mv "$_tmp_file" "$_file"
}

# Merge portable Codex defaults without tracking its machine-local config.toml.
sync_codex_defaults() {
  _defaults_file="$DOTFILES_DIR/.codex/config.defaults.toml"
  _codex_dir="${CODEX_HOME:-$HOME/.codex}"
  _codex_config="$_codex_dir/config.toml"

  [ -f "$_defaults_file" ] || return 0
  mkdir -p "$_codex_dir"
  if [ ! -f "$_codex_config" ]; then
    : >"$_codex_config"
    chmod 600 "$_codex_config"
  fi

  for _key in model model_reasoning_effort service_tier; do
    _value=$(awk -F '=' -v key="$_key" '
      /^\[/ { exit }
      $1 ~ "^[[:space:]]*" key "[[:space:]]*$" {
        value = substr($0, index($0, "=") + 1)
        sub(/^[[:space:]]*/, "", value)
        sub(/[[:space:]]*$/, "", value)
        print value
        exit
      }
    ' "$_defaults_file")
    if [ -n "$_value" ]; then
      set_root_toml_val "$_key" "$_value" "$_codex_config"
    fi
  done

  for _key in status_line status_line_use_colors; do
    _value=$(awk -F '=' -v key="$_key" '
      /^\[/ {
        section = $0
        gsub(/^\[|[[:space:]]|\].*$/, "", section)
        in_tui = (section == "tui")
        next
      }
      in_tui && $1 ~ "^[[:space:]]*" key "[[:space:]]*$" {
        value = substr($0, index($0, "=") + 1)
        sub(/^[[:space:]]*/, "", value)
        sub(/[[:space:]]*$/, "", value)
        print value
        exit
      }
    ' "$_defaults_file")
    if [ -n "$_value" ]; then
      set_section_toml_val "tui" "$_key" "$_value" "$_codex_config"
    fi
  done
}

# Ensure the GitHub CLI is authenticated after it has been installed by Nix.
ensure_gh_auth() {
  if ! command -v gh >/dev/null 2>&1; then
    echo "Error: GitHub CLI was not found after applying the configuration." >&2
    return 1
  fi

  if gh auth status >/dev/null 2>&1; then
    echo "GitHub CLI is already authenticated."
    return 0
  fi

  echo "GitHub CLI is not authenticated. Starting login..."
  if ! exec 3</dev/tty; then
    echo "Error: A terminal is required to authenticate GitHub CLI." >&2
    return 1
  fi

  gh auth login <&3
  exec 3<&-
}

# Retrieve the latest commit SHA from the GitHub API for a specific repository
fetch_github_sha() {
  _url="$1"

  if [ -z "$_url" ]; then
    echo "Error: No URL provided to fetch_github_sha" >&2
    exit 1
  fi

  if command -v jq >/dev/null 2>&1; then
    _sha=$(curl -fsSL -H "Accept: application/vnd.github+json" -H "User-Agent: dotfiles-updater" "$_url" | jq -r '.[0].sha' 2>/dev/null)
  else
    # Fallback extraction without jq
    _sha=$(curl -fsSL -H "Accept: application/vnd.github+json" -H "User-Agent: dotfiles-updater" "$_url" | grep -m 1 '"sha":' | cut -d '"' -f 4)
  fi

  if [ -z "$_sha" ] || [ "$_sha" = "null" ]; then
    echo "Error: Failed to fetch commit SHA from GitHub API ($_url)." >&2
    exit 1
  fi

  echo "$_sha"
}

# Synchronize an external resource by comparing local and remote SHAs, downloading if necessary, and updating the TOML configuration
sync_external_resource() {
  _api_url="$1"
  _name="$2"
  _key="$3"
  _curl_dest="$4"
  _curl_url="$5"

  # Fetch remote SHA (fails early if fetch_github_sha returns error)
  _tmp_sha=$(fetch_github_sha "$_api_url") || exit 1
  _local_sha=$(get_toml_val "external" "$_key")

  if [ "$_local_sha" = "$_tmp_sha" ]; then
    echo "$_name is up to date"
  else
    echo "Updating $_name..."

    # Download atomically so a failed request cannot corrupt the current asset.
    _dest_dir=${_curl_dest%/*}
    mkdir -p "$_dest_dir"
    _download_tmp=$(mktemp "${_curl_dest}.tmp.XXXXXX") || {
      echo "Error: Could not create a temporary file for $_name." >&2
      exit 1
    }
    if curl -fsSL "$_curl_url" -o "$_download_tmp" && mv "$_download_tmp" "$_curl_dest"; then
      set_toml_val "external" "$_key" "$_tmp_sha" "$CONFIG_FILE"
    else
      rm -f "$_download_tmp"
      echo "Error: Failed to download asset for $_name from $_curl_url" >&2
      exit 1
    fi
  fi
}

last_phase() {
  _config="$1"

  # 1. Sync external resources based on the configuration file
  "$DOTFILES_DIR/scripts/update-mattpocock-skills.sh"

  if [ "$_config" = "desktop" ]; then # Run ONLY for desktop config
    sync_external_resource "https://api.github.com/repos/catppuccin/alacritty/commits?per_page=1" \
      "catppuccin/alacritty" "catppuccin-alacritty" \
      "$HOME/.config/alacritty/themes/catppuccin-macchiato.toml" \
      "https://github.com/catppuccin/alacritty/raw/main/catppuccin-macchiato.toml"
  fi
  if [ "$_config" = "desktop" ] || [ "$_config" = "dev" ]; then # Run for desktop and dev config
    sync_external_resource "https://api.github.com/repos/catppuccin/bat/commits?per_page=1" \
      "catppuccin/bat" "catppuccin-bat" \
      "$(bat --config-dir)/themes/Catppuccin Macchiato.tmTheme" \
      "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme"
    sync_external_resource "https://api.github.com/repos/catppuccin/delta/commits?per_page=1" \
      "catppuccin/delta" "catppuccin-delta" \
      "$HOME/.config/delta/themes/catppuccin.gitconfig" \
      "https://github.com/catppuccin/delta/raw/main/catppuccin.gitconfig"
    sync_external_resource "https://api.github.com/repos/catppuccin/lazygit/commits?per_page=1" \
      "catppuccin/lazygit" "catppuccin-lazygit" \
      "$HOME/.config/lazygit/blue.yml" \
      "https://github.com/catppuccin/lazygit/raw/main/themes-mergable/macchiato/blue.yml"
  fi
  # if [ "$CONFIG" = "desktop" ] || [ "$CONFIG" = "dev" ] || [ "$CONFIG" = "server" ]; then # Run for all configs
  # fi

  # 2. Stow the dotfiles
  cd "$DOTFILES_DIR" || return
  echo "Resyncing dotfiles..."
  mkdir -p "$HOME/.codex"
  mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
  stow .

  # 3. Apply portable Codex defaults without replacing its app-managed config.
  sync_codex_defaults

  # 4. Authenticate GitHub CLI where it is part of the selected configuration.
  if [ "$_config" = "desktop" ] || [ "$_config" = "dev" ]; then
    ensure_gh_auth
  fi

  # 5. Configure Codex MCP servers without replacing its app-managed config.
  if [ "$_config" = "desktop" ] || [ "$_config" = "dev" ]; then
    if command -v codex >/dev/null 2>&1; then
      if codex mcp get context7 >/dev/null 2>&1; then
        echo "Context7 MCP is already configured."
      else
        echo "Configuring Context7 MCP..."
        codex mcp add context7 --url "https://mcp.context7.com/mcp"
      fi
    fi
  fi

  # 6. Update tpm (Tmux Plugin Manager)
  if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Pulling latest changes for tpm..."
    git -C "$HOME/.tmux/plugins/tpm" pull
  else
    echo "Cloning tpm repository..."
    mkdir -p "$HOME/.tmux/plugins"
    git clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
  fi

  # 7. Run install/update/clean of tpm
  SCRIPTS_DIR="$HOME/.tmux/plugins/tpm/scripts"
  HELPERS_DIR="$SCRIPTS_DIR/helpers"
  "$SCRIPTS_DIR/install_plugins.sh" --tmux-echo >/dev/null 2>&1
  "$SCRIPTS_DIR/update_plugins.sh" --tmux-echo >/dev/null 2>&1
  "$SCRIPTS_DIR/clean_plugins.sh" --tmux-echo >/dev/null 2>&1
  # shellcheck source=/dev/null
  . "$HELPERS_DIR/tmux_utils.sh"
  reload_tmux_environment
}
