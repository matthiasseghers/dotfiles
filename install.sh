#!/bin/sh

# Check if installed in correct folder before installing.
INSTALL_DIR="$HOME/.dotfiles"
if [ "$(dirname "$0")" != "$INSTALL_DIR" ]; then
    echo "Please install in $INSTALL_DIR and rerun the install script."
    exit 1
fi

# Zsh
$INSTALL_DIR/zsh/install.sh
$INSTALL_DIR/git/install.sh
$INSTALL_DIR/homebrew/install.sh
$INSTALL_DIR/composer/install.sh

# XCode Command Line Tools
if ! command -v xcode-select &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
fi
