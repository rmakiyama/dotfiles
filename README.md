# Dotfiles

Personal dotfiles configuration for macOS development environment.

> [!NOTE]
> This setup is tailored for personal use and is not designed to be highly generic or configurable.

## Features

- **Fish Shell** - Modern shell with autocompletions and syntax highlighting
- **Starship** - Cross-shell prompt with Git integration
- **Ghostty** - Fast terminal emulator
- **Mise** - Runtime version manager

## Quick Setup

```bash
git clone <your-repo-url> ~/dev/dotfiles
cd ~/dev/dotfiles
# If you cloned to a different path, update DOTFILES_ROOT in fish/config.fish first
chmod +x setup.sh
./setup.sh
```

## What the setup script does

1. Installs Homebrew (if not present)
2. Installs required tools: fish, starship, mise, ghostty, etc...
3. Sets fish as the default shell
4. Deploys configuration files to their proper locations

## Manual Deployment

If you need to redeploy configurations after making changes:

```fish
dotdeploy
```

This creates symlinks based on `manifest.tsv`. Existing files are backed up as `.bak` files, and existing symlinks are skipped.

## Adding New Files

```fish
dotlink ~/.vimrc vim
```

This moves `~/.vimrc` to `vim/` directory, creates a symlink, and updates `manifest.tsv`.
