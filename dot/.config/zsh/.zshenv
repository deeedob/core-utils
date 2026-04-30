# Sourced by ALL zsh invocations (interactive, non-interactive, login, scripts).
# ONLY set environment variables here — no aliases, no functions, no prompt.
# Keep it fast: avoid subprocesses ($(...)), eval, and slow commands.

# ---------------------------------------------------------------------------
# XDG Base Directories
# ---------------------------------------------------------------------------
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# ---------------------------------------------------------------------------
# Zsh
# ---------------------------------------------------------------------------
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# ---------------------------------------------------------------------------
# Editor / Pager
# ---------------------------------------------------------------------------
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR -u NONE"
export VISUAL="$EDITOR"
export MANPAGER="nvim +Man!"
export PAGER="less"
export LESS="-R --use-color -Dd+r\$Du+b"
export TERMINAL="${TERMINAL:-ghostty}"

# ---------------------------------------------------------------------------
# Language / Locale
# ---------------------------------------------------------------------------
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# ---------------------------------------------------------------------------
# Tool-specific XDG compliance
# ---------------------------------------------------------------------------
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GOPATH="$XDG_DATA_HOME/go"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite_history"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonstartup.py"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# ---------------------------------------------------------------------------
# Build tools
# ---------------------------------------------------------------------------
export CMAKE_GENERATOR="Ninja"

# COMPILE_CORES is set in .zprofile (requires subshell); use it if available.
if [[ -n "${COMPILE_CORES:-}" ]]; then
  export MAKEFLAGS="${MAKEFLAGS} -j ${COMPILE_CORES}"
fi
export CPPFLAGS="${CPPFLAGS} -fdiagnostics-color=always"

# ---------------------------------------------------------------------------
# PATH
# ---------------------------------------------------------------------------
typeset -gU path
path=(
  "$HOME/.local/bin"
  "$XDG_DATA_HOME/cargo/bin"
  "$XDG_DATA_HOME/go/bin"
  "$HOME/.local/share/npm/bin"
  "$HOME/.local/share/nvim/mason/bin"
  $path
)

# ---------------------------------------------------------------------------
# Ensure required XDG state/cache dirs exist
# ---------------------------------------------------------------------------
for _d in \
  "$XDG_CACHE_HOME/zsh" \
  "$XDG_STATE_HOME/zsh" \
  "$XDG_STATE_HOME/less" \
  "$XDG_STATE_HOME/python"; do
  [[ -d "$_d" ]] || mkdir -p "$_d"
done
unset _d
