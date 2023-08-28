#!/bin/sh

# Define the list of PECL packages to install
pecl_packages=("xdebug" "redis")

# Install PECL packages if they are not already installed
for package in "${pecl_packages[@]}"; do
    if ! pecl list | grep -q "$package"; then
        echo "Installing $package..."
        pecl install "$package"
    else
        echo "$package is already installed."
    fi
done

exit 0
