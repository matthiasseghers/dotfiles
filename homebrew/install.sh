#!/bin/sh
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

BREWTAPS=(
  shivammathur/php
)

BREWAPPS=(
  wget
  mackup
  php@8.0
  openssl
  httpd
  ripgrep
)

# Check for Homebrew
if test ! $(which brew); then
  echo "Installing Homebrew for you."

  # Install the correct homebrew for each OS type
  if test "$(uname)" = "Darwin"; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  elif test "$(expr substr $(uname -s) 1 5)" = "Linux"; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
  fi

fi

## Install (brew) apps
echo "Adding brew taps..."
brew tap ${BREWTAPS[@]}
echo "Installing Applications..."
brew install ${BREWAPPS[@]}

exit 0
