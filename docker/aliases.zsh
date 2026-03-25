alias d='docker'
alias d-c='docker compose'
alias d-ps='docker ps'

d-nuke() {
  echo "This will remove all stopped containers, networks, images, and volumes."
  printf "  Are you sure? [y/N] "
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    docker system prune --all --volumes --force
  else
    echo "Aborted."
  fi
}
