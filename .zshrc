if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# load oh-my-posh if not using Apple Terminal
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"
fi

# Keybindings
# bindkey -M vicmd 'v' edit-command-line
bindkey '^f' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Edit command line
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# History
HISTSIZE=5000
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $real_path'

# Exported vars
export PATH="$PATH:/root/.local/bin"
export SSH_AUTH_SOCK="$HOME/.ssh/proton-pass-agent.sock"
export EDITOR='nvim'
export VISUAL='nvim'
export BAT_THEME='Catppuccin Macchiato'
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/blue.yml"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#363A4F,bg:#24273A,spinner:#F4DBD6,hl:#ED8796 \
--color=fg:#CAD3F5,header:#ED8796,info:#C6A0F6,pointer:#F4DBD6 \
--color=marker:#B7BDF8,fg+:#CAD3F5,prompt:#C6A0F6,hl+:#ED8796 \
--color=selected-bg:#494D64 \
--color=border:#6E738D,label:#CAD3F5"

# Command Variables
CMD_TREE='eza --icons --color=always --tree'
CMD_BAT='bat -n --color=always'

# Aliases
alias ls='eza --icons --color=always --git'
alias ll='ls -l'
alias l='ls -Al'
alias tree="$CMD_TREE"
alias c='clear'
alias k='kubectl'
alias bat="$CMD_BAT"

# Scripts aliases
alias sinstall="$HOME/dotfiles/scripts/install.sh"
alias supdate="$HOME/dotfiles/scripts/update.sh"

# Editor Aliases
alias nano='$EDITOR'
alias vim='$EDITOR'

# Suffix Aliases
alias -s md="bat"
alias -s mov="open"
alias -s png="open"
alias -s mp4="open"
alias -s js='$EDITOR'
alias -s ts='$EDITOR'
alias -s yaml="bat"
alias -s json="bat"

# Global Aliases
alias -g NE='2>/dev/null' # Redirect stderr to /dev/null
alias -g NO='>/dev/null' # Redirect stdout to /dev/null
alias -g NUL='>/dev/null 2>&1' # Redirect both stdout and stderr to /dev/null

# Hotkeys insert
bindkey -s '^Xgc' 'git commit -m ""\C-b' # git commit with cursor in message
bindkey -s '^Xgs' 'git status\n' # git status
bindkey -s '^Xgl' 'git log --oneline -n 10\n' # git log with last 10 commits

# FZF configuration
show_file_or_dir_preview="if [ -d {} ]; then $CMD_TREE {} | head -200; else $CMD_BAT --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview "$CMD_TREE {} | head -200" "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# Shell integrations
eval "$(fzf --zsh)"

# Custom functions
# Verify if the SSH agent is running
ssh_status() {
  pass-cli ssh-agent daemon status | sed -n '1p'
}
# Stop the SSH agent
ssh_stop() {
  pass-cli ssh-agent daemon stop | sed -n '1p'
}
# Start the SSH agent for Home Cloud
ssh_start_homecloud() {
  pass-cli ssh-agent daemon start --vault-name 'Home Cloud' | sed -n '1p'
}
