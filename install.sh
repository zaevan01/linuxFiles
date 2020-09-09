ls /sys/firmware/efi/efivars
echo Is system UEFI? (Y/n)
uefi=Y
read uefi

fdisk -l
echo Please select a disk:
read disk
fdisk $disk

#(if above ls command doesn't return "not found")
#Fdisk command sequence:
#d(elete)
#n(ew partition)
#1
#+512M
#t(ype change)
#1(EFI system partition type label)

#n(ew partition)
#(defaults until finished)
#w(rite)

#create filesystem
case $uefi in
	y)
		#for uefi systems
		mkfs.fat -F32 $((disk)1)
		mkfs.ext4 $((disk)2)
		;;
	n)
		#for non-uefi
		mkfs.ext4 $disk
		;;
	*)
		#for uefi systems
		mkfs.fat -F32 $((disk)1)
		mkfs.ext4 $((disk)2)	
		;;


#(connect to wifi)
wifi-menu

pacman -Syy
pacman -S reflector
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector -c "US" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist

mount root /mnt
pacstrap /mnt base linux linux-firmware vim nano git

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

timedatectl list-timezones
echo Please enter a timezone:
read zone
timedatectl set-timezone $zone

locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

echo Hostname:
read hName
echo $hName >> /etc/hostname

echo '127.0.0.1 localhost' >> /etc/hosts
echo '::1 localhost' >> /etc/hosts
echo '127.0.0.1 '$hName >> /etc/hosts

passwd

case $uefi in
	y)
		#for uefi systems
		pacman -S grub efibootmgr
		mkdir /boot/efi
		mount /dev/sda1 /boot/efi
		grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
		grub-mkconfig -o /boot/grub/grub.cfg
		;;
	n)
		#for non-uefi
		pacman -S grub
		grub-install /dev/sda
		grub-mkconfig -o /boot/grub/grub.cfg
		;;
	*)
		#for uefi systems
		pacman -S grub efibootmgr
		mkdir /boot/efi
		mount /dev/sda1 /boot/efi
		grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
		grub-mkconfig -o /boot/grub/grub.cfg
		;;
esac


echo Please enter a username:
read uName
useradd -m $uName
passwd $uName

pacman -S sudo
EDITOR=nano visudo
#add zac ALL=(ALL) ALL NOPASSWD:ALL

pacman -S xorg plasma plasma-wayland-session kde-applications
systemctl enable sddm.service
systemctl enable NetworkManager.service


git clone https://aur.archlinux.org/trizen.git
cd trizen
makepkg -si

git clone https://github.com/zaevan01/linuxFiles.git
mv /etc/pacman.conf /etc/pacman.conf.bak
cp ~/linuxFiles/pacman.conf /etc/pacman.conf
mv ~/.bashrc ~/.bashrc.bak
cp ~/linuxFiles/.bashrc ~/.bashrc

trizen -S nvidia amd-ucode steam terminator minecraft 

mv /etc/x11/xorg.conf /etc/x11/xorg.conf.bak
cp ~/linuxFiles/xorg.conf.bak /etc/x11/xorg.conf


