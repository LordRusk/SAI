#!/bin/sh

### FUNCTIONS ###

error() { printf "Spomething went wrong, maybe it was you, maybe it was the script, who knows"; exit; }
xit() {
	xon=$(echo "Continue\\nExit" | slmenu -i -p "$xprompt")
	if [ "$xom" = "continue" ]; then
		echo "epic"
	elif [ "$xom" = "exit" ]; then
		exit
	fi
}

prescript() {
	sudo pacman --noconfirm -S neovim mercurial

	hg clone https://bitbucket.org/rafaelgg/slmenu
	cd slmenu/
	sudo make clean install
	cd ../
	rm -rf slmenu/
}

welcome() {
	clear
	echo "Welcome to LPI (lazy Pre Install)"
	echo "This script is to help you get arch installed by doing the hard stuff for you"
	echo "and let the rest be up to you, ready to continue?"
	xprompt="Continue?"
	xit
}

formatdrive() {
	clear
	echo "First thing, let's mess with the drives. But first, pick which drive you would like to install arch on"

	echo ""
	lsblk
	cdrive=$(echo "/dev/sda\\n/dev/sdb\\n/dev/sdc\\n/dev/sdd" | slmenu -i -p "Choose a drive")

	clear
	echo "How big do you want your root partition to be? Defualt is 30gb"
	rps=$(echo "30gb" | slmenu -i -p "Size of root partition")

	clear
	echo "You may want to change the size of your home partition if you are planning on duel booting, if not leave blank"
	hps=$(echo "" | slmenu -i -p "Home Partition Size")

	clear
	echo "If you continue, the selected drive will be wiped, all data will be lost, do you want to continue?"
	xprompt="Are you sure you want to continue?"
	xit

	echo -e "g\nd\n1\nd\n2\nd\n3\nd\n4\nd\n5\nd\n6" | fdisk "$cdrive"
	echo -e "g\nn\np\n1\n\n+500mb\nn\np\n2\n\n+"$rps"\nn\np\n3\n\n"$hps"\nw" | fdisk "$cdrive"


	mkfs.fat -F32 "$cdrive"1
	mkfs.ext4 "$cdrive"2
	mkfs.ext4 "$cdrive"3
	mount "$cdrive"2 /mnt
	mkdir /mnt/home
	mount "$cdrive"3 /mnt/home
}

mirrorlist() {
	echo "The defualt arch mirrorlist can be slow and unreliable, please edit the mirrorlist for faster speeds."
	xprompt="Continue?"
	xit
	nvim /etc/pacman.d/mirrorlist
}

fancypac() {
	echo "Would you like pacman to look nice while installing?"
	fp=$(echo "Yes\\nNo" | slmenu -i -p "Would you?")
	if [ "$fp" = "Yes" ]; then
		grep "^Color" /etc/pacman.conf >/dev/null || sed -i "s/^#Color/Color/" /etc/pacman.conf
		grep "ILoveCandy" /etc/pacman.conf >/dev/null || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
	else
		echo "ok"
	fi
}

install() {
	echo "It's time to actually install arch, ready?"
	xprompt="Ready?"
	xit

	pacstrap /mnt linux linux-firmware base base-devel dosfstools exfat-utils efibootmgr os-prober mtools network-manager-applet networkmanager wireless_tools wpa_supplicant grub dialog git vim ranger pulseaudio pulseaudio-alsa alsa alsa-utils pavucontrol xorg-server xorg-xinit xclip xorg-xbacklight xcompmgr xwallpaper sxiv mpv unrar unzip zathura zathura-djvu zathura-pdf-mupdf noto-fonts noto-fonts-emoji
}

postinstall() {
	genfstab /mnt >> /mnt/etc/fstab

	echo "it do be done heckin epic"
}


### THE ACTUAL SCRIPT ###

# Pre script | install slmenu and neovim
prescript || error "User Exited."

# Welcome the user
welcome || error "User Exited."

# Everything that must be done to the drives
formatdrive || error "User Exited."

# Edit the mirrorlist for faster downloads
mirrorlist || error "User Exited."

# make pacman and yay look good
fancypac || error "User Exited."

# The actual install
install || error "User Exited."

# Finish up
postinstall || error "User Exited."
