: <<'CORE_UTILS_WINDOWS'
@echo off
setlocal
set "CORE_UTILS_BOOTSTRAP=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'Stop'; $path = $env:CORE_UTILS_BOOTSTRAP; $text = Get-Content -Raw -LiteralPath $path; $startMarker = ':CORE_UTILS_POWERSHELL'; $endMarker = 'CORE_UTILS_POWERSHELL_PAYLOAD'; $start = $text.IndexOf($startMarker); if ($start -lt 0) { throw 'PowerShell payload marker not found.' }; $start += $startMarker.Length; $end = $text.IndexOf($endMarker, $start); if ($end -lt 0) { throw 'PowerShell payload end marker not found.' }; $payload = $text.Substring($start, $end - $start); & ([scriptblock]::Create($payload)) @args" %*
exit /b %ERRORLEVEL%
CORE_UTILS_WINDOWS

set -euo pipefail

REPO_URL="https://github.com/deeedob/core-utils.git"
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"

info()    { printf '\033[0;34m[core-utils]\033[0m %s\n' "$*"; }
success() { printf '\033[0;32m[core-utils]\033[0m %s\n' "$*"; }
warn()    { printf '\033[0;33m[core-utils]\033[0m %s\n' "$*"; }
die()     { printf '\033[0;31m[core-utils] ERROR:\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'USAGE'
Usage:
  bash bootstrap.cmd [install|update|link] [--no-packages] [--no-link]

Commands:
  install   Clone or update, install packages, and link configs (default)
  update    Pull latest changes and re-link configs
  link      Link configs from the current checkout only

Environment:
  CORE_UTILS_DIR  Override install directory

Defaults:
  Local checkout: directory containing bootstrap.cmd
  Piped install:  ./core-utils
USAGE
}

detect_os() {
  if [[ "${OSTYPE:-}" == darwin* ]]; then
    echo macos
  elif grep -qi microsoft /proc/version 2>/dev/null; then
    echo wsl
  elif [[ -f /etc/os-release ]]; then
    echo linux
  else
    echo unknown
  fi
}

detect_distro() {
  command -v apt-get >/dev/null 2>&1 && { echo apt; return; }
  command -v pacman >/dev/null 2>&1 && { echo pacman; return; }
  command -v dnf >/dev/null 2>&1 && { echo dnf; return; }
  command -v zypper >/dev/null 2>&1 && { echo zypper; return; }
  echo unknown
}

script_dir() {
  cd -P "$(dirname "$SCRIPT_PATH")" && pwd
}

is_local_script() {
  [[ -f "$SCRIPT_PATH" ]] || return 1
  [[ "$SCRIPT_PATH" != /dev/fd/* ]] || return 1
  [[ "$SCRIPT_PATH" != /proc/self/fd/* ]] || return 1
}

is_core_utils_tree() {
  local dir="$1"
  [[ -f "$dir/bootstrap.cmd" && -d "$dir/dot" && -d "$dir/packages" ]]
}

default_install_dir() {
  local dir
  if is_local_script; then
    dir="$(script_dir)"
    if [[ -d "$dir/.git" ]] || is_core_utils_tree "$dir"; then
      printf '%s\n' "$dir"
      return
    fi
  fi

  printf '%s\n' "$PWD/core-utils"
}

INSTALL_DIR="${CORE_UTILS_DIR:-$(default_install_dir)}"

read_pkg_list() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  grep -v '^#' "$file" | grep -v '^[[:space:]]*$'
}

install_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  local brew_paths=(/opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew)
  local brew_path
  for brew_path in "${brew_paths[@]}"; do
    [[ -x "$brew_path" ]] && eval "$("$brew_path" shellenv)" && break
  done
}

install_brew_pkgs() {
  local pkgs
  pkgs=$(read_pkg_list "$INSTALL_DIR/packages/brew.txt") || true
  [[ -z "$pkgs" ]] && return
  info "Installing brew packages..."
  # shellcheck disable=SC2086
  brew install $pkgs 2>&1 | grep -v 'already installed' || true
}

install_apt_pkgs() {
  local pkgs
  pkgs=$(read_pkg_list "$INSTALL_DIR/packages/apt.txt") || true
  [[ -z "$pkgs" ]] && return
  info "Installing apt packages..."
  sudo apt-get update -qq
  # shellcheck disable=SC2086
  sudo apt-get install -y $pkgs
}

install_pacman_pkgs() {
  local pkgs
  pkgs=$(read_pkg_list "$INSTALL_DIR/packages/pacman.txt") || true
  [[ -z "$pkgs" ]] && return
  info "Installing pacman packages..."
  # shellcheck disable=SC2086
  sudo pacman -Syu --noconfirm $pkgs
}

install_dnf_pkgs() {
  local pkgs
  pkgs=$(read_pkg_list "$INSTALL_DIR/packages/dnf.txt") || true
  [[ -z "$pkgs" ]] && return
  info "Installing dnf packages..."
  # shellcheck disable=SC2086
  sudo dnf install -y $pkgs
}

install_stow() {
  command -v stow >/dev/null 2>&1 && return
  info "Installing stow..."
  case "$OS" in
    macos)
      install_brew
      brew install stow
      ;;
    linux|wsl)
      case "$(detect_distro)" in
        apt) sudo apt-get install -y stow ;;
        pacman) sudo pacman -S --noconfirm stow ;;
        dnf) sudo dnf install -y stow ;;
        *)
          install_brew
          brew install stow
          ;;
      esac
      ;;
    *)
      die "Unsupported OS for automatic stow install."
      ;;
  esac
}

clone_or_update() {
  if [[ -d "$INSTALL_DIR/.git" ]]; then
    info "Updating existing repo..."
    git -C "$INSTALL_DIR" pull --ff-only
    git -C "$INSTALL_DIR" submodule update --init --recursive --remote --merge
  elif is_core_utils_tree "$INSTALL_DIR"; then
    info "Using local core-utils checkout at $INSTALL_DIR..."
  else
    info "Cloning core-utils to $INSTALL_DIR..."
    git clone --recurse-submodules "$REPO_URL" "$INSTALL_DIR"
  fi
}

install_packages() {
  case "$OS" in
    macos)
      install_brew
      install_brew_pkgs
      ;;
    linux|wsl)
      case "$(detect_distro)" in
        apt) install_apt_pkgs ;;
        pacman) install_pacman_pkgs ;;
        dnf) install_dnf_pkgs ;;
        zypper) warn "No zypper package list is configured; skipping system packages." ;;
        *) warn "No supported system package manager found; skipping system packages." ;;
      esac

      if command -v brew >/dev/null 2>&1; then
        install_brew
        install_brew_pkgs
      fi
      ;;
    *)
      warn "Unknown OS; skipping package installation."
      ;;
  esac
}

link_configs() {
  install_stow

  info "Linking core-utils to $HOME..."
  stow --verbose=1 --restow --dir="$INSTALL_DIR" --target="$HOME" dot

  local dir
  for dir in \
    "$HOME/.local/bin" \
    "$HOME/.local/share" \
    "$HOME/.local/state/zsh" \
    "$HOME/.local/state/less" \
    "$HOME/.local/state/python" \
    "$HOME/.cache/zsh"; do
    [[ -d "$dir" ]] || mkdir -p "$dir"
  done
}

install_yazi_plugins() {
  if ! command -v ya >/dev/null 2>&1; then
    warn "ya (yazi) not found — skipping yazi plugin installation."
    return
  fi
  info "Installing yazi plugins and flavors..."
  ya pkg install 2>&1 | grep -v '^$' || warn "ya pkg install failed (non-fatal)"
}

CMD="install"
NO_PACKAGES=0
NO_LINK=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    install|update|link)
      CMD="$1"
      ;;
    --no-packages)
      NO_PACKAGES=1
      ;;
    --no-link)
      NO_LINK=1
      ;;
    -h|--help|help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
  shift
done

OS=$(detect_os)

case "$CMD" in
  install)
    clone_or_update
    [[ "$NO_PACKAGES" -eq 1 ]] || install_packages
    [[ "$NO_LINK" -eq 1 ]] || link_configs
    [[ "$NO_LINK" -eq 1 ]] || install_yazi_plugins
    success "Install complete. Open a new shell to apply changes."
    ;;
  update)
    clone_or_update
    [[ "$NO_LINK" -eq 1 ]] || link_configs
    [[ "$NO_LINK" -eq 1 ]] || install_yazi_plugins
    success "Update complete."
    ;;
  link)
    INSTALL_DIR="$(script_dir)"
    link_configs
    install_yazi_plugins
    success "Configs linked."
    ;;
esac

exit 0

: <<'CORE_UTILS_POWERSHELL_PAYLOAD'
:CORE_UTILS_POWERSHELL
param(
  [string]$Command = "install",
  [switch]$Force,
  [switch]$NoPackages,
  [switch]$NoLink,
  [switch]$DryRun,
  [switch]$Help
)

$ErrorActionPreference = "Stop"
$RepoUrl = "https://github.com/deeedob/core-utils.git"
$ScriptPath = $env:CORE_UTILS_BOOTSTRAP

function Test-CoreUtilsTree($Path) {
  if (-not $Path) { return $false }
  return (
    (Test-Path -LiteralPath (Join-Path $Path "bootstrap.cmd")) -and
    (Test-Path -LiteralPath (Join-Path $Path "dot")) -and
    (Test-Path -LiteralPath (Join-Path $Path "packages"))
  )
}

function Get-ScriptDir {
  if ($ScriptPath -and (Test-Path -LiteralPath $ScriptPath)) {
    return (Resolve-Path -LiteralPath (Split-Path -Parent $ScriptPath)).Path
  }
  return $null
}

function Get-DefaultInstallDir {
  $scriptDir = Get-ScriptDir
  if ($scriptDir -and ((Test-Path -LiteralPath (Join-Path $scriptDir ".git")) -or (Test-CoreUtilsTree $scriptDir))) {
    return $scriptDir
  }

  return Join-Path (Get-Location) "core-utils"
}

$InstallDir = if ($env:CORE_UTILS_DIR) { $env:CORE_UTILS_DIR } else { Get-DefaultInstallDir }

function Show-Usage {
  @"
Usage:
  .\bootstrap.cmd [install|update|link] [-Force] [-NoPackages] [-NoLink] [-DryRun]

Commands:
  install   Clone or update, install packages, and link configs (default)
  update    Pull latest changes and re-link configs
  link      Link configs from the current checkout only

Environment:
  CORE_UTILS_DIR  Override install directory

Defaults:
  Local checkout: directory containing bootstrap.cmd
  Piped install:  .\core-utils
"@ | Write-Host
}

function Info($Message) { Write-Host "[core-utils] $Message" -ForegroundColor Blue }
function Success($Message) { Write-Host "[core-utils] $Message" -ForegroundColor Green }
function Warn($Message) { Write-Host "[core-utils] $Message" -ForegroundColor Yellow }

function Install-Scoop {
  if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Info "Installing Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
  }
}

function Install-ScoopPackages {
  $pkgFile = Join-Path $InstallDir "packages\scoop.txt"
  if (-not (Test-Path -LiteralPath $pkgFile)) { return }

  foreach ($bucket in @("extras", "nerd-fonts", "versions")) {
    scoop bucket add $bucket 2>$null | Out-Null
  }

  $packages = @(Get-Content -LiteralPath $pkgFile | Where-Object { $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' })
  if ($packages.Count -eq 0) { return }

  Info "Installing Scoop packages..."
  foreach ($pkg in $packages) {
    scoop install $pkg 2>&1 | Where-Object { $_ -notmatch 'already installed' }
  }
}

function Clone-OrUpdate {
  if (Test-Path -LiteralPath (Join-Path $InstallDir ".git")) {
    Info "Updating existing repo..."
    git -C $InstallDir pull --ff-only
    git -C $InstallDir submodule update --init --recursive --remote --merge
  } elseif (Test-CoreUtilsTree $InstallDir) {
    Info "Using local core-utils checkout at $InstallDir..."
  } else {
    Info "Cloning core-utils to $InstallDir..."
    git clone --recurse-submodules $RepoUrl $InstallDir
  }
}

function New-CoreUtilsSymlink($Source, $Target) {
  if (Test-Path -LiteralPath $Target) {
    if (-not $Force) {
      Write-Host "SKIP (exists):  $Target" -ForegroundColor Yellow
      return
    }

    if ($DryRun) {
      Write-Host "REMOVE (dry):   $Target" -ForegroundColor Yellow
    } else {
      Remove-Item -LiteralPath $Target -Recurse -Force
    }
  }

  $parent = Split-Path -Parent $Target
  if (-not (Test-Path -LiteralPath $parent)) {
    if ($DryRun) {
      Write-Host "MKDIR (dry):    $parent" -ForegroundColor Cyan
    } else {
      New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
  }

  if ($DryRun) {
    Write-Host "LINK (dry):     $Target -> $Source" -ForegroundColor Cyan
  } else {
    New-Item -ItemType SymbolicLink -Path $Target -Value $Source | Out-Null
    Write-Host "LINKED:         $Target" -ForegroundColor Green
  }
}

function Link-Configs {
  $dotDir = Join-Path $InstallDir "dot"
  $homeDir = $env:USERPROFILE

  Info "Linking core-utils to $homeDir..."
  New-CoreUtilsSymlink (Join-Path $dotDir ".zshenv") (Join-Path $homeDir ".zshenv")

  $nativeConfigs = @("git", "ripgrep", "atuin", "tig", "lazygit", "yazi", "bat")
  $configSource = Join-Path $dotDir ".config"
  $configTarget = Join-Path $homeDir ".config"

  foreach ($name in $nativeConfigs) {
    $source = Join-Path $configSource $name
    $target = Join-Path $configTarget $name
    if (Test-Path -LiteralPath $source) {
      New-CoreUtilsSymlink $source $target
    }
  }
}

function Install-YaziPlugins {
  if (-not (Get-Command ya -ErrorAction SilentlyContinue)) {
    Warn "ya (yazi) not found — skipping yazi plugin installation."
    return
  }
  Info "Installing yazi plugins and flavors..."
  ya pkg install 2>&1 | Where-Object { $_ -notmatch '^\s*$' }
}

if ($Help -or $Command -eq "help" -or $Command -eq "--help" -or $Command -eq "-h") {
  Show-Usage
  return
}

switch ($Command) {
  "install" {
    Clone-OrUpdate
    if (-not $NoPackages) {
      Install-Scoop
      Install-ScoopPackages
    }
    if (-not $NoLink) {
      Link-Configs
      Install-YaziPlugins
    }
    Success "Install complete. Restart your terminal."
  }
  "update" {
    Clone-OrUpdate
    if (-not $NoLink) {
      Link-Configs
      Install-YaziPlugins
    }
    Success "Update complete."
  }
  "link" {
    $InstallDir = Split-Path -Parent $ScriptPath
    Link-Configs
    Install-YaziPlugins
    Success "Configs linked."
  }
  default {
    throw "Unknown command: $Command"
  }
}
CORE_UTILS_POWERSHELL_PAYLOAD
