#!/bin/bash
git clone https://github.com/smaeul/linux.git --branch=patch/irqchip-v2 --depth=1
cd linux
cp ../cpi-kernel-5.7.smaeul.patch .
git apply cpi-kernel-5.7.smaeul.patch
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
make clockworkpi_cpi3_defconfig
make -j$(nproc)
mkimage -A arm -O linux -T kernel -C none -a 0x40008000 -e 0x40008000 -n "Linux kernel" -d arch/arm/boot/zImage uImage
chmod +x uImage
cd ..
