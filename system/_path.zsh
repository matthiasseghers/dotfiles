# MacPorts first on legacy Intel so it beats any /usr/local leftovers.
# (No ./bin: a relative entry is inherited from holman and shadows commands
# with whatever the current directory holds; $ZSH/bin already covers repo tools.)
if [[ -x /opt/local/bin/port ]]; then
  export PATH="/opt/local/bin:/opt/local/sbin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$ZSH/bin:$PATH"
else
  export PATH="$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$ZSH/bin:$PATH"
fi
export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"
