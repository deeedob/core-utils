if ! (( $+commands[zoxide] )); then
  print -P "%F{yellow}[zsh] zoxide not found — skipping.%f"
  return
fi

# Replace cd with zoxide. The sed works around a completion name collision.
eval "$(zoxide init --cmd cd zsh | sed 's/_files/_cd/g')"
