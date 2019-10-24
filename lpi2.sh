#!/bin/dash

### FUNCTIONS ###

error() { printf "Spomething went wrong, maybe it was you, maybe it was the script, who knows"; exit; }

nxt() { echo "Next" | slmenu -p "Continue?"; }

xit() {
	xon=$(echo "Continue\nExit" | slmenu -i -p "$xprompt")
	if [ "$xom" = "continue" ]; then
		echo "epic"
	elif [ "$xom" = "exit" ]; then
		while [ "$xom" = "$zom" ]; do
			exit
		done
	fi
}

welcome() {
	clear
	echo "Welcome to LPI (lazy Pre Install)"
	echo "This script is to help you get arch installed by doing the hard stuff for you"
	echo "and leaves the rest up to you, ready to continue?"
	xprompt="Continue?"
	xit
}

formatdrive() {
	clear
	echo "Are are installing arch on an non EFI bios or an EFI bios."
	bs=$(echo "non EFI\nEFI" | slmenu -p "non EFI or EFI")

	clear
	echo "Please select the drive you would like to install arch on"
	sdrive=$(lsblk -lp | grep "disk $" | awk '{print $1, "(" $4 ")"}' | slmenu -i -p "Choose a drive")
	cdrive=$(echo "$sdrive" | awk '{print $1}')

	clear
	echo "How big do you want your root partition to be? Defualt is 30gb"
	rps=$(echo "30gb" | slmenu -i -p "Size of root partition")

	clear
	echo "How big do you want your swap partition? Defualt is 1.5x your ram"
	sps=$(echo "" | slmenu -i -p "Size of swap partition")

	clear
	echo "If you continue, the selected drive will be wiped, all data will be lost, do you want to continue?"
	xprompt="Are you sure you want to continue?"
	xit

	dd if=/dev/zero of="$cdrive"  bs=512  count=1
	echo -e "g\nn\np\n1\n\n+500mb\nn\np\n2\n\n+"$sps"\nn\np\n3\n\n+"$rps"\nn\np\n4\n\n\nw" | fdisk "$cdrive"

	if [ "$bs" = "EFI" ]; then
		mkfs.fat -F32 "$cdrive"1
	else
		mkfs.ext4 "$cdrive"1
	fi
	mkfs.ext4 "$cdrive"3
	mkfs.ext4 "$cdrive"4
	mount "$cdrive"3 /mnt
	mkdir /mnt/home
	mount "$cdrive"4 /mnt/home
	mkdir /mnt/boot
	if [ "$bs" = "EFI" ]; then
		mkdir /mnt/boot/efi
		mount "$cdrive"1 /mnt/boot/efi
	else
		mount "$cdrive"1 /mnt/boot
	fi

	mkswap "$cdrive"2
	swapon "$cdrive"2
}

mirrorlist() {
	clear
	echo "The defualt arch mirrorlist can be slow and unreliable, please edit the mirrorlist for faster speeds."
	nxt
	nvim /etc/pacman.d/mirrorlist
}

install() {
	clear
	echo "It's time to actually install arch, ready?"
	xprompt="Ready?"
	nxt

	clear
	pacstrap /mnt base linux linux-firmware base-devel exfat-utils efibootmgr os-prober networkmanager wireless_tools wpa_supplicant grub slmenu dash git neovim xorg-server xorg-xinit xclip xorg-xbacklight compton xwallpaper terminus-font
	
	clear
	echo "Would you like to install the needed packages for a desktop enviroment / window manager? | Xorg packages"
}

postinstall() {
	genfstab -U /mnt >> /mnt/etc/fstab

	echo "$cdrive\n$bs" > /mnt/temp

	cp lpi3.sh /mnt
	arch-chroot /mnt dash /lpi3.sh

	rm /mnt/lpi3.sh
	rm /mnt/temp

	clear
	echo "As long as there were no hidden errors, you should be able to reboot and boot into your new install."
	rb=$(echo "Reboot\nDon't Reboot" | slmenu -p "Would you like to reboot now?")
	if [ "$rb" = "Reboot" ]; then
		reboot
	else
		clear
	fi
}


### THE ACTUAL SCRIPT ###

# Welcome the user
welcome || error "User Exited."

# Everything that must be done to the drives
formatdrive || error "User Exited."

# Edit the mirrorlist for faster downloads
mirrorlist || error "User Exited."

# The actual install
install || error "User Exited."

# Launch lpi3.sh, then delete the files from /mnt after
postinstall || error "User Exited."
