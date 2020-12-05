#!/bin/bash 
#
#Note for connecting to wifi: iwctl --passphrase {WIFIPASSWORD} station {DEVICE(usually wlan0)} connect "{SSID}"
#
ls /sys/firmware/efi/efivars
echo "Is system UEFI? (Y/n)"
read uefi
fdisk -l
echo "Please select a boot device:"
read bootDev
wipefs -a $bootDev
#create filesystem
case $uefi in
	y|*)
		#for uefi systems
		parted --script $bootDev \ mklabel gpt \ mkpart primary 2048s 512MB \ mkpart primary 512MB 100%
		mkfs.fat -F 32 $bootDev"1"
		mkfs.ext4 $bootDev"2"
		mount $bootDev"2" /mnt
		;;
	n)
		#for non-uefi
		parted --script $bootDev \ mklabel gpt \ mkpart primary 2048s 100%
		mkfs.ext4 $bootDev"1"
		mount $bootDev"1" /mnt
		;;
esac
pacman -Syy
pacman -S git --noconfirm
pacstrap /mnt base linux linux-firmware linux-headers linux-zen linux-zen-headers vim nano git --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
cd /mnt/
git clone https://github.com/zaevan01/linuxFiles.git
cd
arch-chroot /mnt
#shutdown now
