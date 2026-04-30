if ! (( $+commands[atuin] )); then
  print -P "%F{yellow}[zsh] atuin not found — skipping. Install: brew install atuin%f"
  return
fi

# Atuin replaces CTRL-R with a context-aware history UI (SQLite-backed).
# --disable-up-arrow preserves history-substring-search on up/down arrows.
eval "$(atuin init zsh --disable-up-arrow)"
