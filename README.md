# LLARBS
Luke's Lazy Auto Ricing Bootstrapping Scripts: a fork of LARBS with some added lazyness

This is a "fork" of larbs that adds a helpful tool for getting everything from right after chrooting into the new install of arch to running LARBS. I did this completely for self time save. But maybe it will help others. Pre LPI...


\Make sure you are connected to a network
    If you are connected to ethernet, you should be automatically connected
    Test if you are connected: Ping www.google.com
    If not, you can connect with wifi-menu (in the future you must use sudo if not root)
    Once you are connected to the internet, you can move on

Partition your drive // creating filesystem
    First identify the drive you are going to install Arch Linux onto.
    To list all drives, you can either do “lsblk” or “fdisk -l”
    Once you identify the drive, you can start partitioning the drive by using the command “cfdisk [drive] (The drive will be formatted as such “/dev/sd<-insert letter of drive (i.E, a, b, c)) (if prompted choose dos)
    If there are any partitions already made to the drive, just go over the already made drives, and choose the “Erase” function (Note: Nothing you do will be finalized until you choose the “Write” function)
    The first partition we are going to make is the 300mb “Boot” partition, so choose “New” resize to “300mb” and choose extended.
    The next partition we are going to be making is the “root” (/) partition, now if you have any real amount of disk space, make it 30GB, but if you are just going through this on a 8GB drive on a virtual machine, do 2GB or something similar to that % of the drive.
    The last partition we are going to be making is the is the “home” partition (/home) you can just allocate everything left over in your drive to this partition.
    Now you can choose the “Write” function, and spell out “yes” when it asks if you want to write to the drive, choose “quit” and move on. (WARNING: After writing, there is no going back, you will have to go through with the install, or reinstall whatever OS you had on the drive beforehand)
Now we have to make the file systems for each partition. The first partition, which is the “boot” (/dev/sd-1) needs to be Fat-32. The way to do this “mkfs.fat -F32 /dev/sda-1” Next we are going to format the root (/) partition, the way to do this is “mkfs.ext4 /dev/sd-2” Finally we have to format the home (/home) partition, the way to do this is “mkfs.ext4 /dev/sd-3”
Now we have to mount the partitions to be able to install Arch Linux, right now, we are going to mount /dev/sd-2 on /mnt with “mount /dev/sd-2 /mnt” Next we are going to mount /dev/sd-3 onto /mnt/home, but first we have to make /mnt/home, how we do this is “mkdir /mnt/home” now we can mount /dev/sd-3 there with “mount /dev/sd-3 /mnt/home”
Now before we move to the install, let’s make sure that everything looks fine, run the command “mount |grep sd-” and the output should look like this.

/dev/sd-2 on /mnt type ext4 (rw,relatime)
/dev/sd-3 on /mnt/home type ext4 (rw,relatime)

If all looks good, you can move on.

    
Pacstrap base arch // installing other needed software
The command we are going to use to install Arch is called “pacstrap” along with being able to install arch onto the drive, we can also install all the base programs we are going to need. Here’s a list of programs we are going to need along with the base install

base-devel
grub
vim
ranger
efibootmgr:
dosfstools
os-prober
mtools
network-manager-applet
networkmanager
wireless_tools
wpa_supplicant
dialog
dmenu
wget
git
make
feh
blueberry
ksysguard
pavucontrol
gparted
    
  The full command we will be running is “pacstrap /mnt base base-devel grub vim ranger efibootmgr dosfstools os-prober mtools network-manager-applet networkmanager wireless_tools wpa_supplicant dmenu dialog mkdwget git make feh blueberry ksysguard pavucontrol gparted” It should take a considerable amount of time to download and install all the packages along with Arch Linux. All other programs I would want on my system (i.E. discord, steam, etc) we can install after.
  The last thing we have to do before configuring Arch Linux with LLARBS, is generating our fstab. This can be easily done with this command → “genfstab -U -p /mnt  >> /mnt/etc/fstab” Now we can easily check if this worked by printing out the file we just made, you can easily print out a text file using the “cat” command rather than having to open it in an editor like nano or vim. All we have to do is run this command → “cat /mnt/etc/fstab” It should list sd-2 and sd-3 each mounted on (/) and (/home) respectively, along with a UUID, don’t worry about the UUID.
