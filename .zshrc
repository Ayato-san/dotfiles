export PATH="$PATH:/root/.local/bin"
export SSH_AUTH_SOCK="$HOME/.ssh/proton-pass-agent.sock"

eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

# Aliases
alias ls='ls --color'
alias ll='ls -l'
alias l='ls -Al'
