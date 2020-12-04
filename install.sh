#!/bin/bash 
ls /sys/firmware/efi/efivars
echo "Is system UEFI? (Y/n)"
read uefi
fdisk -l
echo "Please select a boot device:"
read bootDev
parted -s $bootDev -- mklabel gpt
#create filesystem
case $uefi in
	y)
		#for uefi systems
		echo "Boot?"
		read disk2
		echo "Root?"
		read disk1
		parted -s $bootDev mkpart primary fat32 2048s 512MB
		parted -s $bootDev mkpart primary ext4 512MB -1s
		mkfs.fat -F 32 $disk2
		mkfs.ext4 $disk1
		parted set 1 bios_grub on
		parted set 2 root on
		;;
	n)
		#for non-uefi
		echo "Root?"
		read disk1
		parted -s $bootDev mkpart primary ext4 2048s -1s
		mkfs.ext4 $disk1
		parted set 1 root on
		;;
	*)
		#for uefi systems
		echo "Boot?"
		read disk2
		echo "Root?"
		read disk1
		parted -s $bootDev mkpart primary fat32 2048s 512MB
		parted -s $bootDev mkpart primary ext4 512MB -1s
		mkfs.fat -F 32 $disk2
		mkfs.ext4 $disk1
		parted set 1 bios_grub on
		parted set 2 root on
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
arch-chroot /mnt
