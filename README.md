# Dotfiles

This repository contains my personal dotfiles and Nix package configurations for
Apple Silicon macOS, NixOS, and x86-64 Debian, Fedora, and Arch Linux machines.

> [!IMPORTANT]
> The Nix configuration contains machine-specific values, including my username
> and hostnames. Review and adapt it before installing it on another machine.

## Installation

<!-- markdownlint-disable MD033 -->
<details open>
<summary>Remote installation</summary>

The installer requires `git`, `curl`, `sudo`, and `xz`. To download and run it directly:

<!-- markdownlint-disable MD013 -->
```bash
curl -fsSL "https://raw.githubusercontent.com/Ayato-san/dotfiles/refs/heads/main/scripts/install.sh" | sh
```
<!-- markdownlint-enable MD013 -->
</details>

<details>
<summary>Manual installation</summary>

Clone the repository:

```bash
git clone https://github.com/Ayato-san/dotfiles.git ~/dotfiles
```

Then run the installation script:

```bash
~/dotfiles/scripts/install.sh
```

</details>
<!-- markdownlint-enable MD033 -->

The installer installs Nix when necessary, links the dotfiles with GNU Stow, and
synchronizes the tmux plugins. On Linux, it prompts you to choose the `server`,
`dev`, or `desktop` configuration. NixOS uses the corresponding system
configuration; Debian, Fedora, and Arch use the standalone Home Manager
configuration. macOS uses `desktop`.

For the `dev` and `desktop` configurations, installation checks the GitHub CLI
authentication status and starts `gh auth login` when authentication is needed.

> [!IMPORTANT]
> To enable GitHub Copilot suggestions in Neovim, open Neovim and run
> `:LspCopilotSignIn` once.

<!-- Separate the adjacent GitHub alerts for markdownlint MD028. -->

> [!NOTE]
> Inside tmux, press `prefix + I` to install any configured plugins that are
> missing. TPM itself is installed by the installation script.

## Update

After installation, open a new Zsh session and run:

```bash
supdate
```

The update also checks the GitHub CLI authentication status and starts
`gh auth login` when necessary on `dev` and `desktop` configurations.

> [!NOTE]
> Inside tmux, press `prefix + U` to update the installed tmux plugins manually.

## Inspiration

The inspiration for this configuration comes from the [dotfiles by elliottminns](https://github.com/elliottminns/dotfiles).
I'd suggest watching his videos ([@dreamsofcode](https://youtube.com/@dreamsofcode),
[@dreamsofautonomy](https://youtube.com/@dreamsofautonomy)).
