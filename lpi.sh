#!/bin/bash


### FUNCTIONS ###

error() { printf "Something went wrong, maybe it was the script, maybe it was you, who knows"; exit; }

prescript() { \
	PS3='LPI needs install; dialog for menus and vim for text editing, before the rest of the script can run. Would you like to install dialog and vim, or quit LPI?: '
	options=("Install Dialog and vim" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"Install Dialog and vim")
				pacman -Sy --noconfirm dialog vim
				break
			;;
			"Quit")
				echo "User Exited."
				exit
				break
			;;
			*) echo "invalid option $REPLY";;
		esac
	done
}

welcomemsg() { \
	dialog --title "Welcome" --msgbox "Welcome to LPI! (Lazy Pre Install)\\n\\nThis script is a tool to help you get Arch installed to a point where all you have to do, is install a graphical enviroment and you are good to go." 10 60
}

partitiondrive() { \
	dialog --title "Partitioning and formating" --yesno "First we need to partition the drive, but first we have to choose the drive and wipe it, it will usually be /dev/sda, but it is still good to check. All the current connected drives will be listed, identify which one you want to install Arch and type out the name. If you wish to not go through with the wiping, formating, and partitioning, then choose exit" 12 60

	fdisk -l

	PS3='Choose a drive: '
	options=("/dev/sda/" "/dev/sdb/" "/dev/sdc/" "/dev/sdd/" "/dev/sd0", "Exit")
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
			"Exit")
				echo "User Exited."
				exit
				break
			;;
			*) echo "invalid option $REPLY";;
		esac
	done

	dialog --title "DISCLAIMER" --msgbox "If you are reinstalling using LPI on a partition scheme similar to the one LPI makes, it may ask you if you want to continue with the formatting. If it does, just accept and continue." 10 40

	rps=$(dialog --inputbox "How big big do you want your root partition with extension? (i.E 30gb) The lowest you want to go is 5gb for a VERY small harddrive. Anything with over 250gb you should make it 30gb." 10 60 3>&1 1>&2 2>&3 3>&1) || exit
	hps=$(dialog --inputbox "If you want your home partition to be something other than the rest of the drive (maybe you are duel booting) put it bewlow, if not, leave it blank." 10 60 3>&1 1>&2 2>&3 3>&1)

	echo -e "g\nn\np\n1\n\n+500mb\nn\np\n2\n\n+"$rps"\nn\np\n3\n\n"$hps"\nw" | fdisk "$drive"

	mkfs.fat -F32 /dev/sda1
	mkfs.ext4 /dev/sda2
	mkfs.ext4 /dev/sda3

	mount /dev/sda2 /mnt
	mkdir /mnt/home
	mount /dev/sda3 /mnt/home
}

mirrorlist() { \
	dialog --title "MirrorList" --msgbox "Arch's defualt mirror list can be slow and sometimes just has mirrors that don't work. To improve download speed for the rest of your time with this install, you are going to need to edit the mirror list. The mirrorlist is composed of a bunch of links and locations. All you need to do it comment out (add # before) whichever mirror links aren't close to you. (i.E. If you live in america, comment out mirrors that are not in located in the USA)" 12 60
	vim /etc/pacman.d/mirrorlist
}

install() { \
	dialog --title "It's Finally Time!!" --msgbox "It's time to install, from here its all but automatic, so let LPI do its thing and sit back. Depending on how good your internet is, is how fast the install will be. Ready?" 7 35
	pacstrap /mnt base base-devel dosfstools exfat-utils efibootmgr os-prober mtools network-manager-applet networkmanager wireless_tools wpa_supplicant grub dialog wget git make vim ranger pulseaudio pulseaudio-alsa pavucontrol xorg-server xorg-xinit xorg-xbacklight xcompmgr xwallpaper sxiv unrar unzip zathura zathura-djvu zathura-pdf-mupdf firefox

	dialog --title "Base Install Finished!!" --msgbox "LPI is done installing the base arcj system, its time to start configuring things inside the system like grub, locale, etc." 15 30

}

postinstall() { \
	genfstab /mnt >> /mnt/etc/fstab

	# All configuring and scripts must be ran in a seperate script to function in chroot
	cp lpi2.sh /mnt
	arch-chroot /mnt sh /lpi2.sh
}

finish() {
	dialog --title "LPI has finished" --msgbox "As long as there were no hidden errors, LPI has successfully installed everything needed for a base arch install. LPI will now reboot, afterwords just log in and start installing your graphical enviroment" 10 60

	reboot
}

### THE ACTUAL SCRIPT ###

### This is how everything happens in an intuitive format and order.

# Install dialog, at the same time making sure everything else is good for the install
prescript || error "User Exited."

# Welcome user
welcomemsg || error "User Exited."

# Get sizes for drives, make the partitions, and format the partitions
partitiondrive || error "User Exited."

# Edit the mirror list for faster pacman install speeds overall
mirrorlist || error "User Exited."

# Time to install the base system + everything else they need for a funtioning Arch system.
install || error "User Exited."

# Configure some things post install before we can install grub
postinstall || error "User Exited."

# Finish LPI
finish || error "User Exited."
