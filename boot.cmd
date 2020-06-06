setenv bootargs earlyprintk no_console_suspend fsck.repair=yes root=/dev/mmcblk0p2 rootfstype=ext4 rootwait init=/lib/systemd/systemd noinitrd panic=10 cma=256M ${extra}
fatload mmc 0 0x48000000 uImage
if gpio input pl11;
then
	fatload mmc 0 0x49000000 sun8i-r16-clockworkpi-cpi3.dtb;
else
	fatload mmc 0 0x49000000 sun8i-r16-clockworkpi-cpi3-hdmi.dtb;
fi;
bootm 0x48000000 - 0x49000000
