# zoxide: smarter cd (z command)
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi
