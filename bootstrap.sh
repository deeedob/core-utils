#!/usr/bin/env bash
# bootstrap.sh — Set up core-utils on macOS or Linux.
#
# Usage:
#   curl -fsSL <raw-url>/bootstrap.sh | bash        # install
#   bash bootstrap.sh [install|update|link]
#
# Modes:
#   install  (default) Clone repo, install packages, link configs
#   update             Pull latest, re-link
#   link               Symlink configs only (requires stow + cloned repo)
set -euo pipefail

REPO_URL="https://github.com/deeedob/core-utils"
INSTALL_DIR="${CORE_UTILS_DIR:-$HOME/.local/share/core-utils}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()    { printf '\e[0;34m[core-utils]\e[0m %s\n' "$*"; }
success() { printf '\e[0;32m[core-utils]\e[0m %s\n' "$*"; }
warn()    { printf '\e[0;33m[core-utils]\e[0m %s\n' "$*"; }
die()     { printf '\e[0;31m[core-utils] ERROR:\e[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Detection
# ---------------------------------------------------------------------------
detect_os() {
  if [[ "$OSTYPE" == darwin* ]]; then
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
  command -v apt-get >/dev/null 2>&1 && { echo apt;    return; }
  command -v pacman  >/dev/null 2>&1 && { echo pacman; return; }
  command -v dnf     >/dev/null 2>&1 && { echo dnf;    return; }
  command -v zypper  >/dev/null 2>&1 && { echo zypper; return; }
  echo unknown
}

# ---------------------------------------------------------------------------
# Package managers
# ---------------------------------------------------------------------------
install_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Make brew available in this session
  local brew_paths=(/opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew)
  for bp in "${brew_paths[@]}"; do
    [[ -x "$bp" ]] && eval "$("$bp" shellenv)" && break
  done
}

read_pkg_list() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  grep -v '^#' "$file" | grep -v '^[[:space:]]*$'
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
    macos)              brew install stow ;;
    linux|wsl)
      case "$(detect_distro)" in
        apt)    sudo apt-get install -y stow ;;
        pacman) sudo pacman -S --noconfirm stow ;;
        dnf)    sudo dnf install -y stow ;;
        *)      brew install stow ;;
      esac ;;
  esac
}

# ---------------------------------------------------------------------------
# Actions
# ---------------------------------------------------------------------------
clone_or_update() {
  if [[ -d "$INSTALL_DIR/.git" ]]; then
    info "Updating existing repo..."
    git -C "$INSTALL_DIR" pull --ff-only
    git -C "$INSTALL_DIR" submodule update --remote --merge
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
      local distro
      distro=$(detect_distro)
      case "$distro" in
        apt)    install_apt_pkgs ;;
        pacman) install_pacman_pkgs ;;
        dnf)    install_dnf_pkgs ;;
      esac
      # Brew as a secondary source for tools not in system repos
      if command -v brew >/dev/null 2>&1 || [[ "$OS" == macos ]]; then
        install_brew
        install_brew_pkgs
      fi
      ;;
  esac
}

do_link() {
  install_stow
  bash "$INSTALL_DIR/link.sh"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
OS=$(detect_os)
CMD="${1:-install}"

case "$CMD" in
  install)
    clone_or_update
    install_packages
    do_link
    success "Install complete. Open a new shell to apply changes."
    ;;
  update)
    clone_or_update
    do_link
    success "Update complete."
    ;;
  link)
    INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    do_link
    success "Configs linked."
    ;;
  *)
    echo "Usage: bootstrap.sh [install|update|link]"
    exit 1
    ;;
esac
