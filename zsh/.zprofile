# PATH is set here rather than in .zshenv because /etc/zprofile runs path_helper,
# which moves entries added before it behind the system paths

[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

typeset -U path
path=(~/.local/bin $path)
