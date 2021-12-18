#!/bin/sh

# Add global gitignore
ln -sf $HOME/.dotfiles/git/.global-gitignore $HOME/.gitignore

# Git
if test ! $(which git); then
	echo "Installing Git..."
	brew install git
fi

echo $DOTFILES_ROOT
exit 0

# Setup Git
if [[ ! -f $HOME/.gitignore ]]; then
	echo "Configure Git..."
	read -p 'Git Username: ' GIT_USERNAME
	read -p 'Git email: ' GIT_EMAIL
	git config --global user.name "$GIT_USERNAME" # add github account
	git config --global user.email $GIT_EMAIL     # add github email
	git config --global core.excludesFile $HOME/.gitignore
fi

exit 0
