# Dotfiles

Personal dotfiles configuration for macOS development environment.

> [!NOTE]
> This setup is tailored for personal use and is not designed to be highly generic or configurable.

## Features

- **Zsh** - No framework; autosuggestions and syntax highlighting come from Homebrew plugins
- **Starship** - Cross-shell prompt with Git integration
- **Ghostty** - Fast terminal emulator
- **Mise** - Runtime version manager
- **Claude Code** - Settings, global CLAUDE.md and status line script

## Quick Setup

```bash
xcode-select --install   # git
git clone <your-repo-url> ~/dev/dotfiles
cd ~/dev/dotfiles
./setup.sh personal   # or: ./setup.sh work
```

## What the setup script does

1. Installs Homebrew and mise (if not present)
2. Links the mise config files and selects the profile (see below)
3. Runs `mise bootstrap`, which applies `mise/dotfiles.toml`:
   - installs the packages in `[bootstrap.packages]` and the tools in `[tools]`
   - sets zsh as the login shell
   - applies the macOS settings (Dock, Finder, keyboard, trackpad, screenshots)
   - links the configuration files to their proper locations

## Personal and work Macs

| File | Loaded on | Linked as |
| --- | --- | --- |
| `mise/dotfiles.toml` | every Mac | `~/.config/mise/conf.d/dotfiles.toml` |
| `mise/personal.toml` | personal Macs | `~/.config/mise/config.personal.toml` |
| `mise/work.toml` | work Macs (not created yet) | `~/.config/mise/config.work.toml` |

`~/.config/mise/miserc.local.toml` selects the profile on each Mac with `env = ["personal"]` or `env = ["work"]`. `setup.sh` writes it on the first run.

Tools you only want on one Mac go in `~/.config/mise/config.toml`, which is where `mise use -g` writes and is not part of this repository.

## Day-to-day

After changing `mise/dotfiles.toml` or pulling changes:

```bash
mise bootstrap --dry-run   # preview
mise bootstrap             # apply only what differs
mise bootstrap status      # compare the config with this machine
```

`mise dot apply` applies only the dotfiles. If a real file already exists where a link should go, mise stops instead of overwriting it. Check it with `mise dot diff`, then rerun with `--force` to replace it (the existing file is not backed up).

## Adding New Files

```bash
mise dot add ~/.vimrc --source ~/dev/dotfiles/vim/.vimrc --path ~/dev/dotfiles/mise/dotfiles.toml
```

This moves `~/.vimrc` into `vim/`, links it back, and adds the entry to `mise/dotfiles.toml`.
