[[ "$OSTYPE" == darwin* ]] || return

# ---------------------------------------------------------------------------
# Homebrew — hardcoded paths, no subprocesses.
# $HOMEBREW_PREFIX is set in .zprofile; fall back gracefully.
# ---------------------------------------------------------------------------
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  # Prefer GNU coreutils over macOS BSD variants
  for _util_dir in \
    "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin" \
    "$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin" \
    "$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin" \
    "$HOMEBREW_PREFIX/opt/grep/libexec/gnubin"
  do
    [[ -d "$_util_dir" ]] && path=("$_util_dir" $path)
  done
  unset _util_dir

  export CMAKE_PREFIX_PATH="$HOMEBREW_PREFIX${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"
fi

# Disable macOS session save/restore ("Save Shell State")
export SHELL_SESSIONS_DISABLE=1

# Deployment target (safe: sw_vers is always present on macOS)
export MACOSX_DEPLOYMENT_TARGET="$(sw_vers -productVersion)"

# ---------------------------------------------------------------------------
# Optional SDK paths — only set if the tool is actually installed
# ---------------------------------------------------------------------------
if command -v java >/dev/null 2>&1 && [[ -x /usr/libexec/java_home ]]; then
  export JAVA_HOME="$(/usr/libexec/java_home 2>/dev/null)"
fi

if [[ -d /opt/homebrew/share/android-commandlinetools ]]; then
  export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
  export ANDROID_SDK_ROOT=$ANDROID_HOME
  # NDK: set only when the expected directory exists
  local _ndk_dir
  _ndk_dir=$(echo "$ANDROID_HOME/ndk/"*(N[1]) 2>/dev/null)
  [[ -d "$_ndk_dir" ]] && export ANDROID_NDK_ROOT="$_ndk_dir"
  unset _ndk_dir
fi

# ---------------------------------------------------------------------------
# macOS aliases
# ---------------------------------------------------------------------------
alias show-hidden='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hide-hidden='defaults write com.apple.finder AppleShowAllFiles NO  && killall Finder'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias ql='qlmanage -p'
