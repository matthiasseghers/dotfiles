#!/usr/bin/env bash
#
# Legacy Intel support for the brew entry points and the Intel install paths.
#
# All legacy-Intel behavior keys off DOTFILES_LEGACY_INTEL (1 = Intel Mac,
# 0 = Apple Silicon or any non-Darwin host). This file is the single arch
# check: delete it and every guarded source line becomes a no-op, which turns
# legacy support off without touching the callers.
#
# hw.optional.arm64=1 means Apple Silicon; anything else (0/missing) on Darwin
# is Intel. Never use uname -m here: a Rosetta terminal reports x86_64 on
# Apple Silicon.
#
# Usage:
#   DOTFILES_ROOT="$(pwd -P)"
#   if [ -f "$DOTFILES_ROOT/script/lib/legacy-intel.sh" ]; then
#     . "$DOTFILES_ROOT/script/lib/legacy-intel.sh"
#   fi
#
# Bash 3.2 compatible; POSIX sh.

# shellcheck disable=SC2034 # consumed by the scripts that source this file
if [ "$(uname -s)" = "Darwin" ] && [ "$(sysctl -n hw.optional.arm64 2>/dev/null)" != "1" ]; then
  DOTFILES_LEGACY_INTEL=1
else
  DOTFILES_LEGACY_INTEL=0
fi

# Print the repo root: $DOTFILES_ROOT when set, otherwise $PWD. Same rule as
# groups.sh; kept private so sourcing both files cannot clash.
_dotfiles_legacy_intel_root() {
  if [ -n "${DOTFILES_ROOT:-}" ]; then
    printf '%s\n' "$DOTFILES_ROOT"
  else
    printf '%s\n' "$PWD"
  fi
}

# Install every port listed in $DOTFILES_ROOT/Portsfile (one port per line,
# '#' starts a comment). port install is idempotent, so re-running is safe;
# sudo prompts once per port. Fails when the Portsfile is missing.
dotfiles_intel_install_ports() {
  local root line port
  root="$(_dotfiles_legacy_intel_root)"
  if [ ! -f "$root/Portsfile" ]; then
    echo "› Portsfile not found at $root/Portsfile" >&2
    return 1
  fi
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="$(printf '%s' "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [ -n "$line" ] || continue
    port="$line"
    echo "› port install $port"
    sudo port install "$port"
  done < "$root/Portsfile"
}
