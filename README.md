# LPI
Lazy Pre Install: The lazy (best) way to install Arch

LPI is a helpful tool for getting from booting from the Arch usb, to be able to install a WM/DE and be on your way. It's very easy to use and is very lightweight.

# How To
After you boot fron the arch usb, all you have to do is run these commands:
```
pacman -Sy git
git clone https://www.github.com/LordRusk/LPI
cd LPI
sh lpi.sh
```
Thats it, you are on your way to the laziest Arch install of your life.

# Notes\\ToDo
  - LPI only supports EFI booting right now, when I get around to it I will add non EFI support.
  - The first beta of slmenu-LPI is out, I still have yet to get slmenu installed on a virtual machiene, it doesn't have enough space to install the needed packages to get it downloaded and compiled...if only it were in the defualt repos.

# FAQ
Q: Why is there two lpi.sh's? `lpi.sh // lpi2.sh `

A: The reason why LPI needs two scripts is: In a script, you can't chroot into an install and just continue the scipt, the chroot itself is all one command. The way I get around this is haveing two scripts and running `arch-chroot /mnt /lpi2.sh` (after copying lpi2.sh to /mnt) meaning, as far as the first script is concerned, everything inside the chroot (the second script) is one command.
