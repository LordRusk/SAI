#!/bin/bash


### FUNCTIONS ###

error() { printf "Something went wrong, maybe it was the script, maybe it was you, who knows"; exit;}

prescript() { \
	PS3='LPI needs install; dialog for menus, vim for text editing, and ranger to debug, before the rest of the script can run. Would you like to install dialog, vim, and ranger or quit LPI?: '
	options=("Install Dialog" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"Install Dialog")
				pacman -Sy --noconfirm dialog vim ranger
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
	dialog --title "Welcome" --msgbox "Welcome to LPI! (Lazy Pre Install)\\n\\nThis script is a tool to help you get Arch installed. (LPI will also ask if you would like to use LARBS (Luke's Automatic Bootstrapping Scripts) as a graphical interface, or let you install and configure your own!" 10 60
	}

partitiondrive() { \
	rps=$(dialog --inputbox "How big big do you want your root partition with extension? (i.E 30gb) The lowest you want to go is 5gb for a VERY small harddrive. Anything with over 250gb you should make it 30gb." 10 60 3>&1 1>&2 2>&3 3>&1) || exit
	hps=$(dialog --inputbox "If you want your home partition to be something other than the rest of the drive (maybe you are duel booting) put it bewlow, if not, leave it blank." 10 60 3>&1 1>&2 2>&3 3>&1)

	echo -e "g\nn\np\n1\n\n+500mb\nn\np\n2\n\n+"$rps"\nn\np\n3\n\n"$hps"\nw" | fdisk /dev/sda

	mkfs.fat -F32 /dev/sda1
	mkfs.ext4 /dev/sda2
	mkfs.ext4 /dev/sda3

	mount /dev/sda2 /mnt
	mkdir /mnt/home
	mount /dev/sda3 /mnt/home
}

mirrorlist() {
	mle=$(dialog --title "Would you like to edit the pacman mirror list?" --yesno "The defualt Arch mirror list can be slow and some mirrors just don't work. If you edit the mirror list (by putting # before mirror links you do not want to use" 10 50)
	if [[ "$mle" == "yes" ]] do
		echo "$mle"
		done
	echo $mle
	fi

}

installbase() {
	sudo pacman -S base git dialog
}

### THE ACTUAL SCRIPT ###

### This is how everything happens in an intuitive format and order.

# Install dialog, at the same time making sure everything else is good for the install
prescript || error "User Exited."

# Welcome user
welcomemsg || error "User Exited."

# Get sizes for drives, make the partitions, and format the partitions
partitiondrive || error "User Exited."
