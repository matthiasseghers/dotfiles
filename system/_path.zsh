# Package binaries come first via homebrew/path.zsh, which puts the detected
# prefix's bin (and sbin) at the front.
# (No ./bin: a relative entry is inherited from holman and shadows commands
# with whatever the current directory holds; $ZSH/bin already covers repo tools.)
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$ZSH/bin:$PATH"
export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"
