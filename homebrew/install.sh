#!/bin/sh
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.
#
# Legacy Intel: Homebrew is gone on those machines, so this exits immediately.

root="$(cd "$(dirname "$0")/.." && pwd -P)"

if [ -f "$root/script/lib/legacy-intel.sh" ]; then
  # shellcheck source=script/lib/legacy-intel.sh
  # shellcheck disable=SC1091
  . "$root/script/lib/legacy-intel.sh"
fi

if [ "${DOTFILES_LEGACY_INTEL:-0}" = "1" ]; then
  echo "› legacy Intel - Homebrew skipped (MacPorts owns the CLI tools)"
  exit 0
fi

# Check for Homebrew
if ! command -v brew >/dev/null 2>&1
then
  echo "  Installing Homebrew for you."

  # Install the correct homebrew for each OS type
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Make brew usable in this process (the installer does not touch the PATH)
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

exit 0
