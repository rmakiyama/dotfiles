#!/bin/bash

set -e

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

# Install required tools
log_info "Installing required tools..."

tools=("fish" "starship" "mise")
for tool in "${tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        log_info "Installing $tool..."
        brew install "$tool"
        log_success "$tool installed"
    else
        log_success "$tool is already installed"
    fi
done

# Install ghostty if not present
if ! command -v ghostty &> /dev/null; then
    log_info "Installing ghostty..."
    if brew list --cask ghostty &> /dev/null; then
        log_success "ghostty is already installed"
    else
        brew install --cask ghostty
        log_success "ghostty installed"
    fi
else
    log_success "ghostty is already installed"
fi

# Add fish to valid login shells if not already present
if ! grep -q "$(which fish)" /etc/shells; then
    log_info "Adding fish to valid login shells..."
    echo "$(which fish)" | sudo tee -a /etc/shells
    log_success "Fish added to valid login shells"
fi

# Change default shell to fish
if [[ "$SHELL" != "$(which fish)" ]]; then
    log_info "Changing default shell to fish..."
    chsh -s "$(which fish)"
    log_success "Default shell changed to fish"
    log_warning "Please restart your terminal or run 'exec fish' to use the new shell"
else
    log_success "Fish is already the default shell"
fi

# Deploy dotfiles using the fish function
log_info "Deploying dotfiles..."

# Create a temporary fish script to run dotdeploy
temp_fish_script=$(mktemp)
cat > "$temp_fish_script" << EOF
set -gx DOTFILES_ROOT "$DOTFILES_ROOT"
source "$DOTFILES_ROOT/fish/functions/dotdeploy.fish"
dotdeploy
EOF

# Run the fish script
fish "$temp_fish_script"
rm "$temp_fish_script"

log_success "Dotfiles deployed successfully"

echo ""
log_success "🎉 Setup completed successfully!"
echo ""
log_info "Next steps:"
echo "  1. Restart your terminal or run 'exec fish'"
echo "  2. Verify your setup with 'fish --version' and 'starship --version'"
echo "  3. Enjoy your new development environment!"
echo ""
