#!/usr/bin/env bash
#
# Symlink ssh/config to ~/.ssh/config

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

src="$DOTFILES_ROOT/ssh/config"
dst="$HOME/.ssh/config"

if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
  echo "  skipped $dst (already linked)"
elif [ -e "$dst" ]; then
  echo "  backing up $dst → ${dst}.backup"
  mv "$dst" "${dst}.backup"
  ln -s "$src" "$dst"
  echo "  linked $src to $dst"
else
  ln -s "$src" "$dst"
  echo "  linked $src to $dst"
fi
