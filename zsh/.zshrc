# Environment variables
export DOTFILES_ROOT="$HOME/dev/dotfiles"

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt extended_history
# Also appends each command right away, so inc_append_history stays off
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks

# Options
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt interactive_comments
setopt magic_equal_subst
# Pass an unmatched glob through as is, like bash, so URLs with ? work unquoted
setopt no_nomatch
# Free Ctrl-S and Ctrl-Q from pausing the terminal
setopt no_flow_control

# Completion. brew shellenv in .zprofile has already added Homebrew's completions to fpath
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Key bindings. zsh switches to vi mode when $EDITOR contains "vi"
bindkey -e

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
# The up and down keys send ^[[A/^[[B or ^[OA/^[OB depending on the terminal mode
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^P' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Aliases
alias l='ls -AG'
alias configz='code ~/.zshrc'
alias sourcez='source ~/.zshrc'
alias configs='code ~/.config/starship.toml'

(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[mise] )) && eval "$(mise activate zsh)"

# fzf for Ctrl-R only. Empty commands keep it from binding Ctrl-T and Alt-C
if [[ -r $HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh ]]; then
    FZF_CTRL_T_COMMAND='' FZF_ALT_C_COMMAND='' source $HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh
fi

[[ -r $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
    source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Settings only for this Mac
[[ -f $DOTFILES_ROOT/zsh/local.zsh ]] && source $DOTFILES_ROOT/zsh/local.zsh

# Must come last: it highlights by wrapping every widget defined before it
[[ -r $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
    source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
