#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Usage: ./setup.sh personal|work
PROFILE="${1:-}"
if [[ "$PROFILE" != "personal" && "$PROFILE" != "work" ]]; then
    echo "Usage: $0 personal|work" >&2
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$SCRIPT_DIR"

log_info "Starting dotfiles setup..."
log_info "Dotfiles directory: $DOTFILES_ROOT"

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    log_error "This script is designed for macOS only."
    exit 1
fi

# mise/dotfiles.toml links files from ~/dev/dotfiles
if [[ "$DOTFILES_ROOT" != "$HOME/dev/dotfiles" ]]; then
    log_error "Clone this repository to ~/dev/dotfiles and rerun."
    exit 1
fi

# Select which mise/<profile>.toml this Mac loads
miserc="$HOME/.config/mise/miserc.local.toml"
if [[ -e "$miserc" ]]; then
    if ! grep -q "\"$PROFILE\"" "$miserc"; then
        log_error "$miserc selects another profile. Add \"$PROFILE\" to its env list or pass the right profile."
        exit 1
    fi
else
    mkdir -p "$(dirname "$miserc")"
    echo "env = [\"$PROFILE\"]" > "$miserc"
    log_success "Selected the $PROFILE profile in $miserc"
fi

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    log_success "Homebrew installed successfully"
else
    log_success "Homebrew is already installed"
fi

# Install mise
if command -v mise &> /dev/null; then
    MISE="$(command -v mise)"
    log_success "mise is already installed"
else
    log_info "Installing mise..."
    curl -fsSL https://mise.run | sh
    MISE="$HOME/.local/bin/mise"
    log_success "mise installed"
fi

# Link a file in this repository into mise's global config directory
link_mise_config() {
    local source="$1" link="$2"
    mkdir -p "$(dirname "$link")"
    if [[ -e "$link" && ! -L "$link" ]]; then
        log_error "$link already exists and is not a symlink. Move it aside and rerun."
        exit 1
    fi
    ln -sfn "$source" "$link"
    log_success "Linked $link"
}

link_mise_config "$DOTFILES_ROOT/mise/dotfiles.toml" "$HOME/.config/mise/conf.d/dotfiles.toml"

if [[ -f "$DOTFILES_ROOT/mise/$PROFILE.toml" ]]; then
    link_mise_config "$DOTFILES_ROOT/mise/$PROFILE.toml" "$HOME/.config/mise/config.$PROFILE.toml"
else
    log_warning "mise/$PROFILE.toml does not exist yet. Only the shared config is applied."
fi

# Apply packages, tools, login shell and dotfiles
log_info "Running mise bootstrap..."
"$MISE" bootstrap

echo ""
log_success "🎉 Setup completed successfully!"
echo ""
log_info "Next steps:"
echo "  1. Restart your terminal or run 'exec fish'"
echo "  2. Check the state with 'mise bootstrap status'"
echo ""
