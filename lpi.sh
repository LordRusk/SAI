#!/bin/sh

# Make sure git is installed to download custom repo
pacman --noconfirm -S git

# Download custom repo
cd ../
git clone https://www.github.com/LordRusk/rskrepo
cd rskrepo
cp pacman.conf /etc/pacman.conf

# Install needed script packages
pacman --noconfirm -Sy dash neovim slmenu gawk grep

# Launch the real script
cd ../LPI
dash lpi2.sh
