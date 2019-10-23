#!/bin/dash

# Define lpi2.sh variables
cdrive=$(cat temp | grep /dev)
bs=$(cat temp | grep EFI)

### FUNCTIONS ###

error() { printf "Something went wrong, maybe it was the script, maybe it was you, who knows."; exit; }

nxt() { echo "Next" | slmenu -p "Continue?"; }

xit() {
xon=$(echo "Continue\\nExit" | slmenu -i -p "$xprompt")
	if [ "$xom" = "continue" ]; then
		echo "epic"
	elif [ "$xom" = "exit" ]; then
		while [ "$xom" = "$xom" ]; do
			error
		done

	fi
}

locale() {
	clear
	echo "Next we are going to be configuing your locale. First please enter your Region/City in that format"
	echo "Example: Pacific time would be America/Los_Angeles"
	rc=$(echo "Region/City" | slmenu -p "Region/City")
	ln -sf /usr/share/zoneinfo/"$rc" /etc/localtime
	hwclock --systohc

	clear
	echo "Please uncoomment en_US.UTF-8 UTF-8 and other locals you may need"
	nxt
	nvim /etc/locale.gen
	locale-gen
}

bootmanager() {
	clear
	echo "LPI automatically installs GRUB as it's boot manager, if you would not like to install grub, "
	echo "but install a different boot manager outside of LPI, select Exit, if not, continue."
	grb=$(echo "Install Grub\nSkip" | slmenu -p "Install or Skip")
	if [ "$grb" = "Install Grub" ]; then
		if [ "$bs" = "non EFI" ]; then
			grub-install "$cdrive"
		elif [ "$bs" = "EFI" ]; then
			grub-install --target=x86_64-efi --bootloader-id=grub-uefi --recheck
		fi
		mkinitcpio -p grub
		grub-mkconfig -o /boot/grub/grub.cfg
	elif [ "$grb" = "Skip" ]; then
		echo "ok"
	fi
}

getuserandpass() {
	clear
	echo "Would you like to create a user?"
	cu=$(echo "Create User\nSkip" | slmenu -p "Create User?")
	if [ "$cu" = "Create User" ]; then

		name=$(echo "" | slmenu -p "Please enter the name of your new user")
		while ! echo "$name" | grep "^[a-z_][a-z0-9_-]*$" >/dev/null 2>&1; do
			clear
			echo "Username not valid. Give a username beginning with a letter, with only lowercase letters, - or _."
			name=$(echo "" | slmenu -p "Please type a valid username")
		done
		clear
		pass1=$(echo "" | slmenu -p "Enter a password for the user")
		clear
		pass2=$(echo "" | slmenu -p "Retype Password")
		while ! [ "$pass1" = "$pass2" ]; do
			unset pass2
			clear
			echo "Passwords do not match. Enter password again."
			pass1=$(echo "" | slmenu -p "Enter a password")
			clear
			pass2=$(echo "" | slmenu -p "Retype password")
		done ;
	else
		clear
		echo "Would you like to set a root password"
		srp=$(echo "Set Root Password\nSkip" | slmenu -p "Set Root Password?")
		if [ "$srp" = "Set Root Password" ]; then
			clear
			rpass1=$(echo "" | slmenu -p "Enter a root password")
			clear
			rpass2=$(echo "" | slmenu -p "Retype password")
			while ! [ "$rpass1" = "$rpass2" ]; do
				unset pass2
				clear
				echo "Passwords do not match. Enter password again."
				rpass1=$(echo "" | slmenu -p "Enter a password")
				clear
				rpass2=$(echo "" | slmenu -p "Retype password")
			done ;
		else
			echo ""
		fi
	fi

}

adduserandpass() {
	if [ "$cu" = "Create User" ]; then
		clear
		echo "Adding user and setting root password"
		useradd -m -g wheel "$name"
		echo "$name:$pass1" | chpasswd
		unset pass1 pass2 ;
	elif [ "$srp" = "Set Root Password" ]; then
		echo "root:$rpass1" | chpasswd
		unset rpass1 rpass2 ;
	fi
}

sudoers() {
	clear
	echo "Would you like to edit /etc/sudoers file? If so, your new user is in group wheel"
	es=$(echo "Yes\\nNo" | slmenu -p "Edit /etc/sudoers?")
	if [ "$es" = "Yes" ]; then
		nvim /etc/sudoers
	else
		echo "ok"
	fi
}

wificonfig() {
	clear
	echo "Would you like to enable NetworkManager?"
	en=$(echo "Yes\\nNo" | slmenu -p "Enable NetworkManger?")
	if [ "$en" = "Yes" ]; then
		systemctl enable NetworkManager.service
	else
		echo "ok"
	fi
}

### THE ACTUAL SCRIPT ###

# Generate the locale and get local time configured
locale || error "User Exited."

# Ask if grub should be installed or if they want to install something else
bootmanager

# Get username and password for the new user, get the root password, set the root passwor, and make the new account
getuserandpass || error "User Exited."
adduserandpass || error "User Exited."

# Ask if they would like to edit /etc/sudoers file
sudoers || error "User Exited."

# Ask if they would like to enable networkmanager
wificonfig || error "User Exited."
