#!/bin/bash
echo "Is system UEFI?"
read uefi
timedatectl list-timezones
echo "Please enter a timezone:"
read zone
timedatectl set-timezone $zone
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
echo "Hostname:"
read hName
echo $hName >> /etc/hostname
echo '127.0.0.1 localhost' >> /etc/hosts
echo '::1 localhost' >> /etc/hosts
echo '127.0.1.1 '$hName >> /etc/hosts
passwd
case $uefi in
	y)
		#for uefi systems
		pacman -S grub efibootmgr --noconfirm
		mkdir /boot/efi
		echo "Boot partition?"
		read disk2
		mount $disk2 /boot/efi
		grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
		grub-mkconfig -o /boot/grub/grub.cfg
		;;
	n)
		#for non-uefi
		pacman -S grub --noconfirm
		grub-install /mnt
		grub-mkconfig -o /boot/grub/grub.cfg
		;;
	*)
		#for uefi systems
		pacman -S grub efibootmgr --noconfirm
		mkdir /boot/efi
		echo "Boot partition?"
		read disk2
		mount $disk2 /boot/efi
		grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
		grub-mkconfig -o /boot/grub/grub.cfg
		;;
esac
echo "Please enter a username:"
read uName
useradd -m $uName
passwd $uName
pacman -S sudo --noconfirm
export EDITOR=nano
echo $uName' ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
pacman -S xorg plasma plasma-wayland-session kde-applications terminator base-devel reflector firefox --noconfirm
systemctl enable sddm.service
systemctl enable NetworkManager.service
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector -c "US" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist
cd /home/$uName
git clone https://aur.archlinux.org/trizen.git
mv /etc/pacman.conf /etc/pacman.conf.bak
cp /linuxFiles/pacman.conf /etc/pacman.conf
mv /home/$uName/.bashrc /home/$uName/.bashrc.bak
cp /linuxFiles/.bashrc /home/$uName/.bashrc
echo "Install nvidia drivers and AMD Microcode?(Y/n)"
read extraPrograms
case $extraPrograms in
	y)
		pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils amd-ucode steam minecraft
		mv /etc/x11/xorg.conf /etc/x11/xorg.conf.bak
		cp /linuxFiles/xorg.conf.bak /etc/x11/xorg.conf

		;;
	n)
		exit
		;;
	*)
		pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils amd-ucode steam minecraft
		mv /etc/x11/xorg.conf /etc/x11/xorg.conf.bak
		cp ~/linuxFiles/xorg.conf.bak /etc/x11/xorg.conf
		;;
esac
