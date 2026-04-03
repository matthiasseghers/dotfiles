#!/usr/bin/env bash
#
# Symlink starship/starship.toml to ~/.config/starship.toml

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
# shellcheck disable=SC1091
source "$DOTFILES_ROOT/script/lib/output.sh"

mkdir -p "$HOME/.config"

src="$DOTFILES_ROOT/starship/starship.toml"
dst="$HOME/.config/starship.toml"

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
