#!/usr/bin/env bash
#
# Shared output formatting functions for dotfiles scripts.
# Source this file at the top of any script that needs formatted output.
#
# Usage:
#   source "$(cd "$(dirname "$0")/.." && pwd -P)/script/lib/output.sh"

info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}
