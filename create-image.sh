#!/bin/bash

mkdir clockworkpi-image
mkdir clockworkpi-image/BOOT
mkdir clockworkpi-image/rootfs

dd if=/dev/zero of=clockworkpi-debian.img bs=1M seek=1224 count=0
echo -e "n\np\n1\n8192\n93814\nn\np\n2\n94208\n\nt\n1\nc\nt\n2\n83\nw\n" | fdisk clockworkpi-debian.img

# Mount first partition

losetup -o 4194304 --sizelimit 41.8M /dev/loop0 clockworkpi-debian.img
mkfs.vfat /dev/loop0
fatlabel /dev/loop0 BOOT
mount -t vfat /dev/loop0 clockworkpi-image/BOOT

# Mount second partition

losetup -o 48234496 --sizelimit 1178M /dev/loop1 clockworkpi-debian.img
mkfs.ext4 /dev/loop1 -L rootfs
mount -t ext4 /dev/loop1 clockworkpi-image/rootfs
