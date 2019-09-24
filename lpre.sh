#!/bin/bash

echo "Hello, and welcome to LLARBS (Luke's Lazy Auto Ricing Bootstrapping Scripts), this is a fork of LARBS made by Luke Smith (lukesmith.xyz) and adds this pre dialog install process, making it even easier to get Luke's Rice up and running."
echo "What LPI (lazy pre-install) does is, after you format your partitions and install the base arch, it will install everything needed to run LARBS. Check the readme.md here and at github (github.com/LordRusk/LLARBS) for instructions for how to partition and format (not that you should need it.)"
echo "Would you like to proceed? y/n:"
read choice

if [[ $choice == "y" ]]; then
	sudo pacman -S base-devel grub vim ranger efibootmgr dosfstools os-prober mtools network-manager-applet networkmanager wireless_tools wpa_supplicant dialog
	echo "In this file are a bunch of locals, you are going to need to uncomment (remove the hashtag) of which ever locale is where you live, if you don't know which one, just uncomment "en_US.UTF-8 UTF-8" and save the file: Press any button to continue"
	read waet

	nano /etc/locale.gen
	locale-gen

	echo "Configuring grub"
	mkdir /boot/efi
	mount /dev/sda1 /boot/efi
	grub-install --target=x86_64-efi --bootloader-id=grub-uefi --recheck
	mkdir /boot/grub/locale
	cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
	grub-mkconfig -o /boot/grub/grub.cfg

	echo "Now we are going to set the root password, just incase something messes up. NOTE: make it different from your password for your user later in the install"
	passwd root

	echo "Now downloading LARBS"
	curl -LO larbs.xyz/larbs.sh

	echo "Start LARBS now? y/n:"
	read choice2

	if [[ $choice2 == "y" ]]; then
		sh larbs.sh
	elif [[ $choice2 == "n" ]]; then
		echo "Okay, exiting"
	fi
elif [[ $choice == "n" ]]; then
	echo "Okay, exiting"
fi

