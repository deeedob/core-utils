# ~/.zshenv — sourced by ALL zsh invocations.
# Single responsibility: redirect zsh dotfiles to XDG_CONFIG_HOME.
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
. $ZDOTDIR/.zshenv
