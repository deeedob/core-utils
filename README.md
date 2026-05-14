# core-utils

Cross-platform CLI environment. Works on macOS, Linux, and Windows (native).

**Stack:** zsh · neovim · ghostty · git (lazygit · delta · tig) · fzf · atuin

---

## Install

`bootstrap.cmd` is the single setup file. Run it with Bash on macOS/Linux, or run it directly from PowerShell on Windows.

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/deeedob/core-utils/main/bootstrap.cmd | bash
```

Or clone manually:

```bash
git clone --recurse-submodules https://github.com/deeedob/core-utils
cd core-utils
bash bootstrap.cmd install
```

### Windows (PowerShell, run as Admin)

```powershell
iwr -useb https://raw.githubusercontent.com/deeedob/core-utils/main/bootstrap.cmd -OutFile bootstrap.cmd
.\bootstrap.cmd
```

Installs [Scoop](https://scoop.sh) if not present, then installs packages and links configs.
On Windows, only terminal-compatible configs are linked (git, ripgrep, tig, atuin, lazygit, yazi).
Full zsh config applies when using Git Bash or MSYS2.

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

### Content search — `frg`

Live ripgrep search with fzf, opens result in `$EDITOR` at the matching line.

```
frg                    Interactive (type to search)
frg "error handling"   Pre-fill query
frg -t cpp             Restrict to file type (rg --type)
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
| `enter` | Open commit in nvim (readonly) |
| `ctrl-d` | Switch to diff preview |
| `ctrl-f` | Switch to full-message preview |
| `ctrl-s` | Back to stat preview |
| `ctrl-y` | Copy SHA to clipboard |
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
| `frg [query] [-t type]` | Live ripgrep search → nvim at line |
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
