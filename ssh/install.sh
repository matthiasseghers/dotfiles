#!/usr/bin/env bash
#
# Symlink ssh/config to ~/.ssh/config

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
# shellcheck disable=SC1091
source "$DOTFILES_ROOT/script/lib/output.sh"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

src="$DOTFILES_ROOT/ssh/config"
dst="$HOME/.ssh/config"

if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
  success "skipped ${src#"$HOME/"} → ${dst#"$HOME/"}"
elif [ -e "$dst" ]; then
  info "backing up ${dst#"$HOME/"}"
  mv "$dst" "${dst}.backup"
  ln -s "$src" "$dst"
  success "linked ${src#"$HOME/"} → ${dst#"$HOME/"}"
else
  ln -s "$src" "$dst"
  success "linked ${src#"$HOME/"} → ${dst#"$HOME/"}"
fi
