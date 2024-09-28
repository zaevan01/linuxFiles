#!/bin/bash 
#
#Note for connecting to wifi: iwctl --passphrase {WIFIPASSWORD} station {DEVICE(usually wlan0)} connect "{SSID}"
#
ls /sys/firmware/efi/efivars
echo "Is system UEFI? (y/n)"
read uefi
fdisk -l
echo "Please select a boot device:"
read bootDev
echo "Is device an NVME drive? (y/N)"
read nvme
wipefs -a $bootDev
#create filesystem
case $uefi in
	y)
		#for uefi systems
		parted --script $bootDev \ mklabel gpt \ mkpart primary 2048s 512MB \ mkpart primary 512MB 100%
		case $nvme in
			y)
				boot=$bootDev"p1"
				root=$bootDev"p2"
				;;
			n|*)
				boot=$bootDev"1"
				root=$bootDev"2"
				;;
		esac
		mkfs.fat -F 32 $boot
		mkfs.ext4 $root
		mount $root /mnt
		;;
	n)
		#for non-uefi
		parted --script $bootDev \ mklabel gpt \ mkpart primary 2048s 100%
		case $nvme in
			y)
				root=$bootDev"p1"
				;;
			n|*)
				root=$bootDev"1"
				;;
		esac
		mkfs.btrfs $root
		mount $root /mnt
		;;
esac
pacman -Syy
pacman -S git --noconfirm
pacstrap /mnt base linux linux-firmware linux-headers linux-zen linux-zen-headers vim nano git --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
cd /mnt/
git clone https://github.com/zaevan01/linuxFiles.git
touch parameters.txt
echo $boot >> /mnt/linuxFiles/parameters.txt
echo $uefi >> /mnt/linuxFiles/parameters.txt
cd
arch-chroot /mnt
