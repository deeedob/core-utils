# Sourced AFTER .zshrc in login shells.
# Use for background tasks that are expensive and run only once per login.
() {
  local zcd="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
  if [[ -s "$zcd" && (! -s "${zcd}.zwc" || "$zcd" -nt "${zcd}.zwc") ]]; then
    zcompile "$zcd" &!
  fi
}
