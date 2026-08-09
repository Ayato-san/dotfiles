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
bindkey '^X^E' edit-command-line 

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
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

# Aliases
alias ls='eza --icons --color --git'
alias ll='ls -l'
alias l='ls -Al'
alias tree='eza --icons --tree'
alias c='clear'

# Editor Aliases
alias nano='$EDITOR'
alias vim='$EDITOR'
alias nvim='$EDITOR'

# Suffix Aliases
alias -s js='$EDITOR'
alias -s ts='$EDITOR'

# Global Aliases
alias -g NE='2>/dev/null' # Redirect stderr to /dev/null
alias -g NO='>/dev/null' # Redirect stdout to /dev/null
alias -g NUL='>/dev/null 2>&1' # Redirect both stdout and stderr to /dev/null

# Hotkeys insert
bindkey -s '^Xgc' 'git commit -m ""\C-b' # git commit with cursor in message
bindkey -s '^Xgs' 'git status\n' # git status
bindkey -s '^Xgl' 'git log --oneline -n 10\n' # git log with last 10 commits

# Shell integrations
eval "$(fzf --zsh)"
