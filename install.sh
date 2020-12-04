ls /sys/firmware/efi/efivars
echo Is system UEFI?
read uefi

fdisk -l
echo Please select a disk(s)

#create filesystem
case $uefi in
	y)
		#for uefi systems
		echo Boot?
		read disk2
		echo Root?
		read disk1
		mkfs.fat -F32 $disk1
		mkfs.ext4 $disk2
		;;
	n)
		#for non-uefi
		read disk1
		mkfs.ext4 $disk
		;;
	*)
		#for uefi systems
		echo Boot?
		read disk2
		echo Root?
		read disk1
		mkfs.fat -F32 $disk2
		mkfs.ext4 $disk1	
		;;
esac

echo please enter wifi-SSID
read wifi-name
echo Please enter wifi-password
read wifi-pass
#(connect to wifi)
iwctl station wlan0 connect $wifi-name --passphrase $wifi-pass

pacman -Syy

mount $disk1 /mnt
pacstrap /mnt base linux linux-firmware linux-headers linux-zen linux-zen-headers vim nano git

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt
