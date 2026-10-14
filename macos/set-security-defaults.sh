#!/usr/bin/env bash
# Sets macOS defaults that require administrator privileges.
#
# Run with sudo or allow the script to self-elevate.

set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "set-security-defaults.sh is macOS only" >&2
  exit 1
fi

# Self-elevate if not running as root.
if [ "$(id -u)" -ne 0 ]; then
  echo "Re-running with sudo…" >&2
  exec sudo "$0" "$@"
fi

# Require password immediately after screen lock (macOS 13+).
# Note: defaults write com.apple.screensaver no longer works for this.
sysadminctl -screenLock immediate
