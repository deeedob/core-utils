# ---------------------------------------------------------------------------
# Safety nets
# ---------------------------------------------------------------------------
alias rm='rm -iv'
alias cp='cp -v'
alias mv='mv -v'

# ---------------------------------------------------------------------------
# Navigation
# ---------------------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Directory stack (AUTO_PUSHD in 10-options)
alias d='dirs -v'
for i in {1..9}; do alias "$i"="cd +$i"; done

# ---------------------------------------------------------------------------
# ls / eza
# ---------------------------------------------------------------------------
if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first'
  alias l='eza -lbF --group-directories-first'
  alias ll='eza -lbGF --git --group-directories-first'
  alias la='eza -lbhHigUmuSa --git --group-directories-first'
  alias lt='eza --tree --level=2 --group-directories-first'
  alias lta='eza --tree --level=2 -a --group-directories-first'
else
  alias ls='ls --color=auto'
  alias l='ls -lFh'
  alias ll='ls -lAFh'
  alias la='ls -A'
  alias lt='ls -ltrh'
fi

# ---------------------------------------------------------------------------
# cat / bat
# ---------------------------------------------------------------------------
if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
  alias less='bat --paging=always'
fi

# ---------------------------------------------------------------------------
# System info
# ---------------------------------------------------------------------------
alias df='df -h'
alias du='du -h'
(( $+commands[dust]  )) && alias duu='dust'
(( $+commands[btop]  )) && alias top='btop'
(( $+commands[tldr]  )) && alias help='tldr'

# ---------------------------------------------------------------------------
# HTTP
# ---------------------------------------------------------------------------
(( $+commands[xh] )) && alias GET='xh GET' PATCH='xh PATCH' POST='xh POST' DELETE='xh DELETE'

# ---------------------------------------------------------------------------
# Git  (single `g` for git; rg is ripgrep — used directly)
# ---------------------------------------------------------------------------
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gb='git branch'
alias gc='git commit'
alias gcm='git commit -m'
alias gcf='git commit --fixup'
alias gca='git commit --amend'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gfa='git fetch --all'
alias gp='git push'
alias gpl='git pull'
alias gr='git remote'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grs='git remote show'
alias gs='git status'
alias gst='git stash'
alias gsw='git switch'
alias grev='git-revise'
alias lg='lazygit'

# ---------------------------------------------------------------------------
# Misc
# ---------------------------------------------------------------------------
alias reload='source $ZDOTDIR/.zshrc'
alias c='clear'
alias flush='printf "\033[2J\033[3J\033[1;1H"'
alias ports='lsof -nP -iTCP -sTCP:LISTEN -iUDP'
alias h='history 0 | less'
(( $+commands[lazydocker] )) && alias lzd='lazydocker'
