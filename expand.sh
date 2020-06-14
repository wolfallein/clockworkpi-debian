echo -e "d\n2\nn\np\n2\n94208\n\nN\nw\n" | fdisk /dev/mmcblk0
resize2fs /dev/mmcblk0p2
sed -i '/expand.sh/d' /root/.profile
rm /root/expand.sh
systemctl reboot
