[[ -o interactive ]] || return

if [[ -n "${ZSH_PROFILE-}" ]]; then
  zmodload zsh/zprof 2>/dev/null
fi

# Export here as /etc/zshrc will set it too; zshenv alone doesn't suffice.
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=100000
export SAVEHIST=100000

# Load conf.d/ modules in numeric order (NN-name.zsh).
() {
  local f
  for f in "$ZDOTDIR/conf.d"/[0-9][0-9]-*.zsh(N); do
    source "$f"
  done
}

if [[ -n "${ZSH_PROFILE-}" ]]; then
  zprof
fi
