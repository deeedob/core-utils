typeset -gU fpath
fpath=("$ZDOTDIR/functions" $fpath)

# Autoload every file in functions/
() {
  local fn
  for fn in "$ZDOTDIR/functions"/*(N.:t); do
    autoload -Uz "$fn"
  done
}

# ---------------------------------------------------------------------------
# Clipboard helper — returns the correct pipe command for the current platform
# ---------------------------------------------------------------------------
_clip_cmd() {
  if   (( $+commands[pbcopy]   )); then echo "pbcopy"
  elif (( $+commands[wl-copy]  )); then echo "wl-copy"
  elif (( $+commands[xclip]    )); then echo "xclip -selection clipboard"
  elif (( $+commands[xsel]     )); then echo "xsel --clipboard --input"
  elif command -v clip.exe >/dev/null 2>&1; then echo "clip.exe"
  else echo "cat"
  fi
}

# ---------------------------------------------------------------------------
# Directory utilities
# ---------------------------------------------------------------------------

# Create directory and cd into it
mkcd() { mkdir -p "$@" && cd "$_" }

# Go up N directories (default 1)
up() {
  local t='.' n="${1:-1}"
  while (( n-- > 0 )); do t+='/..'; done
  cd "$t"
}

# yazi wrapper — cd to the directory yazi exits in
y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  command rm -f -- "$tmp"  # bypass rm='rm -iv' alias: suppress verbose output
}

# ---------------------------------------------------------------------------
# ff — Find Files (fd + fzf → open in $EDITOR)
#
# Usage: ff [path] [-e ext]
#   ff              Search from CWD
#   ff src/         Search from path
#   ff -e cpp       Filter by extension
#
# fzf bindings:
#   enter      Open in $EDITOR (nvim)
#   ctrl-o     Open with system default (xdg-open / open)
#   ctrl-y     Copy path to clipboard
#   ctrl-/     Toggle preview
# ---------------------------------------------------------------------------
ff() {
  local search_path='.'
  local -a extra_fd_args

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -e|--ext) extra_fd_args+=(--extension "$2"); shift 2 ;;
      *)        search_path="$1"; shift ;;
    esac
  done

  local CLIP
  CLIP=$(_clip_cmd)

  local file
  file=$(
    { (( $+commands[fd] )) && \
        fd --type=f --hidden --follow --exclude=.git "${extra_fd_args[@]}" . "$search_path" || \
        find "$search_path" -type f -not -path '*/.git/*'
    } | fzf \
        --preview='bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null || echo {}' \
        --bind="ctrl-o:execute-silent(xdg-open {} 2>/dev/null || open {} 2>/dev/null)" \
        --bind="ctrl-y:execute-silent(echo -n {} | $CLIP)" \
        --header='enter:nvim  ctrl-o:open  ctrl-y:copy-path  ctrl-/:preview'
  )
  [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
}

# ---------------------------------------------------------------------------
# fcd — Find directory and cd into it (fzf-powered)
# ---------------------------------------------------------------------------
fcd() {
  local dir
  dir=$(
    { (( $+commands[fd] )) && \
        fd --type=d --hidden --follow --exclude=.git . "${1:-.}" || \
        find "${1:-.}" -type d -not -path '*/.git/*'
    } | fzf --preview 'eza --tree --level=2 --color=always {}'
  ) && cd "$dir"
}

# ---------------------------------------------------------------------------
# frg — Find with Ripgrep (live ripgrep + fzf → open in $EDITOR at line)
#
# Usage: frg [initial-query] [-t type]
#   frg                   Interactive live search
#   frg "error handling"  Pre-fill query
#   frg -t cpp            Restrict to filetype (rg --type)
#
# fzf bindings:
#   enter      Open in $EDITOR at matching line
#   ctrl-y     Copy "file:line" to clipboard
#   ctrl-/     Toggle preview
# ---------------------------------------------------------------------------
frg() {
  (( $+commands[rg]  )) || { print "frg: ripgrep (rg) not found" >&2; return 1 }
  (( $+commands[fzf] )) || { print "frg: fzf not found"          >&2; return 1 }

  local -a rg_type_args
  local initial_query=''

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t|--type) rg_type_args+=(--type "$2"); shift 2 ;;
      *)         initial_query+="${initial_query:+ }$1"; shift ;;
    esac
  done

  local rg_base="rg --column --line-number --no-heading --color=always --smart-case ${rg_type_args[*]}"
  local CLIP
  CLIP=$(_clip_cmd)

  local result
  result=$(
    FZF_DEFAULT_COMMAND="$rg_base ${(q)initial_query:-.}" \
    fzf --ansi \
        --disabled \
        --query="$initial_query" \
        --bind="change:reload:$rg_base {q} 2>/dev/null || true" \
        --delimiter=: \
        --preview='bat --color=always --style=numbers --line-range={2}:+60 {1} 2>/dev/null' \
        --preview-window='right:55%:+{2}+3/3:wrap' \
        --bind="ctrl-y:execute-silent(echo -n {1}:{2} | $CLIP)" \
        --header='enter:nvim-at-line  ctrl-y:copy-location  ctrl-/:preview'
  )

  [[ -z "$result" ]] && return
  local file="${result%%:*}"
  local line="${${result#*:}%%:*}"
  ${EDITOR:-nvim} +"$line" "$file"
}

# ---------------------------------------------------------------------------
# gl — Git Log browser (fzf-powered)
#
# Usage: gl [query] [-d query]
#   gl                  Browse full log (stat preview)
#   gl "fix auth"       Pre-filter commits by message (--grep)
#   gl -d "needle"      Pre-filter commits touching string in diff (-S)
#
# fzf bindings:
#   enter      Open commit in nvim (readonly)
#   ctrl-d     Switch to diff preview
#   ctrl-f     Switch to full-message preview
#   ctrl-s     Back to stat preview (default)
#   ctrl-y     Copy SHA to clipboard
#   ctrl-b     Checkout commit (exits fzf)
# ---------------------------------------------------------------------------
gl() {
  (( $+commands[git] )) || { print "gl: git not found" >&2; return 1 }
  git rev-parse --git-dir &>/dev/null || { print "gl: not a git repo" >&2; return 1 }

  local mode='msg' query=''

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--diff) mode='diff'; shift; query="${1:-}"; [[ $# -gt 0 ]] && shift ;;
      *)         query+="${query:+ }$1"; shift ;;
    esac
  done

  local -a git_log_args
  case "$mode" in
    msg)  [[ -n "$query" ]] && git_log_args+=(--grep="$query") ;;
    diff) [[ -n "$query" ]] && git_log_args+=(-S "$query") ;;
  esac

  local CLIP
  CLIP=$(_clip_cmd)

  git log --oneline --color=always "${git_log_args[@]}" | \
    fzf --ansi \
        --no-sort \
        --preview='git show --stat --color=always {1}' \
        --preview-window='right:60%:wrap' \
        --bind='ctrl-d:change-preview(git show --patch --color=always {1})' \
        --bind='ctrl-f:change-preview(git show --color=always {1})' \
        --bind='ctrl-s:change-preview(git show --stat --color=always {1})' \
        --bind="ctrl-y:execute-silent(echo -n {1} | $CLIP)" \
        --bind='enter:execute(git show {1} | nvim +"set ft=git nomod" -)' \
        --bind='ctrl-b:execute(git checkout {1})+abort' \
        --header='enter:nvim  ctrl-d:diff  ctrl-f:full  ctrl-s:stat  ctrl-y:copy  ctrl-b:checkout'
}

# ---------------------------------------------------------------------------
# gbc — Git Branches Containing a commit
#
# Usage: gbc [sha]   (defaults to HEAD)
# ---------------------------------------------------------------------------
gbc() {
  local sha="${1:-HEAD}"
  git branch --all --contains "$sha" 2>/dev/null | \
    fzf --header="Branches containing: $sha"
}

# ---------------------------------------------------------------------------
# fenv — Fuzzy search environment variables, copy value
# ---------------------------------------------------------------------------
fenv() {
  local CLIP
  CLIP=$(_clip_cmd)

  printenv | sort | \
    fzf --delimiter='=' \
        --preview='echo "Value: {2..}"' \
        --preview-window=down:3:wrap \
        --bind="ctrl-y:execute-silent(echo -n {2..} | $CLIP)" \
        --header='enter:print  ctrl-y:copy-value'
}

# ---------------------------------------------------------------------------
# fproc — Fuzzy process viewer / killer
# ---------------------------------------------------------------------------
fproc() {
  local pid
  pid=$(
    ps aux | tail -n +2 | \
      fzf --preview='echo {}' \
          --preview-window=down:3:wrap \
          --header='enter:kill(TERM)  ctrl-k:kill(KILL)' \
          --bind='ctrl-k:execute-silent(echo {} | awk "{print \$2}" | xargs kill -9)' | \
      awk '{print $2}'
  )
  [[ -n "$pid" ]] && kill "$pid"
}
