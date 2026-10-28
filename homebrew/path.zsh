# MacPorts on legacy Intel, Homebrew on Apple Silicon.
if [[ -x /opt/local/bin/port ]]; then
  export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
else
  export PATH="/opt/homebrew/bin:$PATH"
fi
