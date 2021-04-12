# clockworkpi-debian : A minimal Debian OS for clockworkpi device based on Allwinner R16 SOC

![retroarch running debian bullseye]()

## Bin folder

For convenience I added compiled kernel files (uImage, dts, boot.scr) to the bin folder if you just want to update your system.
Just copy the files to /BOOT.

## Dependencies (Debian/Ubuntu)

General:

````
sudo apt install git build-essential
````

For u-boot build:

````
sudo apt install gcc-arm-linux-gnueabihf \
    bison flex swig python3-distutils python3-dev
````

For Linux Kernel 5.7:

````
sudo apt install libssl-dev u-boot-tools
````

For generating Debian rootfs:

````
sudo apt install multistrap qemu-user-static
````

thanks @omgmog

## Automatic procedure

Run:

````
./auto-create-image.sh
````

Copy image to SD card (Replace /dev/sdX with your SD card):

````
sudo dd bs=4M if=clockworkpi-debian.img of=/dev/sdX conv=fsync
````

If you have problems, try using `bs=1M`.

## Manual procedure

### SD card preparation

Use `lsblk` to make sure you are working with the SD card. Replace `/dev/sdX` with your device.

#### Create partitions
````
sudo fdisk /dev/sdX
````
1. Delete all existent partitions. Use `d` to delete.
2. Create two new primary partitions. Use option `n` to create.

  First Partition `Start = 8192 End = 93814`
  Second partition `Start = 94218 End = XXX` - End = Size available for your OS. You can use any size.

3. Define `vfat` type for first partition. Use `t`, `1` to select first partition, and use code `c` for `W95 FAT32 (LBA)`
4. Define `ext` type for second partition. Use `t`, `2` to select second partition, and use `83` for `Linux`.

You must have a similar table (Use `p` to check):

````
Device     Boot Start      End  Sectors  Size Id Type
/dev/sdb1        8192    93814    85623 41.8M  c W95 FAT32 (LBA)
/dev/sdb2       94208 62521343 62427136 29.8G 83 Linux
````

5. Use `w` to write new partition table.

#### Format the SD card, and set the labels (labels are not neccessary, but convenient)

````
sudo mkfs.vfat /dev/sdX1
sudo fatlabel /dev/sdX1 BOOT
sudo mkfs.ext4 /dev/sdX2 -L rootfs
````

### u-boot

````
git clone git://git.denx.de/u-boot.git --depth=1
cd u-boot
cp ../cpi-u-boot.patch .
git apply cpi-u-boot.patch
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
make clockworkpi-cpi3_defconfig
make
sudo dd if=u-boot-sunxi-with-spl.bin of=/dev/sdX bs=1024 seek=8
cd ..
````

### Kernel - 5.7

You can use mainline. I use smaeul's for better power management support.

````
git clone https://github.com/smaeul/linux.git --branch=patch/irqchip-v2 --depth=1
cd linux
cp ../cpi-kernel-5.7.smaeul.patch .
git apply cpi-kernel-5.7.smaeul.patch
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
make clockworkpi_cpi3_defconfig
make
mkimage -A arm -O linux -T kernel -C none -a 0x40008000 -e 0x40008000 -n "Linux kernel" -d arch/arm/boot/zImage uImage
chmod +x uImage
sudo cp -p uImage /media/$USER/BOOT/
sudo cp -p arch/arm/boot/dts/sun8i-r16-clockworkpi-cpi3.dtb /media/$USER/BOOT/
sudo cp -p arch/arm/boot/dts/sun8i-r16-clockworkpi-cpi3-hdmi.dtb /media/$USER/BOOT/
cd ..
````

### Generate boot.scr

````
mkimage -C none -A arm -T script -d boot.cmd boot.scr
sudo cp -p boot.scr /media/$USER/BOOT/
````

### Generate Debian root

If you want to have wifi already connected, change the contents of `wpa_supplicant.conf` with your information.

````
sudo ./create-debian.sh
sudo rsync -axHAX --progress target-rootfs/ /media/$USER/rootfs/
sudo umount /media/$USER/rootfs
````

Don't interrupt the script. It uses chroot.

umount will take a while, be patient.

Insert SD cart in the device and boot.

## Troubleshooting

### apt

If you have a error with apt like:

````
dpkg: error processing package base-files (--configure):
 installed base-files package post-installation script subprocess returned error exit status 1
dpkg: dependency problems prevent configuration of bash:
````

Run on the device:

````
apt clean
apt remove base-files
apt install base-files bash
````

### No sound

Use `alsamixer` to unmute `AIF1 Slot 0`:

Navigate with cursor and use `M` to unmute.

### Set locale

https://wiki.debian.org/Locale

### Forum and other users

Other users and help can be found in the clockworkpi forum : https://forum.clockworkpi.com/

In particular [the initial thread about this project](https://forum.clockworkpi.com/t/os-retroarch-debian-os-image-based-on-the-minimal-debian-u-boot-kernel-and-debian-from-scratch-v0-3/5707).

## Known Issues

1. HDMI audio doesn't work, the sound is being routed to GameShell speakers. To have HDMI out connect the HDMI cable and reboot.
1. ~~Charging/Power LED doesn't work.~~ FIXED



## sites for reference

https://www.acmesystems.it/debian_wheezy

https://github.com/jubinson/debian-rootfs.git

https://github.com/clockworkpi/USB-Ethernet

https://linux-sunxi.org/U-Boot

https://linux-sunxi.org/LCD

https://github.com/balena-os/brcm_patchram_plus

https://github.com/clockworkpi/bluetooth/wiki
