#!/bin/sh

# Determine the installation directory based on the environment
if [ -n "$GITHUB_ACTIONS" ]; then
    # GitHub Actions runner
    INSTALL_DIR="$GITHUB_WORKSPACE"
else
    # Non-GitHub Actions environment
    INSTALL_DIR="$HOME"
fi

# Debug: Print out relevant variables
echo "GITHUB_WORKSPACE: $GITHUB_WORKSPACE"
echo "Script's directory: $(dirname "$0")"
echo "Expected INSTALL_DIR: $INSTALL_DIR"

# Change directory to the script's directory
cd "$(dirname "$0")"

# Check if installed in the correct folder before installing.
if [ "$GITHUB_WORKSPACE" != "$INSTALL_DIR" ]; then
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
