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
  - LPI Has been fully moved to slmenu, the old dialog supported LPI can be here [here](https://www.github.com/LordRusk/old_LPI), Though it will not be supported from this point on.
  - LPI only supports EFI booting right now, when I get around to it I will add non EFI support.
