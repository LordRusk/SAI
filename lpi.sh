#!/bin/sh

# Make sure git is installed to download custom repo
pacman --noconfirm -S git

# Download custom repo
cd ../
git clone https://www.github.com/LordRusk/rskrepo
cd rskrepo
cp pacman.conf /etc/pacman.conf

# Install needed script packages
pacman --noconfirm -Sy dash neovim slmenu

# Make a symbolic link of dash at /usr/bin/sh
ln -sfT dash /usr/bin/sh

# Launch the real script
sh lpi2.sh
