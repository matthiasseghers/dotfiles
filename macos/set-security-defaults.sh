#!/usr/bin/env bash
# Requires the login password immediately after screen lock (macOS 13+).
#
# `defaults write com.apple.screensaver` no longer works for this; sysadminctl
# is the only supported path, and it needs an admin session. The script
# therefore runs as the invoking user, not root: `-password -` makes
# sysadminctl ask for the login password itself. Bootstrap pipes this script's
# output, so the prompt reads from /dev/tty instead of the consumed stdin.
#
# Warn, never fail: a declined prompt, a non-interactive run or a status that
# does not confirm leaves the setting untouched. The script then prints the
# manual command and exits 0, so bootstrap keeps going.
#
# Manual:
#   sysadminctl -screenLock immediate -password -
# Verify:
#   sysadminctl -screenLock status

set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "set-security-defaults.sh is macOS only" >&2
  exit 1
fi

manual_hint () {
  echo "screen lock not confirmed - apply it manually:"
  echo "  sysadminctl -screenLock immediate -password -"
  echo "verify with: sysadminctl -screenLock status"
}

if { sysadminctl -screenLock immediate -password - < /dev/tty; } 2>/dev/null; then
  # Read-only check; when it needs more rights than this session has it
  # reports "Password is required!" (or nothing) instead of prompting, because
  # it was given no password argument. In that case the attempt's exit status
  # is the only evidence, so it is trusted and the user gets the check command.
  status="$(sysadminctl -screenLock status 2>/dev/null < /dev/null || true)"
  case "$status" in
    *immediate*)
      echo "password required immediately after screen lock"
      ;;
    ''|*"Password is required"*)
      echo "screen lock set - verify with: sysadminctl -screenLock status"
      ;;
    *)
      manual_hint
      ;;
  esac
else
  manual_hint
fi

exit 0
