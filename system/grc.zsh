# GRC colorizes nifty unix tools all over the place. The prefix (and with it
# grc's own config) comes from homebrew/path.zsh - no `brew --prefix` fork here.
if (( $+commands[grc] )) && [[ -f "$DOTFILES_PKG_PREFIX/etc/grc.zsh" ]]
then
  source "$DOTFILES_PKG_PREFIX/etc/grc.zsh"
fi
