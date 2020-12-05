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
#create filesystem
case $uefi in
	y)
		#for uefi systems
		echo "Boot?"
		read disk2
		echo "Root?"
		read disk1
		parted --script $bootDev \ mklabel gpt \ mkpart primary 2048s 512MB \ mkpart primary 512MB 100%
		mkfs.fat -F 32 $disk2
		mkfs.ext4 $disk1
		;;
	n)
		#for non-uefi
		echo "Root?"
		read disk1
		parted --script $bootDev \ mklabel gpt \ mkpart primary 2048s 100%
		mkfs.ext4 $disk1
		;;
	*)
		#for uefi systems
		echo "Boot?"
		read disk2
		echo "Root?"
		read disk1
		parted --script $bootDev \ mklabel gpt \ mkpart primary 2048s 512MB \ mkpart primary 512MB 100%
		mkfs.fat -F 32 $disk2
		mkfs.ext4 $disk1
		;;
esac
pacman -Syy
pacman -S git --noconfirm
mount $disk1 /mnt
pacstrap /mnt base linux linux-firmware linux-headers linux-zen linux-zen-headers vim nano git --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
cd /mnt/
git clone https://github.com/zaevan01/linuxFiles.git
cd
arch-chroot /mnt
shutdown now
