zmodload -i zsh/complist
zmodload -i zsh/stat

() {
  local zcd="${XDG_CACHE_HOME}/zsh/zcompdump"
  autoload -Uz compinit
  # Skip the security check (-C) when the dump is fresh (< 20h).
  if [[ -f "$zcd" ]]; then
    local -A fstat
    zstat -H fstat "$zcd"
    if (( EPOCHSECONDS - fstat[mtime] < 72000 )); then
      compinit -C -d "$zcd"
    else
      compinit -d "$zcd"
      zcompile "$zcd"
    fi
  else
    compinit -d "$zcd"
    zcompile "$zcd"
  fi
}

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings'     format '%F{red}-- no matches --%f'
zstyle ':completion:*:corrections'  format '%F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*' verbose true
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME}/zsh/zcompcache"
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*:functions'              ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*:*:kill:*:processes'     list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*'                 command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:(ssh|scp|sftp|rsync):*' hosts off
