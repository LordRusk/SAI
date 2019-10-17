#!/bin/sh

### FUNCTIONS ###

error() { printf "Something went wrong, maybe it was the script, maybe it was you, who knows."; exit;}

xit() {
	xon=$(echo "Continue\\nExit" | slmenu -i -p "$xprompt")
	if [ "$xom" = "continue" ]; then
		echo "epic"
	elif [ "$xom" = "exit" ]; then
		exit
	fi
}

chosendrive() {
	clear
	echo "Please re-select the drive you installed arch on"

	echo ""
	lsblk
	cdrive=$(echo "/dev/sda\\n/dev/sdb\\n/dev/sdc\\n/dev/sdd" | slmenu -i -p "Choose a drive")
}

locale() {
	clear
	echo "Next we are going to be configuing your locale. First please enter your Region/City in that format"
	rc=$(echo "Region/City" | slmenu -p "Region/City")
	ln -sf /usr/share/zoneinfo/"$rc" /etc/localtime
	hwclock --systohc

	clear
	echo "Please uncoomment en_US.UTF-8 UTF-8 and other locals you may need"
	echo "Okay" | slmenu
	nvim /etc/locale.gen
	locale-gen
}

bootmanager() {
	echo "LPI automatically installs GRUB as it's boot manager, if you would not like to install grub, "
	echo "but install a different boot manager outside of LPI, select Exit, if not, continue."
	grb=$(echo "Install Grub\\nSkip" | slmenu -p "Install or skip")
	if [ grb = "Install Grub" ]; then
		mkdir /boot/efi
		mount "$drive"1 /boot/efi
		grub-install --target=x86_64-efi --bootloader-id=grub-uefi --recheck
		mkdir /boot/grub/locale
		cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
		grub-mkconfig -o /boot/grub/grub.cfg
	elif [ grb = "Skip" ]; then
		echo "ok"
	fi
}

### THE ACTUAL SCRIPT ###

# Re select the drive
chosendrive

# Generate the locale and get local time configured
locale
