# core-utils

Cross-platform CLI environment. Works on macOS, Linux, and Windows (native).  
Designed to be added as a submodule in a larger dotfiles repo.

**Stack:** zsh · neovim · ghostty · git (lazygit · delta · tig) · fzf · atuin

---

## Install

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/deeedob/core-utils/main/bootstrap.sh | bash
```

Or clone manually:

```bash
git clone --recurse-submodules https://github.com/deeedob/core-utils ~/.local/share/core-utils
cd ~/.local/share/core-utils
make install
```

### Windows (PowerShell, run as Admin)

```powershell
iwr -useb https://raw.githubusercontent.com/deeedob/core-utils/main/bootstrap.ps1 | iex
```

Installs [Scoop](https://scoop.sh) if not present, then installs packages and links configs.  
On Windows, only terminal-compatible configs are linked (git, ripgrep, tig, atuin, lazygit).  
Full zsh config applies when using Git Bash or MSYS2.

### As a submodule (dotfiles integration)

```bash
cd ~/dotfiles
git submodule add https://github.com/deeedob/core-utils core-utils
# Then in your dotfiles link.sh:
bash core-utils/link.sh
```

---

## What gets installed

| Category | Tools |
|----------|-------|
| Shell | zsh, fzf, atuin, zoxide, stow |
| Files | fd, ripgrep, bat, eza, sd, dust, ouch |
| Git | lazygit, delta, tig, git-revise, git-absorb, gh |
| Monitoring | btop |
| HTTP | xh |
| Help | tealdeer (tldr) |
| Misc | yazi, jq, yq |

macOS: GNU coreutils, findutils, gnu-sed, grep (override BSD variants).

---

## Symlink management

```bash
make link          # re-link all configs (requires stow)
make update        # pull latest + re-link
```

Uses [GNU Stow](https://www.gnu.org/software/stow/): `dot/` is stowed to `$HOME`.  
Windows: `link.ps1` creates the same symlinks via PowerShell `mklink`.

---

## Zsh

### Config layout

```
~/.zshenv                 → sets ZDOTDIR only
~/.config/zsh/
├── .zshenv               → XDG dirs, PATH, tool env vars
├── .zprofile             → login-time setup (brew, COMPILE_CORES)
├── .zshrc                → loads conf.d/ in order
└── conf.d/
    ├── 10-options.zsh    → all setopt in one place
    ├── 20-completion.zsh → compinit + zstyle
    ├── 30-keybindings.zsh→ vi mode, cursor shapes, readline bindings
    ├── 40-aliases.zsh    → aliases
    ├── 50-plugins.zsh    → plugins (auto-cloned, no plugin manager)
    ├── 60-fzf.zsh        → FZF_DEFAULT_OPTS + shell integration
    ├── 61-zoxide.zsh     → zoxide (replaces cd)
    ├── 70-atuin.zsh      → atuin (replaces ctrl-r)
    ├── 71-macos.zsh      → macOS-only: GNU path overrides, SDK guards
    └── 80-functions.zsh  → custom functions
```

### Plugins (auto-cloned on first shell start)

- **fzf-tab** — replace zsh completion menu with fzf  
- **fast-syntax-highlighting** — syntax highlighting (faster than zsh-syntax-highlighting)  
- **zsh-autosuggestions** — ghost-text suggestions from history  
- **zsh-history-substring-search** — up/down arrows search history by prefix  
- **zsh-you-should-use** — reminds you when an alias exists  
- **pure** — minimal async prompt  
- **fzf-git.sh** — fzf keybindings for git objects (see below)  

Update all plugins:

```zsh
zsh-plugin-update
```

---

## Key commands

### File finding — `ff`

Find files with fd + fzf, open in `$EDITOR`.

```
ff              Search from CWD
ff src/         Search from path
ff -e cpp       Filter by extension
```

| Binding | Action |
|---------|--------|
| `enter` | Open in `$EDITOR` (nvim) |
| `ctrl-o` | Open with system default |
| `ctrl-y` | Copy path to clipboard |
| `ctrl-/` | Toggle preview |

### Content search — `fs`

Live ripgrep search with fzf, opens result in `$EDITOR` at the matching line.

```
fs                    Interactive (type to search)
fs "error handling"   Pre-fill query
fs -t cpp             Restrict to file type (rg --type)
```

| Binding | Action |
|---------|--------|
| `enter` | Open in nvim at line |
| `ctrl-y` | Copy `file:line` to clipboard |
| `ctrl-/` | Toggle preview |

### Git log browser — `gl`

```
gl                    Browse full log (stat preview)
gl "fix auth"         Filter by commit message (--grep)
gl -d "secret_key"    Filter by diff content (-S)
```

| Binding | Action |
|---------|--------|
| `enter` | Show full commit in pager |
| `ctrl-d` | Switch to diff preview |
| `ctrl-f` | Switch to full-message preview |
| `ctrl-s` | Back to stat preview |
| `ctrl-y` | Copy SHA to clipboard |
| `ctrl-o` | Open commit on GitHub (gh) |
| `ctrl-n` | Open commit in nvim |
| `ctrl-b` | Checkout commit |

### Git object picker — fzf-git.sh

Press `CTRL-G` then a second key to fuzzy-pick a git object and paste it into the current command line:

| Chord | Object |
|-------|--------|
| `ctrl-g ctrl-h` | Commit hashes |
| `ctrl-g ctrl-b` | Branches |
| `ctrl-g ctrl-t` | Tags |
| `ctrl-g ctrl-r` | Remotes |
| `ctrl-g ctrl-f` | Changed files |

Example: type `git show ` then `ctrl-g ctrl-h` to pick a commit hash.

### Other utilities

| Command | Description |
|---------|-------------|
| `gbc [sha]` | List branches containing a commit (default: HEAD) |
| `fcd [path]` | Fuzzy cd into a directory |
| `fenv` | Fuzzy search env vars, copy value |
| `fproc` | Fuzzy process viewer / killer |
| `y` | Launch yazi; cd to the directory it exits in |
| `up [n]` | Go up N directories (default 1) |
| `mkcd <dir>` | mkdir + cd in one step |
| `extract <file>` | Extract any archive format |
| `ipinfo` | Show external + internal IP addresses |

### Shell history — atuin

Replaces `ctrl-r` with a context-aware history UI backed by SQLite.  
Up/down arrows still use history-substring-search (unchanged).  
Local-only mode — no cloud sync.

---

## Tig

Quick reference for the most useful tig bindings (defined in `tigrc`):

| Key | Action |
|-----|--------|
| `e` | Open file / blame line in `$EDITOR` |
| `y` | Copy commit SHA to clipboard |
| `o` | Open commit on GitHub (`gh browse`) |
| `D` | Show full diff with delta |
| `r` | Interactive rebase from commit |
| `g` / `G` | Jump to first / last line |
| `ctrl-d` / `ctrl-u` | Half-page down / up |

Use tig for read-only exploration (blame, log, search).  
Use lazygit (`lg`) for interactive staging, rebasing, and branch management.

---

## Git config highlights

- `branch.sort = -committerdate` — newest branches first in `git branch`
- `push.autoSetupRemote = true` — no more `--set-upstream`
- `delta` with `side-by-side` and `line-numbers` enabled
- `rebase.autoSquash = true` — `--fixup` commits squash automatically
- `rerere.enabled = true` — remember conflict resolutions

---

## Aliases reference

### Git

| Alias | Command |
|-------|---------|
| `g` | `git` |
| `ga` / `gaa` / `gap` | add / add --all / add --patch |
| `gc` / `gcm` / `gcf` | commit / commit -m / commit --fixup |
| `gd` / `gds` | diff / diff --staged |
| `gf` / `gfa` | fetch / fetch --all |
| `gp` / `gpl` | push / pull |
| `grb` / `grbi` | rebase / rebase -i |
| `gsw` | switch |
| `gst` | stash |
| `lg` | lazygit |
| `grev` | git-revise |

### System

| Alias | Replaces |
|-------|---------|
| `top` | btop |
| `duu` | dust (visual disk usage) |
| `cat` | bat (syntax-highlighted) |
| `help` | tldr |
| `lzd` | lazydocker |
| `GET` / `POST` / etc. | xh (HTTP client) |
