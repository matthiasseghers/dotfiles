# fzf: fuzzy finder
if (( $+commands[fzf] )); then
  # Atuin owns Ctrl-R (atuin/ loads before fzf/ alphabetically, and fzf would
  # rebind it). fzf >= 0.48 skips its Ctrl-R binding when this is empty.
  FZF_CTRL_R_COMMAND=

  # fd-backed sources: include hidden files, exclude .git
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --hidden --exclude .git --type d'
  fi

  source <(fzf --zsh)
fi
