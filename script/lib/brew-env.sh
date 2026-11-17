#!/usr/bin/env bash
#
# Load Homebrew into PATH when it is installed but not visible to this process.
#
# homebrew/install.sh runs as a child, so its shellenv eval never reaches the
# caller; a stale terminal or a direct script/install starts without brew on
# PATH and would die on `brew bundle`. This helper fixes the current process
# only - it never installs anything.
#
# Usage:
#   DOTFILES_ROOT="$(pwd -P)"
#   . "$DOTFILES_ROOT/script/lib/brew-env.sh"
#   dotfiles_brew_shellenv
#
# Bash 3.2 compatible; POSIX sh.

# No-op when brew is already on PATH or not installed at all. Apple Silicon
# first, then the Intel prefix.
dotfiles_brew_shellenv() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  return 0
}
