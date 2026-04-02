# Load zsh plugins installed via Homebrew
if [[ "$(uname -m)" == "arm64" ]]; then
  HOMEBREW_PREFIX="/opt/homebrew"
else
  HOMEBREW_PREFIX="/usr/local"
fi

if [ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
