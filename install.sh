#!/bin/bash 
ls /sys/firmware/efi/efivars
echo "Is system UEFI? (Y/n)"
read uefi
fdisk -l
echo "Please select a boot device:"
read bootDev
#create filesystem
case $uefi in
	y)
		#for uefi systems
		echo "Boot?"
		read disk2
		echo "Root?"
		read disk1
		parted --script $bootDev \ mklabel gpt \ mkpart primary 2048s 512MB \ mkpart primary 512MB -1s
		mkfs.fat -F 32 $disk2
		mkfs.ext4 $disk1
		;;
	n)
		#for non-uefi
		echo "Root?"
		read disk1
		parted --script $bootDev \ mklabel gpt \ mkpart primary 2048s -1s
		mkfs.ext4 $disk1
		;;
	*)
		#for uefi systems
		echo "Boot?"
		read disk2
		echo "Root?"
		read disk1
		parted --script $bootDev \ mklabel gpt \ mkpart primary 2048s 512MB \ mkpart primary 512MB -1s
		mkfs.fat -F 32 $disk2
		mkfs.ext4 $disk1
		;;
esac
echo "please enter wifi-SSID"
read wifiName
echo "Please enter wifi-password"
read wifiPass
#(connect to wifi)
iwctl --passphrase $wifiPass station wlan0 connect $wifiName
pacman -Syy
mount $disk1 /mnt
pacstrap /mnt base linux linux-firmware linux-headers linux-zen linux-zen-headers vim nano git --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
git clone https://github.com/zaevan01/linuxFiles.git
cd
arch-chroot /mnt
