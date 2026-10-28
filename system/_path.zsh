# MacPorts first on legacy Intel so it beats any /usr/local leftovers.
if [[ -x /opt/local/bin/port ]]; then
  export PATH="/opt/local/bin:/opt/local/sbin:./bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$ZSH/bin:$PATH"
else
  export PATH="./bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$ZSH/bin:$PATH"
fi
export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"
