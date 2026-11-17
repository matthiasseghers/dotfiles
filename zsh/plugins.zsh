# Load zsh plugins installed via MacPorts or Homebrew. The prefix is declared
# per machine (an optional ~/.localrc override) and otherwise defaulted from
# the hardware in homebrew/path.zsh, which always runs before this file.
# HOMEBREW_PREFIX is deliberately not set here - it belongs to `brew shellenv`,
# and overriding it breaks a machine with both installed.
if [ -f "$DOTFILES_PKG_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$DOTFILES_PKG_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [ -f "$DOTFILES_PKG_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$DOTFILES_PKG_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
