# List all Launch Agents and Daemons
alias launchitems="launchctl list | grep -v com.apple"

# Open current directory in Finder
alias o='open .'

# Remove all .DS_Store files recursively
alias cleanup='find . -name "*.DS_Store" -delete && echo "Cleaned .DS_Store files"'

# Toggle hidden files in Finder
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'

# Update all Homebrew packages
alias brewup='brew update && brew upgrade && brew cleanup'
