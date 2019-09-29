#!/bin/bash

### FUNCTIONS ###

error() { printf "Something went wrong, maybe it was the script, maybe it was you, who knows."; exit; }

welcome() { \
	dialog --title "Welcome to the second part of LPI" --msgbox "Welcome to the second half of LPI, where LPI configures, isntalls, and gets your new install up and to the point where all you have to do is install a WM/DE. Ready to get started?" 10 50
}

confdrive() {
	dialog --title "Confirm drive" "Please confirm the drive you installed choose to intall arch on..." 7 14

	fdisk -l

	PS3='Choose a drive: '
	options=("/dev/sda/" "/dev/sdb/" "/dev/sdc/" "/dev/sdd/" "/dev/sd0")
	select opt in "${options[@]}"
	do
		case $opt in
			"/dev/sda/")
				drive="/dev/sda"
				break
			;;
			"/deb/sdb/")
				drive="/dev/sdb"
				break
			;;
			"/dev/sdc/")
				drive="/dev/sdc"
				break
			;;
			"/dev/sdd/")
				drive="/dev/sdd"
				break
			;;
			"/dev/sd0/")
				drive="/dev/sd0/"
				break
			;;
			*) echo "invalid option $REPLY";;
		esac
	done
}

locale() {
	dialog --title " locale" --msgbox "In order for your system, to work properly you are going to need to configure your locale. Uncomment (remove the #) which locale is yours. (If you live in america then uncomment '#en-US.UTF-8 UTF-8'" 15 40

	vim /etc/locale.gen
	locale-gen
}

grub() {
	dialog --title "grub" --msgbox "When installing Arch, you need a boot manager to actually boot into your install. One of the most popular, and the one we are going to be installing is called grub." 10 40

	mkdir /boot/efi
	mount /dev/sda1 /boot/efi
	grub-install --target=x86_64-efi --bootloader-id=grub-uefi --recheck
	mkdir /boot/grub/locale
	cp  /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
	grub-mkconfig -o /boot/grub/grub.cfg

	dialog --title -grub "installation done" -msgbox "Grub has been successfuly installed" 7 15
}

getuserandpass() {
	dialog --title "Creating a user" --msgbox "Next LPI is going to help you create a user" 7 30

	name=$(dialog --inputbox "First, please enter a name for the user account." 10 60 3>&1 1>&2 2>&3 3>&1) || exit
	while ! echo "$name" | grep "^[a-z_][a-z0-9_-]*$" >/dev/null 2>&1; do
		name=$(dialog --no-cancel --inputbox "Username not valid. Give a username beginning with a letter, with only lowercase letters, - or _." 10 60 3>&1 1>&2 2>&3 3>&1)
	done
	pass1=$(dialog --no-cancel --passwordbox "Enter a password for that user." 10 60 3>&1 1>&2 2>&3 3>&1)
	pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
	while ! [ "$pass1" = "$pass2" ]; do
		unset pass2
		pass1=$(dialog --no-cancel --passwordbox "Passwords do not match.\\n\\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
		pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
	done ;

	dialog --title "Root password" --msgbox "You must set the root password, just incase anything ever goes wrong with your user, you can log into root and fix it. NOTE: Set the root password to something other than your main password" 10 40

	passwd
}

### THE ACTUAL SCRIPT ###

### this is how everything happens ###

# Welcome the user to section 2 of LPI
welcome || error "User Exited."

# Confirm the $drive variable for installation of grub
confdrive || error "User Exited."

# Configure the locale
locale || error "User Exited."

# Install and configure grub
grub || error "User Exited."

# Make user
getuserandpass || error "User Exited."
echo 'epic'


