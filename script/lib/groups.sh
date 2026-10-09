#!/usr/bin/env bash
#
# Shared DOTFILES_GROUPS parsing for script/install and bin/dot-doctor.
#
# A group exists iff a Brewfile.<name> file sits in the repo root
# (Brewfile.lock.json files are never groups). Groups are requested via
# DOTFILES_GROUPS in ~/.localrc, space- or comma-separated.
#
# Usage:
#   DOTFILES_ROOT="$(pwd -P)"
#   source "$DOTFILES_ROOT/script/lib/groups.sh"
#
# Bash 3.2 compatible: no mapfile, no associative arrays.

# Print the repo root: $DOTFILES_ROOT when set, otherwise $PWD.
dotfiles_root() {
  if [ -n "${DOTFILES_ROOT:-}" ]; then
    printf '%s\n' "$DOTFILES_ROOT"
  else
    printf '%s\n' "$PWD"
  fi
}

# Print the available group names (every Brewfile.<name> in the repo
# root, excluding *.lock.json), one per line, sorted.
dotfiles_available_groups() {
  local root f base
  root="$(dotfiles_root)"
  for f in "$root"/Brewfile.*; do
    [ -e "$f" ] || continue
    case "$f" in
      *.lock.json) continue ;;
    esac
    base="${f##*/Brewfile.}"
    [ -n "$base" ] && printf '%s\n' "$base"
  done | sort
}

# Print the available group names on one space-separated line.
dotfiles_available_groups_line() {
  dotfiles_available_groups | paste -sd ' ' -
}

# Print the groups requested in $DOTFILES_GROUPS: split on spaces and/or
# commas, ignore empties, de-duplicate (first occurrence wins). One per
# line, in request order.
dotfiles_requested_groups() {
  local raw="${DOTFILES_GROUPS:-}"
  local seen="" g rest
  rest="${raw//,/ }"
  for g in $rest; do
    case ",$seen," in
      *,"$g",*) continue ;;
    esac
    seen="$seen,$g"
    printf '%s\n' "$g"
  done
}

# Print the requested groups that have no Brewfile.<name> in the repo
# root, one per line.
dotfiles_unknown_groups() {
  local root g
  root="$(dotfiles_root)"
  while IFS= read -r g; do
    [ -n "$g" ] || continue
    [ -f "$root/Brewfile.$g" ] || printf '%s\n' "$g"
  done < <(dotfiles_requested_groups)
}
