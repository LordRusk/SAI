#!/bin/bash

### FUNCTIONS ###

error() { printf "Something went wrong, maybe it was the script, maybe it was you, who knows."; exit; }

welcome() {
	dialog --title "Welcome to the second part of LPI" --msgbox "Welcome to the second half of LPI, where LPI configures, isntalls, and gets your new install up and to the point where all you have to do is install a WM/DE. Ready to get started?" 10 50
}

locale() {
	dialog --locale --msgbox "First LPI need to configure your location and time, but you have to specify a timezone to do so. When the text editor opens, uncomment (remove the #) your timeszone. If you don't know which one, uncomment '#en-US. UTF-8 UTF-8'"

	vim /etc/locale.gen
	locale-gen
}

grub() { \
	dialog --title "grub" --msgbox "When installing Arch, you need a boot manager to actually boot into your install. One of the most popular, and the one we are going to be installing is called grub." 10 40

	mkdir /boot/efi
	mount /dev/sda1 /boot/efi
	grub-install --target=x86_64-efi --bootloader-id=grub-uefi --recheck
	mkdir /boot/grub/locale
	cp  /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
	grub-mkconfig -o /boot/grub/grub.cfg

	dialog --title -grub "installation done" -msgbox "Grub has been successfuly installed" 7 15
}

### THE ACTUAL SCRIPT ###

### this is how everything happens ###

# Welcome the user to section 2 of LPI
welcome || error "User Exited."

# Configure and generate the locale
locale || error "User Exited."

# Install and configure grub
grub || error "User Exited."

echo 'epic'


