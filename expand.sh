echo -e "d\nn\np\n1\n8192\n\nN\nw\n" | sudo fdisk /dev/mmcblk0
sudo resize2fs /dev/mmcblk0p1
sed -i '/expand.sh/d' /home/cpi/.profile
sudo rm /home/cpi/expand.sh
sudo systemctl reboot
