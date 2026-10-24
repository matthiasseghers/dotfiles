#!/usr/bin/env bash
#
# Shared output formatting functions for dotfiles scripts.
# Source this file at the top of any script that needs formatted output.
#
# The tags are Holman's ([ .. ] [ ?? ] [ OK ] [FAIL]), extracted verbatim
# from his bootstrap. Colors and cursor control are emitted only when
# stdout is a terminal; NO_COLOR turns them off everywhere, so piped
# output (tests, tee, CI logs) stays plain and greppable.
#
# Usage:
#   source "$(cd "$(dirname "$0")/.." && pwd -P)/script/lib/output.sh"

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_INFO=$'\033[00;34m'
  C_ASK=$'\033[0;33m'
  C_OK=$'\033[00;32m'
  C_WARN=$'\033[0;33m'
  C_FAIL=$'\033[0;31m'
  C_RESET=$'\033[0m'
  C_CR=$'\r'          # overwrite the in-progress info line
  C_CLEAR=$'\033[2K'  # wipe it first (success/fail replace an info line)
else
  C_INFO='' C_ASK='' C_OK='' C_WARN='' C_FAIL='' C_RESET='' C_CR='' C_CLEAR=''
fi

info () {
  printf '%s  [ %s..%s ] %s\n' "$C_CR" "$C_INFO" "$C_RESET" "$1"
}

user () {
  printf '%s  [ %s??%s ] %s\n' "$C_CR" "$C_ASK" "$C_RESET" "$1"
}

success () {
  printf '%s%s  [ %sOK%s ] %s\n' "$C_CR" "$C_CLEAR" "$C_OK" "$C_RESET" "$1"
}

warn () {
  printf '%s  [%sWARN%s] %s\n' "$C_CR" "$C_WARN" "$C_RESET" "$1"
}

fail () {
  printf '%s%s  [%sFAIL%s] %s\n' "$C_CR" "$C_CLEAR" "$C_FAIL" "$C_RESET" "$1"
  echo ''
  exit 1
}
