#!/bin/bash

mkdir clockworkpi-image
#mkdir clockworkpi-image/BOOT
mkdir clockworkpi-image/rootfs

dd if=/dev/zero of=clockworkpi-debian.img bs=1M seek=1800 count=0
echo -e "n\np\n1\n8192\n\nt\n83\nw\n" | fdisk clockworkpi-debian.img

#losetup -o 48234496 --sizelimit 2000M /dev/loop1 clockworkpi-debian.img
losetup -o 4194304 --sizelimit 1750M /dev/loop0 clockworkpi-debian.img
mkfs.ext4 /dev/loop0 -L rootfs
mount -t ext4 /dev/loop0 clockworkpi-image/rootfs
