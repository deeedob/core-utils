ZPLUGINDIR="$ZDOTDIR/plugins"

# ---------------------------------------------------------------------------
# Plugin management — lightweight, no external plugin manager.
# Plugins are shallow-cloned on first use and updated via zsh-plugin-update.
# ---------------------------------------------------------------------------

_zsh_plugin_clone() {
  local -A urls=(
    fzf-tab                      'https://github.com/Aloxaf/fzf-tab'
    fast-syntax-highlighting     'https://github.com/zdharma-continuum/fast-syntax-highlighting'
    zsh-autosuggestions          'https://github.com/zsh-users/zsh-autosuggestions'
    zsh-history-substring-search 'https://github.com/zsh-users/zsh-history-substring-search'
    zsh-completions              'https://github.com/zsh-users/zsh-completions'
    zsh-you-should-use           'https://github.com/MichaelAquilina/zsh-you-should-use'
    pure                         'https://github.com/sindresorhus/pure'
    fzf-git                      'https://github.com/junegunn/fzf-git.sh'
  )
  local name="$1" url="${urls[$1]}"
  [[ -z "$url" ]] && { print -P "%F{red}[zsh] Unknown plugin: '$name'%f"; return 1 }
  mkdir -p "$ZPLUGINDIR"
  print -P "%F{yellow}[zsh] Installing '$name'…%f"
  git clone --depth=1 --quiet "$url" "$ZPLUGINDIR/$name" \
    && print -P "%F{green}[zsh] Installed '$name'.%f" \
    || { print -P "%F{red}[zsh] Failed to clone '$name'.%f"; return 1 }
}

_zsource() {
  local f="$ZPLUGINDIR/$1"
  [[ -f "$f" ]] || {
    _zsh_plugin_clone "${f:h:t}" || return 1
  }
  source "$f"
}

zsh-plugin-update() {
  local name dir
  for name in fzf-tab fast-syntax-highlighting zsh-autosuggestions \
              zsh-history-substring-search zsh-completions \
              zsh-you-should-use pure fzf-git; do
    dir="$ZPLUGINDIR/$name"
    if [[ -d "$dir/.git" ]]; then
      print -P "%F{cyan}Updating $name…%f"
      git -C "$dir" pull --ff-only --quiet
    else
      _zsh_plugin_clone "$name"
    fi
  done
  print -P "\n%F{green}Done. Run: source \$ZDOTDIR/.zshrc%f"
}

# ---------------------------------------------------------------------------
# fzf-tab — replace zsh's default completion with fzf
# ---------------------------------------------------------------------------
(( $+commands[fzf] )) && _zsource fzf-tab/fzf-tab.plugin.zsh

zstyle ':fzf-tab:*' switch-group F1 F2

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:*:*'  fzf-preview \
  '([[ -d $realpath ]] && eza --tree --level=2 --color=always $realpath) ||
   ([[ -f $realpath ]] && bat --color=always --style=numbers --line-range=:200 $realpath) ||
   echo $realpath'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:4:wrap
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
  fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
zstyle ':completion:*:git-checkout:*' sort false

# ---------------------------------------------------------------------------
# zsh-history-substring-search
# ---------------------------------------------------------------------------
_zsource zsh-history-substring-search/zsh-history-substring-search.zsh
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=yellow,fg=black,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
HISTORY_SUBSTRING_SEARCH_FUZZY=1

# ---------------------------------------------------------------------------
# zsh-autosuggestions
# ---------------------------------------------------------------------------
_zsource zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(forward-word)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

# ---------------------------------------------------------------------------
# zsh-you-should-use
# ---------------------------------------------------------------------------
_zsource zsh-you-should-use/zsh-you-should-use.plugin.zsh
YSU_MODE=BESTMATCH
YSU_HARDCORE=0

# ---------------------------------------------------------------------------
# zsh-completions
# ---------------------------------------------------------------------------
_zsource zsh-completions/zsh-completions.plugin.zsh

# ---------------------------------------------------------------------------
# fzf-git.sh — CTRL-G prefix keybindings for git objects
# CTRL-G CTRL-H: hashes   CTRL-G CTRL-B: branches  CTRL-G CTRL-T: tags
# CTRL-G CTRL-R: remotes  CTRL-G CTRL-F: files (changed)
# ---------------------------------------------------------------------------
if (( $+commands[fzf] && $+commands[git] )); then
  local _fzf_git="$ZPLUGINDIR/fzf-git/fzf-git.sh"
  [[ -f "$_fzf_git" ]] || _zsh_plugin_clone fzf-git
  [[ -f "$_fzf_git" ]] && source "$_fzf_git"
  unset _fzf_git
fi

# ---------------------------------------------------------------------------
# fast-syntax-highlighting (must be near last, before pure prompt)
# ---------------------------------------------------------------------------
_zsource fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

typeset -A FAST_HIGHLIGHT_STYLES
FAST_HIGHLIGHT_STYLES[command]='fg=blue,bold'
FAST_HIGHLIGHT_STYLES[builtin]='fg=blue,bold'
FAST_HIGHLIGHT_STYLES[function]='fg=blue,bold'
FAST_HIGHLIGHT_STYLES[alias]='fg=cyan,bold'
FAST_HIGHLIGHT_STYLES[path]='fg=white,underline'
FAST_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
FAST_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
FAST_HIGHLIGHT_STYLES[globbing]='fg=magenta,bold'
FAST_HIGHLIGHT_STYLES[history-expansion]='fg=magenta,bold'
FAST_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
FAST_HIGHLIGHT_STYLES[reserved-word]='fg=yellow,bold'
FAST_HIGHLIGHT_STYLES[redirection]='fg=green,bold'
FAST_HIGHLIGHT_STYLES[comment]='fg=245'
FAST_HIGHLIGHT_STYLES[bracket-level-1]='fg=blue,bold'
FAST_HIGHLIGHT_STYLES[bracket-level-2]='fg=cyan,bold'
FAST_HIGHLIGHT_STYLES[bracket-level-3]='fg=magenta,bold'

# ---------------------------------------------------------------------------
# Pure prompt (must be last)
# ---------------------------------------------------------------------------
() {
  local dir="$ZPLUGINDIR/pure"
  if [[ ! -d "$dir" ]]; then
    _zsh_plugin_clone pure || { PS1='%F{blue}%~%f %F{yellow}❯%f '; return }
  fi

  PURE_GIT_UNTRACKED_DIRTY=0

  fpath=("$dir" $fpath)
  autoload -Uz prompt_pure_setup
  prompt_pure_setup

  zstyle ':prompt:pure:prompt:success'  color 'cyan'
  zstyle ':prompt:pure:prompt:error'    color 'red'
  zstyle ':prompt:pure:git:branch'      color 'magenta'
  zstyle ':prompt:pure:git:dirty'       color 'yellow'
  zstyle ':prompt:pure:path'            color 'blue'
  zstyle ':prompt:pure:execution_time'  color 'yellow'
}

unfunction _zsh_plugin_clone _zsource
