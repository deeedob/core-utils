if ! (( $+commands[fzf] )); then
  print -P "%F{yellow}[zsh] fzf not found — skipping fzf integration.%f"
  return
fi

# ---------------------------------------------------------------------------
# Default options
# ---------------------------------------------------------------------------
_fzf_colors="bg+:-1,\
fg:gray,\
fg+:white,\
border:black,\
spinner:0,\
hl:yellow,\
header:blue,\
info:green,\
pointer:red,\
marker:blue,\
prompt:gray,\
hl+:red"

export FZF_DEFAULT_OPTS="
  --height=60%
  --layout=reverse
  --border=rounded
  --info=inline
  --preview-window=right:55%:wrap
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-u:preview-half-page-up'
  --bind='ctrl-d:preview-half-page-down'
  --bind='tab:down,shift-tab:up'
  --bind='ctrl-a:select-all'
  --color='$_fzf_colors'
"
unset _fzf_colors

# ---------------------------------------------------------------------------
# Default command: fd if available, fallback to find
# ---------------------------------------------------------------------------
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type=f --hidden --follow --exclude=.git'
  export FZF_ALT_C_COMMAND='fd --type=d --hidden --follow --exclude=.git'
else
  export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/.git/*"'
  export FZF_ALT_C_COMMAND='find . -type d -not -path "*/.git/*"'
fi
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ---------------------------------------------------------------------------
# Per-binding options
# ---------------------------------------------------------------------------
export FZF_CTRL_T_OPTS="
  --preview '([[ -d {} ]] && eza --tree --level=2 --color=always {}) ||
             bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null ||
             echo {}'
  --header='CTRL-T: paste path into command line'
"
export FZF_ALT_C_OPTS="
  --preview 'eza --tree --level=2 --color=always {}'
  --header='ALT-C: cd into directory'
"
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window=down:3:hidden:wrap
  --bind='ctrl-/:toggle-preview'
  --header='CTRL-R: paste command from history'
"

# Load shell integration (fzf >= 0.48)
source <(fzf --zsh)
