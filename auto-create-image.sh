#!/bin/bash
# Cleaning
sudo rm clockworkpi-debian.img
sudo rm -rf linux
sudo rm -rf u-boot
sudo rm boot.scr
echo "Generating image file and mounting"
sudo ./create-image.sh
echo "Generating u-boot"
./create-u-boot.sh
sudo dd if=u-boot/u-boot-sunxi-with-spl.bin of=clockworkpi-debian.img bs=1024 seek=8
echo "Generating Kernel"
./create-kernel.sh
sudo cp -p linux/uImage clockworkpi-image/BOOT/
sudo cp -p linux/arch/arm/boot/dts/sun8i-r16-clockworkpi-cpi3.dtb clockworkpi-image/BOOT/
sudo cp -p linux/arch/arm/boot/dts/sun8i-r16-clockworkpi-cpi3-hdmi.dtb clockworkpi-image/BOOT/
echo "Generating boot.scr"
mkimage -C none -A arm -T script -d boot.cmd boot.scr
sudo cp -p boot.scr clockworkpi-image/BOOT/
echo "Generating Debian files"
sudo ./create-debian.sh
echo "Installing kernel modules"
cd linux
sudo make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=$(pwd)/../clockworkpi-image/rootfs modules_install
cd ..
echo "Finishing job"
sudo umount clockworkpi-image/BOOT
sudo umount clockworkpi-image/rootfs
sudo losetup -d /dev/loop0
sudo losetup -d /dev/loop1
sudo rm -rf clockworkpi-image
