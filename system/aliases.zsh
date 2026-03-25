# eza replaces ls
if (( $+commands[eza] ))
then
  alias ls='eza --color=auto'
  alias l='eza -lah'
  alias ll='eza -l'
  alias la='eza -a'
  alias lt='eza --tree'
fi

# Navigation
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'

# Shortcuts
alias p='cd ~/Projects'
alias pw='cd ~/Projects/Work'
alias pp='cd ~/Projects/Private'

# Sudo
alias please='sudo'

# Network
alias ip-public='curl -s https://api.ipify.org && echo'
alias ip-local="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# SSH - public keys are stored in 1Password; copy from the app UI

# macOS
alias o='open .'
alias cleanup='find . -name "*.DS_Store" -delete && echo "Cleaned .DS_Store files"'