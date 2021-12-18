#!/bin/bash
# Run all dotfiles installers.

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

function bootstrapTerminal() {
	sudo -v
	source ~/.dotfiles/installscript
}

echo 'Bootstrap terminal'
echo '------------------'
echo 'This will reset your terminal. Continue? (y/n) '
read -p 'Answer: ' reply

if [[ $reply =~ ^[Yy]$ ]]; then
	bootstrapTerminal
fi
