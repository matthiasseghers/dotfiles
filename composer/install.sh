#!/bin/sh

## Install composer
if test ! $(which composer); then
	echo 'Install composer'
	brew install composer
fi

exit 0
