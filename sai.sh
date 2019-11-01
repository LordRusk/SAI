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
			exit
		done
	fi
}

preinstall() {
	# Make sure git is installed to download custom repo
	pacman --needed --noconfirm -Sy git

	# Download custom repo
	git clone https://www.github.com/LordRusk/rskrepo ~/
	echo "\n[rskrepo]\nSigLevel = Optional TrustAll\nServer = file:///root/rskrepo/$arch" > /etc/pacman.conf

	# Install needed script packages
	pacman --noconfirm --needed -Sy dash neovim slmenu gawk grep
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
	echo "Would you like to nuke the drive and install a completely fresh arch install, or configure your own partitions?"
	auto=$(echo "Configure partitions\nNuke and auto reinstall" | slmenu -p "Configure the partitions or nuke and auto reinstall?"
	if [ "$auto" = "Configue partitions" ]; then
		clear
		echo "Please delete, format, mount and anything else you need to do to the root partition, then 'exit' the shell"
		echo "Note! LPI will assume the root partition is mounted at /mnt"
		sh
		
		clear
		echo "Please select the drive you configured"
		sdrive=$(lsblk -lp | grep "disk $" | awk '{print $1, "(" $4 ")"}' | slmenu -i -p "Choose a drive")
		cdrive=$(echo "$sdrive" | awk '{print $1}')
	
		clear
		echo "Please select the root partition for the reinstall"
		ssdrive=$(lsblk -lp | grep "$cdisk" | grep "part $" | awk '{print $1, "(" $4 ")"}' | slmenu -i -p "Choose a partition")
		ccdrive=$(echo "$ssdrive" | awk '{print $1}')
	elif [ "$auto" = "Nuke and auto reinstall" ]; then
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
	pacstrap /mnt base linux linux-firmware base-devel os-prober grub slmenu dash neovim terminus-font
	
	if [ "$bs" = "EFI" ]; then
		pacstrap /mnt exfat-utils efibootmgr
	fi
}

postinstall() {
	genfstab -U /mnt >> /mnt/etc/fstab

	echo "$cdrive\n$bs\n$auto" > /mnt/temp

	cp sai2.sh /mnt
	arch-chroot /mnt dash /sai2.sh

	rm /mnt/sai2.sh
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

# Get everything setup for the script
prescript || error

# Welcome the user
welcome || error

# Everything that must be done to the drives
formatdrive || error

# Edit the mirrorlist for faster downloads
mirrorlist || error

# The actual install
install || error

# Launch lpi3.sh, then delete the files from /mnt after
postinstall || error