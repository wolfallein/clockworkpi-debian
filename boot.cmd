setenv bootargs earlyprintk no_console_suspend fsck.repair=yes console=ttyS0,115200 root=/dev/mmcblk0p1 rootfstype=ext4 rootwait init=/lib/systemd/systemd noinitrd panic=10 cma=256M ${extra}
setenv bootdelay 3
ext4load mmc 0 0x48000000 /boot/uImage
if gpio input pl11;
then
	ext4load mmc 0 0x49000000 /boot/sun8i-r16-clockworkpi-cpi3.dtb;
else
	ext4load mmc 0 0x49000000 /boot/sun8i-r16-clockworkpi-cpi3-hdmi.dtb;
fi;
bootm 0x48000000 - 0x49000000
