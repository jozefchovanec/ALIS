#!/bin/bash
#ArchLinux Lightweight Installation Script

echo "[ArchLinux Lightweight Installation Script]"
echo

echo "Please create partitions, sda1 for /mnt and sda2 for swap"
read -p "$*"
cfdisk
echo
fdisk -l
echo
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

echo

echo -n "Please enter hostname: "
read hostname
arch-chroot /mnt sh -c($'echo $hostname > /etc/hostname') & 
arch-chroot /mnt sh -c($'rm -f /etc/hosts') & 
arch-chroot /mnt sh -c($'echo "127.0.0.1       $hostname    $hostname" >> /etc/hosts') &
arch-chroot /mnt sh -c($'echo "::1       $hostname    $hostname" >> /etc/hosts') & 

echo

echo -n "Enter new password for root: "
arch-chroot /mnt sh -c($'passwd') & 

echo

echo -n "Enter name of new user: "
read username
arch-chroot /mnt sh -c($'useradd -m -G wheel -s /bin/bash $username') &
echo -n "Enter new password for $username "
arch-chroot /mnt sh -c($'passwd $username') &
arch-chroot /mnt sh -c($'echo "$username ALL=(ALL) ALL" >> /etc/sudoers') &

echo

echo "Installing recommended utils..."
arch-chroot /mnt sh -c($'pacman -Sy wpa_supplicant dialog xdg-user-dirs alsa-utils ntfs-3g dosfstools exfat-utils mtools scrot htop') &
arch-chroot /mnt sh -c($'xdg-user-dirs-update') &

echo

echo "Install Yaourt from archlinux.fr repository ?"
echo -n "[Y/n]> "
read yaourt

if [ $yaourt = "n" ]; then
break
else

arch-chroot /mnt sh -c($'echo "[archlinuxfr]" >> /etc/pacman.conf') &
arch-chroot /mnt sh -c($'echo "SigLevel = Never" >> /etc/pacman.conf') &
arch-chroot /mnt sh -c($'echo "Server = http://repo.archlinux.fr/$arch" >> /etc/pacman.conf') &

arch-chroot /mnt sh -c($'pacman -Syy') &
arch-chroot /mnt sh -c($'pacman -Scc') &
arch-chroot /mnt sh -c($'pacman -Sy yaourt') &
fi

echo

echo "Add [multilib] repository ?"
echo -n "[Y/n]> "
read multilib

if [ $multilib = "n" ]; then
break
else

arch-chroot /mnt sh -c($'echo "[multilib]" >> /etc/pacman.conf') &
arch-chroot /mnt sh -c($'echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf') &

arch-chroot /mnt sh -c($'pacman -Syy') &
arch-chroot /mnt sh -c($'pacman -Scc') &
fi

echo

echo "Running mkinitcpio..."
arch-chroot /mnt sh -c($'mkinitcpio -p linux') &

echo

echo "Installing Grub..."
arch-chroot /mnt sh -c($'pacman -Sy grub') &
arch-chroot /mnt sh -c($'grub-install --target=i386-pc --recheck --force /dev/sda') &
arch-chroot /mnt sh -c($'grub-mkconfig -o /boot/grub/grub.cfg') &
echo
echo "INSTALLATION DONE !"
echo "Thanks for using my script..."
echo "https://github.com/jozefchovanec/"
echo "Press enter to reboot"
read -p "$*"

reboot

else
exit
fi

