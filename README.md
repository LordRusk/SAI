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
  - LPI Currently supports EFI and non EFI bios, optional user creation, 'sudoers' editing, and enabling NetworkManager.
  - I need to add a package file, so it's easier to remove packages or add packages to the install, though aur and git won't be supported, it will be supported in my auto ricing script when I do make it.
  - LPI Has been fully moved to slmenu, the old dialog supported LPI can be here [here](https://www.github.com/LordRusk/old_LPI), Though it will not be supported.
