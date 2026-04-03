#!/usr/bin/env bash
# Sets reasonable macOS defaults.
#
# Or, in other words, set shit how I like in macOS.
#
# The original idea (and a couple settings) were grabbed from:
#   https://github.com/mathiasbynens/dotfiles/blob/master/.macos
#
# Run ./set-defaults.sh and you'll be good to go.

# Ask for account password upfront (needed for sysadminctl below)
echo "Enter your account password (used to configure screen lock):"
read -rs account_password
echo ''

# Disable press-and-hold for keys in favor of key repeat.
defaults write -g ApplePressAndHoldEnabled -bool false

# Always open everything in Finder's list view. This is important.
defaults write com.apple.finder FXPreferredViewStyle Nlsv

# Show the ~/Library folder.
chflags nohidden ~/Library

# Set a really fast key repeat.
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Set the Finder prefs for showing a few different volumes on the Desktop.
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Run the screensaver if we're in the bottom-left hot corner.
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

# Avoid creating .DS_Store files on network or USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Show all file extensions in Finder.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable auto-substitution of period on double-space.
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Show Finder status bar and path bar.
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Search the current folder by default in Finder.
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Require password immediately after screen lock (macOS 13+).
# Note: defaults write com.apple.screensaver no longer works for this.
echo "$account_password" | sysadminctl -screenLock immediate -password -

# Apply changes
killall Dock
killall Finder
