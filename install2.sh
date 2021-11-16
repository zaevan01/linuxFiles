#!/bin/bash
echo "Is system UEFI? [Y/n]"
read uefi
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
case $uefi in
	y|*)
		#for uefi systems
		pacman -S grub efibootmgr update-grub --noconfirm
		mkdir /boot/efi
		echo "Boot partition?"
		read disk2
		mount $disk2 /boot/efi
		grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
		grub-mkconfig -o /boot/grub/grub.cfg
		;;
	n)
		#for non-uefi
		pacman -S grub update-grub --noconfirm
		grub-install /mnt
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
pacman -S xorg terminator base-devel reflector firefox --noconfirm
echo "Please select a desktop environment:"
echo -e "KDE (Plasma)\nGnome (3)\nXFCE\nCinnamon\nMate\n"
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
		pacman -S gnome --noconfirm
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
	*)
		echo "Please choose a valid option:"
		;;
esac
done
systemctl enable NetworkManager.service
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector -c "US" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist
cd /home/$uName
git clone https://aur.archlinux.org/trizen.git
mv /etc/pacman.conf /etc/pacman.conf.bak
cp /linuxFiles/pacman.conf /etc/pacman.conf
mv /home/$uName/.bashrc /home/$uName/.bashrc.bak
cp /linuxFiles/.bashrc /home/$uName/.bashrc
echo "Install Steam and additional software?(Y/n)"
read extraPrograms
case $extraPrograms in
	y|*)
		pacman -S steam discord-canary minecraft-launcher lutris dxvk terminator libreoffice-fresh deluge vlc --noconfirm
		;;
	n)
		echo
		;;
esac
echo "Please Select Appropriate Graphics Drivers"
echo "Nvidia\nAmd\nIntel"
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
		;;
	[nN]|*)
		echo
		;;
esac
echo "Install AMD or Intel uCode?\nAMD\nIntel" 
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
update-grub
exit
