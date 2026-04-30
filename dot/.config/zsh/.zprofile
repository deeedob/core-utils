# Sourced for LOGIN shells, before .zshrc.
# Use for login-time setup that should not repeat on every subshell.

_get_cores() {
  if   command -v nproc   >/dev/null 2>&1; then nproc
  elif command -v sysctl  >/dev/null 2>&1; then sysctl -n hw.logicalcpu
  else grep -c '^processor' /proc/cpuinfo 2>/dev/null || echo 4
  fi
}

integer _total_cores _compile_cores
_total_cores=$(_get_cores)
_compile_cores=$(( _total_cores > 2 ? _total_cores - 2 : 1 ))
export COMPILE_CORES="$_compile_cores"
export MAKEFLAGS="-j${_compile_cores}"
unset _total_cores _compile_cores
unfunction _get_cores

if [[ "$OSTYPE" == darwin* ]]; then
  if   [[ -x /opt/homebrew/bin/brew  ]]; then HOMEBREW_PREFIX=/opt/homebrew
  elif [[ -x /usr/local/bin/brew     ]]; then HOMEBREW_PREFIX=/usr/local
  fi

  if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
    export HOMEBREW_PREFIX
    export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
    export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1

    typeset -gU path manpath infopath fpath
    path=("$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin" $path)
    manpath=("$HOMEBREW_PREFIX/share/man" $manpath)
    infopath=("$HOMEBREW_PREFIX/share/info" $infopath)
    fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
  fi

elif [[ "$OSTYPE" == linux* ]]; then
  # Linuxbrew / Homebrew on Linux
  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi
