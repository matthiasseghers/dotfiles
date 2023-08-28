#!/bin/sh

# Install oh-my-zsh
if [ -d "~/.oh-my-zsh" ]; then
	echo "Installing oh-my-zsh"
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
	echo "oh-my-zsh already installed."
fi

# Add zsh prefs
ln -sf $HOME/.dotfiles/zsh/.zshrc $HOME/.zshrc
# Add aliases
ln -sf $HOME/.dotfiles/zsh/.zshaliases $HOME/.zshaliases
# Add secret aliases, for stuff you don't want to share
touch $HOME/.zshaliases-secret

exit 0
