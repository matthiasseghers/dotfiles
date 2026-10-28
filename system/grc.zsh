# GRC colorizes nifty unix tools all over the place
if (( $+commands[grc] )) && (( $+commands[brew] ))
then
  source `brew --prefix`/etc/grc.zsh
elif [[ -x /opt/local/bin/port ]] && [[ -f /opt/local/etc/grc.zsh ]]
then
  # MacPorts path - verify on the Intel machine after `port install grc`.
  source /opt/local/etc/grc.zsh
fi
