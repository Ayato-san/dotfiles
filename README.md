# Dotfiles

This repo contains my dotfile configuration, allowing for a consistent computing
experience across multiple machines/OS.

## Installation

<!-- markdownlint-disable MD033 -->
<details open>
<summary>Remote installation</summary>

Run the following command to install the dotfiles directly from the repository:

<!-- markdownlint-disable MD013 -->
```bash
curl -L "https://raw.githubusercontent.com/Ayato-san/dotfiles/refs/heads/main/scripts/install.sh" | bash
```
<!-- markdownlint-enable MD013 -->
</details>

<details>
<summary>Manual installation</summary>

clone the repo and run the following commands:

```bash
git clone https://github.com/Ayato-san/dotfiles.git ~/dotfiles
```

then run the installation script:

```bash
~/dotfiles/scripts/install.sh
```

</details>
<!-- markdownlint-enable MD033 -->

> [!NOTE]
> If tmux plugin manager is not installed, you can run `prefix + I`

## Update

For updating the dotfiles, you can run the following command:

```bash
supdate
```

> [!NOTE]
> If you want to force the tmux plugin updating, you can run `prefix + U`

## Inspiration

The inspiration for this configuration comes from the [dotfiles by elliottminns](https://github.com/elliottminns/dotfiles).
I'd suggest watching his videos ([@dreamsofcode](https://youtube.com/@dreamsofcode),
[@dreamsofautonomy](https://youtube.com/@dreamsofautonomy)).
