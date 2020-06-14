#!/bin/bash
rootfs_dir="clockworkpi-image/rootfs"

# Create filesystem with packages
multistrap -a armhf -f multistrap.conf

# Copy bluetooth firmware loader
cp -p brcm_patchram_plus $rootfs_dir/usr/bin/
chmod +x $rootfs_dir/usr/bin/brcm_patchram_plus
cp -p brcmloader.service $rootfs_dir/etc/systemd/system/
chmod 644 $rootfs_dir/etc/systemd/system/brcmloader.service

# Configure new system
cp /usr/bin/qemu-arm-static $rootfs_dir/usr/bin
mount -o bind /dev/ $rootfs_dir/dev/
# Set environment variables
export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export LC_ALL=C LANGUAGE=C LANG=C
chroot $rootfs_dir dpkg --configure -a
# For some reason the following packages are configured before dependences
# Try to reconfigure. Maybe can be removed in future.
chroot $rootfs_dir dpkg --configure base-files
chroot $rootfs_dir dpkg --configure bash
# Empty root password
chroot $rootfs_dir passwd -d root
# Enable new systemctl service for bluetooth firmware loader at boot
chroot $rootfs_dir systemctl enable brcmloader.service
# Kill processes running in rootfs
fuser -sk $rootfs_dir
rm $rootfs_dir/usr/bin/qemu-arm-static
umount $rootfs_dir/dev/

# Copy bt/wifi firmware
mkdir $rootfs_dir/lib/firmware
rsync -a brcm/* $rootfs_dir/lib/firmware/brcm/

# Create fstab
#microSD partitions mounting
filename=$rootfs_dir/etc/fstab
echo /dev/mmcblk0p1 /boot vfat noatime 0 1 >> $filename
echo /dev/mmcblk0p2 / ext4 noatime 0 1 >> $filename
echo proc /proc proc defaults 0 0 >> $filename

# Copy network files
cp interfaces $rootfs_dir/etc/network/
cp wpa_supplicant.conf $rootfs_dir/etc/wpa_supplicant/

# Add modules to start at boot
echo brcmfmac >> $rootfs_dir/etc/modules
echo blacklist sunxi_cedrus > $rootfs_dir/etc/modprobe.d/nocedrus.conf

# Fix dhcp server for RNDIS usb
echo "subnet 192.168.11.0 netmask 255.255.255.0 {
  range 192.168.11.10 192.168.11.250;
}" >> $rootfs_dir/etc/dhcp/dhcpd.conf
sed -i "s/option domain-name/#option domain-name/" $rootfs_dir/etc/dhcp/dhcpd.conf
sed -i "s/option domain-name-servers/#option domain-name-servers/" $rootfs_dir/etc/dhcp/dhcpd.conf
echo INTERFACES=\"usb0\" >> $rootfs_dir/etc/default/isc-dhcp-server

# Enable root autologin on serial
#filename=$rootfs_dir/lib/systemd/system/serial-getty@.service
#autologin='--autologin root'
#execstart='ExecStart=-\/sbin\/agetty'
#if [[ ! $(grep -e "$autologin" $filename) ]]; then
#    sed -i "s/$execstart/$execstart $autologin/" $filename
#fi

# Enable root autologin on TTY1
filename=$rootfs_dir/lib/systemd/system/getty@.service
autologin='--autologin root'
execstart='ExecStart=-\/sbin\/agetty'
if [[ ! $(grep -e "$autologin" $filename) ]]; then
    sed -i "s/$execstart/$execstart $autologin/" $filename
fi

# Set systemd logging
filename=$rootfs_dir/etc/systemd/system.conf
for i in 'LogLevel=warning'\
         'LogTarget=journal'\
; do
    sed -i "/${i%=*}/c\\$i" $filename
done

# Enable root to connect to ssh with empty password
filename=$rootfs_dir/etc/ssh/sshd_config
if [[ -f $filename ]]; then
    for i in 'PermitRootLogin yes'\
             'PermitEmptyPasswords yes'\
             'UsePAM no'\
    ; do
        sed -ri "/^#?${i% *}/c\\$i" $filename
    done
fi

# Expand filesystem executable
cp -p expand.sh $rootfs_dir/root/
echo "/root/expand.sh" >> $rootfs_dir/root/.profile

### If Retroarch is installed and you want it to start on boot
# Execute retroarch at boot
echo "if [[ \"\$(tty)\" == \"/dev/tty1\" ]]
 then
  retroarch
fi" >> $rootfs_dir/root/.profile
# Copy new retroarch configuration with tweaks for CPI
tar xzf retroarch-config.tar.gz --directory $rootfs_dir
# Replace executable file
#cp -p retroarch $rootfs_dir/usr/bin/
#chmod +x $rootfs_dir/usr/bin/retroarch

echo
echo "$rootfs_dir configured"
