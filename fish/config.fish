if not status is-interactive
    exit
end

# Environment variables
set -gx DOTFILES_ROOT "$HOME/dev/dotfiles"

# Aliases
abbr l 'ls -AG'
abbr configf 'code ~/.config/fish/config.fish'
abbr sourcef 'source ~/.config/fish/config.fish'
abbr configs 'code ~/.config/starship.toml'

command -q /opt/homebrew/bin/brew && /opt/homebrew/bin/brew shellenv | source
command -q starship && starship init fish | source
command -q ~/.local/bin/mise && ~/.local/bin/mise activate fish | source
