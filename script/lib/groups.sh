#!/usr/bin/env bash
#
# Shared DOTFILES_GROUPS parsing for script/install and bin/dot-doctor.
#
# A group exists iff a Brewfile.<name> file sits in the repo root
# (Brewfile.lock.json files are never groups). The selection lives in
# ~/.localgroups (space- or comma-separated, '#' starts a comment);
# $DOTFILES_GROUPS overrides it for a single run and for CI.
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

# Print the machine-local group selection file. This is the only place the
# path is defined — everything else calls this function.
dotfiles_groups_file() {
  printf '%s\n' "$HOME/.localgroups"
}

# Print where the effective selection came from: "env" ($DOTFILES_GROUPS is
# set and non-empty), "file" (~/.localgroups exists) or "none". This is the
# single precedence decision: dotfiles_requested_groups() consumes it, so the
# reported provenance can never disagree with what gets installed.
dotfiles_groups_source() {
  if [ -n "${DOTFILES_GROUPS:-}" ]; then
    printf 'env\n'
  elif [ -f "$(dotfiles_groups_file)" ]; then
    printf 'file\n'
  else
    printf 'none\n'
  fi
}

# Print the group names in $1: split on spaces and/or commas, ignore empties,
# de-duplicate (first occurrence wins). One per line, in request order.
_dotfiles_split_groups() {
  local raw="${1:-}"
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

# Print the groups listed in ~/.localgroups, one per line. Empty when the
# file is absent or holds no active line. Lines starting with '#' are
# comments, so system/localgroups.example can be copied verbatim and edited.
dotfiles_groups_from_file() {
  local file
  file="$(dotfiles_groups_file)"
  [ -f "$file" ] || return 0
  # sed must not abort the caller under set -e if the file vanishes mid-run.
  _dotfiles_split_groups "$(sed -e 's/#.*//' "$file" 2>/dev/null || true)"
}

# Print the effective groups: $DOTFILES_GROUPS when set, otherwise
# ~/.localgroups, otherwise nothing. One per line, in request order.
dotfiles_requested_groups() {
  case "$(dotfiles_groups_source)" in
    env)  _dotfiles_split_groups "${DOTFILES_GROUPS:-}" ;;
    file) dotfiles_groups_from_file ;;
    *)    return 0 ;;
  esac
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
