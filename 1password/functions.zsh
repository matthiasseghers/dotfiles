# 1Password backup for machine-local files (optional): secrets plus the
# folder-scoped git identities, which are not secrets but are equally
# annoying to rebuild by hand. Loaded only when the `op` CLI is installed.
# These files never go into Mackup or the dotfiles repo — they travel as
# one tgz Document.

(( $+commands[op] )) || return

# Machine-local files, relative to $HOME (keep in sync with README).
typeset -ga _local_backup_files=(
  .localrc
  .ssh/config.local
  .config/1Password/ssh/agent.toml
  .local/share/atuin/key
  .gitconfig.identities
)

# Also backed up, matched by glob: every folder-scoped identity file
# (~/.gitconfig-<label>). Labels vary per machine, hence the glob.
# ~/.gitconfig.local is excluded on purpose — bootstrap regenerates it
# from the name/email prompt.
typeset -ga _local_backup_globs=(
  '.gitconfig-*'
)

# Print existing files matched by $_local_backup_globs, relative to $HOME.
_local_backup_glob_matches () {
  setopt local_options null_glob
  local g p
  for g in $_local_backup_globs; do
    for p in $HOME/$~g; do
      [[ -f $p ]] && print -r -- ${p#$HOME/}
    done
  done
}

# Print every backup target that currently exists, relative to $HOME.
_local_backup_present () {
  local f
  for f in $_local_backup_files; do
    [[ -f $HOME/$f ]] && print -r -- $f
  done
  _local_backup_glob_matches
}

# Pack the files that exist into one tgz Document in 1Password.
local-backup () {
  local -a present=("${(@f)$(_local_backup_present)}")
  # (@f) keeps one empty element when the helper prints nothing.
  present=(${present:#})
  if (( ! $#present )); then
    print -u2 "local-backup: no machine-local files found, nothing to do"
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
  local -a globbed=("${(@f)$(_local_backup_glob_matches)}")
  for f in $_local_backup_files; do
    [[ -e $HOME/$f ]] && existing+=("$f")
    mkdir -p "$HOME/${f:h}"
  done
  # Identity files are already in $HOME; only existing ones can conflict.
  for f in ${globbed:#}; do existing+=("$f"); done
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
  # Recompute the glob matches: on a fresh machine nothing matched before
  # the extraction, so the pre-restore list would miss the restored files.
  local -a restored=("${(@f)$(_local_backup_glob_matches)}")
  for f in $_local_backup_files ${restored:#}; do
    [[ -f $HOME/$f ]] && chmod 600 "$HOME/$f"
  done
  return $tar_status
}
