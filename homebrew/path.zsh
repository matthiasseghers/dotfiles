# The package prefix for this Mac, and the one place the zsh files detect it.
# The prefix follows the hardware: Homebrew supports Apple Silicon only, so
# silicon means /opt/homebrew and anything else means MacPorts owns the CLI
# tools (/opt/local). hw.optional.arm64 is hardware truth - unlike uname -m,
# a Rosetta shell cannot fake it. ~/.localrc may override the result.
if [[ -z "$DOTFILES_PKG_PREFIX" ]]; then
  if [[ "$(sysctl -n hw.optional.arm64 2>/dev/null)" == "1" ]]; then
    DOTFILES_PKG_PREFIX=/opt/homebrew
  else
    DOTFILES_PKG_PREFIX=/opt/local
  fi
fi
export DOTFILES_PKG_PREFIX
export PATH="$DOTFILES_PKG_PREFIX/bin:$DOTFILES_PKG_PREFIX/sbin:$PATH"
