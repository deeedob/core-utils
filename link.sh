#!/usr/bin/env bash
# link.sh — Symlink core-utils configs to $HOME using GNU Stow.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: GNU stow is required." >&2
  echo "  macOS:  brew install stow" >&2
  echo "  Debian: apt install stow" >&2
  echo "  Arch:   pacman -S stow" >&2
  exit 1
fi

echo "Linking core-utils → $HOME"
stow --verbose=1 --restow --dir="$SCRIPT_DIR" --target="$HOME" dot

# Ensure required XDG state/cache dirs exist
for d in \
  "$HOME/.local/bin" \
  "$HOME/.local/share" \
  "$HOME/.local/state/zsh" \
  "$HOME/.local/state/less" \
  "$HOME/.local/state/python" \
  "$HOME/.cache/zsh"; do
  [[ -d "$d" ]] || mkdir -p "$d"
done

echo "Done. Open a new shell or: source ~/.zshenv"
