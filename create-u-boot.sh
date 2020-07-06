#!/bin/bash
git clone https://github.com/u-boot/u-boot.git --depth=1
cd u-boot
cp ../cpi-u-boot.patch .
git apply cpi-u-boot.patch
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
make clockworkpi-cpi3_defconfig
make -j$(nproc)
cd ..
