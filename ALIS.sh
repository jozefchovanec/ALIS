#!/bin/bash
#ArchLinux Lightweight Installation Script

echo "[ArchLinux Lightweight Installation Script]"
echo " "
echo "Your network connection is ?"
echo "Enter 1 for Wireless"
echo "Enter 2 for Wired"
read network

if [ $network = "2" ]; then
dhcpcd
else
wifi-menu
fi

echo "Next please create partitions, sda1 for /mnt and sda2 for swap"
read -p "$*"
cfdisk
echo " "
fdisk -l
echo " "
echo "Are you ready for the installation ?"
echo -n "[y/N]> "
read ready

if [ $ready = "y" ]; then

mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda2
mkswap /dev/sda2
swapon /dev/sda2
mount /dev/sda1 /mnt
pacstrap -i /mnt base base-devel
genfstab -U -p /mnt >> /mnt/etc/fstab
arch-chroot /mnt /bin/bash

echo -n "Please enter hostname: "
read hostname
echo $hostname > /etc/hostname
rm -f /etc/hosts
echo "127.0.0.1       $hostname    $hostname" >> /etc/hosts
echo "::1       $hostname    $hostname" >> /etc/hosts

echo -n "Enter new password for root: "
passwd

echo -n "Enter name of new user: "
read username
useradd -m -G wheel -s /bin/bash $username
echo -n "Enter new password for $username"
passwd $username
echo "$username ALL=(ALL) ALL" >> /etc/sudoers

echo "Installing network utils and xdg-user-dirs..."
pacman -Sy wpa_supplicant dialog xdg-user-dirs
xdg-user-dirs-update

echo "Install Yaourt from archlinux.fr repository ?"
echo -n "[Y/n]"
read yaourt

if [ $yaourt = "n" ]; then
else

echo "[archlinuxfr]" >> /etc/pacman.conf
echo "SigLevel = Never" >> /etc/pacman.conf
echo "Server = http://repo.archlinux.fr/$arch" >> /etc/pacman.conf

pacman -Sy yaourt
fi

echo "Running mkinitcpio..."
mkinitcpio -p linux

echo "Installing Grub..."
pacman -Sy grub
grub-install --target=i386-pc --recheck --force /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
echo " "
echo "INSTALLATION DONE !"
echo "Thanks for using my script..."
echo "https://github.com/jozefchovanec/"
echo "Press enter to reboot"
read -p "$*"

exit
reboot

else
exit
fi

