#!/bin/bash

input="/linuxFiles/parameters.txt"
linenum=1
while read line
do
	if [ $linenum == 1 ]
	then
	disk2=$line
	elif [ $linenum == 2 ]
	then
	uefi=$line
	fi
	linenum=$((linenum + 1))
done < "$input"

timedatectl list-timezones
echo "Please enter a timezone:"
read zone
timedatectl set-timezone $zone
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 >> /etc/locale.conf
export LANG=en_US.UTF-8

echo "Hostname:"
read hName
echo $hName >> /etc/hostname
echo '127.0.0.1 localhost' >> /etc/hosts
echo '::1 localhost' >> /etc/hosts
echo '127.0.1.1 '$hName >> /etc/hosts

passwd

pacman -S grub sudo xorg terminator base-devel reflector firefox networkmanager ntfs-3g cups system-config-printer print-manager openssh pulseaudio-bluetooth --noconfirm

case $uefi in
	y|*)
		#for uefi systems
		pacman -S efibootmgr --noconfirm
		mkdir /boot/efi
		mount $disk2 /boot/efi
		grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
		grub-mkconfig -o /boot/grub/grub.cfg
		;;
	n)
		#for non-uefi
		grub-install /mnt
		grub-mkconfig -o /boot/grub/grub.cfg
		;;
esac

echo "Please enter a username:"
read uName
useradd -m $uName
passwd $uName

export EDITOR=nano
echo $uName' ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
usermod -aG wheel $uName

echo "Please select a desktop environment:"
echo -e "KDE (Plasma)\nGnome (3)\nXFCE\nCinnamon\nMate\nNone\n"
echo "Please enter your selection:"
dei=false
while [ "$dei" = false ]
do
read de
case $de in
	[kK]|[kK][dD][eE])
		pacman -S plasma plasma-wayland-session kde-applications --noconfirm
		systemctl enable sddm.service
		dei=true
		;;
	[gG]|[gG][nN][oO][mM][eE])
		pacman -S gnome gnome-tweaks --noconfirm
		systemctl enable gdm.service
		dei=true
		;;
	[xX]|[xX][fF][cC][eE])
		pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter --noconfirm
		systemctl enable lightdm.service
		dei=true
		;;
	[cC]|[cC][iI][nN][nN][aA][mM][oO][nN])
		pacman -S cinnamon lightdm lightdm-gtk-greeter --noconfirm
		systemctl enable lightdm.service
		dei=true
		;;
	[mM]|[mM][aA][tT][eE])
		pacman -S mate mate-extra lightdm lightdm-gtk-greeter --noconfirm
		systemctl enable lightdm.service
		dei=true
		;;
	[nN]|[nN][oO][nN][eE])
		echo "No desktop environment installed";
		dei=true
		;;
	*)
		echo "Please choose a valid option:"
		;;
esac
done

systemctl enable NetworkManager.service
systemctl enable cups.service
systemctl enable bluetooth.service

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector -c "US" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist
cd /home/$uName
git clone https://aur.archlinux.org/trizen.git

mv /etc/pacman.conf /etc/pacman.conf.bak
cp /linuxFiles/pacman.conf /etc/pacman.conf
pacman -Sy

mv /home/$uName/.bashrc /home/$uName/.bashrc.bak
cp /linuxFiles/.bashrc /home/$uName/.bashrc

echo "Install Steam and additional software?(Y/n)"
read extraPrograms
case $extraPrograms in
	y|*)
		pacman -S steam discord-canary lutris libreoffice-fresh deluge vlc --noconfirm
		;;
	n)
		echo
		;;
esac

echo -e "Please Select Appropriate Graphics Drivers\n"
echo -e "Nvidia\nAmd\nIntel"
read gDrivers
case $gDrivers in
	[nN]|[nN][vV][iI][dD][iI][aA])
		pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils --noconfirm
		;;
	[aA]|[aA][mM][dD])
		pacman -S mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon xf86-video-amdgpu mesa-vdpau flameshot --noconfirm
		;;
	[iI]|[iI][nN][tT][eE][lL])
		pacman -S mesa lib32-mesa intel-media-driver vulkan-intel --noconfirm
		;;
	*)
	echo
	;;
esac

echo "Is this Zac's Standard Desktop Setup?(y/N)"
read xFile
case $xFile in
	[yY])
		mv /etc/x11/xorg.conf /etc/x11/xorg.conf.bak
		cp /linuxFiles/xorg.conf.bak /etc/x11/xorg.conf
		echo "options hid_apple fnmode=0" | tee -a /etc/modprobe.d/hid_apple.conf
		;;
	[nN]|*)
		echo
		;;
esac

echo -e "Install AMD or Intel uCode?\nAMD\nIntel" 
read uCode
case $uCode in
	[aA]|[aA][mM][dD]) 
		pacman -S amd-ucode --noconfirm
		;;
	[iI]|[iI][nN][tT][eE][lL])
		pacman -S intel-ucode --noconfirm
		;;
	*)
		echo
		;;
esac

echo "All Done!"
exit
