if not status is-interactive
    exit
end

# Aliases
abbr l 'ls -AG'
abbr configf 'code ~/.config/fish/config.fish'
abbr sourcef 'source ~/.config/fish/config.fish'
abbr configs 'code ~/.config/starship.toml'

command -q brew && brew shellenv | source
command -q starship && starship init fish | source
command -q ~/.local/bin/mise && ~/.local/bin/mise activate fish | source
