#!/bin/sh

# Check if installed in correct folder before installing.
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)
if [ "$(dirname $DOTFILES_ROOT)" = $HOME ]; then
	echo "located in home"
else
	echo "please install in home and rerun the install script."
fi

# Zsh
$DOTFILES_ROOT/zsh/install.sh
$DOTFILES_ROOT/homebrew/install.sh
$DOTFILES_ROOT/git/install.sh
$DOTFILES_ROOT/composer/install.sh

# XCode Command Line Tools
if test ! $(which xcode-select); then
	echo "Installing Xcode..."
	xcode-select --install
fi
