# ---------------------------------------------------------------------------
# Vi mode
# ---------------------------------------------------------------------------
bindkey -v

# 50ms: enough for multi-key sequences (fzf-git CTRL-G prefix), imperceptible for ESC
export KEYTIMEOUT=5

# ---------------------------------------------------------------------------
# Cursor shape per vi mode
# Use precmd hook instead of zle-line-init to avoid conflicts with
# plugins (atuin, fast-syntax-highlighting) that also wrap zle-line-init.
# ---------------------------------------------------------------------------
autoload -Uz add-zsh-hook

_zsh_cursor_beam()  { printf '\e[6 q' }
_zsh_cursor_block() { printf '\e[2 q' }

# Restore beam cursor before each prompt
add-zsh-hook precmd _zsh_cursor_beam

# Switch cursor shape on vi mode change
zle-keymap-select() {
  case "$KEYMAP" in
    vicmd)      _zsh_cursor_block ;;
    viins|main) _zsh_cursor_beam  ;;
  esac
}
zle -N zle-keymap-select

# Reset cursor to beam on shell exit
add-zsh-hook zshexit _zsh_cursor_beam

# ---------------------------------------------------------------------------
# Readline bindings in insert mode (familiar even with vi mode on)
# ---------------------------------------------------------------------------
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
bindkey '^U' backward-kill-line
bindkey '^W' backward-kill-word
bindkey '^Y' yank
bindkey '^F' forward-char
bindkey '^B' backward-char
bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history

# Fix delete key (^[[3~)
bindkey '^[[3~' delete-char

# ---------------------------------------------------------------------------
# History substring search (plugin loaded in 50-plugins; widget names only)
# ---------------------------------------------------------------------------
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# ---------------------------------------------------------------------------
# Edit current command in $EDITOR (Ctrl-X Ctrl-E or 'v' in normal mode)
# ---------------------------------------------------------------------------
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey -M vicmd 'v' edit-command-line

# ---------------------------------------------------------------------------
# Completion menu navigation with vi keys
# ---------------------------------------------------------------------------
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect '^[[Z' reverse-menu-complete
