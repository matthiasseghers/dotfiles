# 1Password backup for machine-local secret files (optional).
# Loaded only when the `op` CLI is installed. Secrets never go into
# Mackup or the dotfiles repo — they travel as one tgz Document.

(( $+commands[op] )) || return

# Machine-local secret files, relative to $HOME (keep in sync with README).
typeset -ga _local_backup_files=(
  .localrc
  .ssh/config.local
  .config/1Password/ssh/agent.toml
  .local/share/atuin/key
)

# Pack the files that exist into one tgz Document in 1Password.
local-backup () {
  local -a present=()
  local f
  for f in $_local_backup_files; do [[ -f $HOME/$f ]] && present+=("$f"); done
  if (( ! $#present )); then
    print -u2 "local-backup: no machine-local secret files found, nothing to do"
    return 1
  fi
  local title="${DOTFILES_BACKUP_NAME:-dotfiles: $(scutil --get LocalHostName)}"
  print "local-backup: packing ${present[*]}"
  local -a op_cmd
  if op item get "$title" >/dev/null 2>&1; then
    op_cmd=(op document edit "$title" - --file-name machine-local.tgz)
  else
    op_cmd=(op document create - --title "$title" --file-name machine-local.tgz)
  fi
  tar -czf - -C "$HOME" "${present[@]}" | "$op_cmd[@]"
}

# Restore a backup Document into $HOME (default: this machine's title;
# pass another machine's title to restore that backup instead).
# Refuses to overwrite existing files — move them aside first.
local-restore () {
  local title="${1:-${DOTFILES_BACKUP_NAME:-dotfiles: $(scutil --get LocalHostName)}}"
  local f tar_status=0
  local -a existing=()
  for f in $_local_backup_files; do
    [[ -e $HOME/$f ]] && existing+=("$f")
    mkdir -p "$HOME/${f:h}"
  done
  if (( $#existing )); then
    print -u2 "local-restore: refusing to overwrite: ${existing[*]} — move aside and re-run"
    return 1
  fi
  print "local-restore: restoring $title"
  op document get "$title" | tar -xzkf - -C "$HOME"
  tar_status=$?
  # $pipestatus[1] is op's exit status; without this a failed `op document
  # get` would look like a successful (empty) restore, because bsdtar
  # exits 0 on empty input.
  (( pipestatus[1] )) && tar_status=$pipestatus[1]
  for f in $_local_backup_files; do [[ -f $HOME/$f ]] && chmod 600 "$HOME/$f"; done
  return $tar_status
}
