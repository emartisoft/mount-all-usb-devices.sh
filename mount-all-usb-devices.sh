#!/bin/bash
# Mount all usb devices on Linux
# Coded by emarti, Murat Ozdemir
# ====================================
USBDEVICES=/var/usbdevices.txt
CURRENTUSBLABEL=/var/usblabel.txt

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# list all devices
blkid | grep "/dev/sd" | awk -F ":" '{print $1}' > $USBDEVICES

declare -i usbcount=0

# umount and remove all usb devices from /mnt folder 
umount /mnt/*
rm -f -d /mnt/*

while IFS= read -r usbdevice
do
    usbcount=$((usbcount+1))
    blkid | grep "$usbdevice" | awk -F "LABEL=" '{print $2}' | awk -F "\"" '{print $2}' > $CURRENTUSBLABEL
    usblabel=$(cat $CURRENTUSBLABEL)
    if [ -z "$usblabel" ]
    then
# defined label
		mkdir -p /mnt/usb$usbcount
		mount -t auto "$usbdevice" /mnt/usb$usbcount
    else
# undefined label
		mkdir -p /mnt/$usblabel
		mount -t auto "$usbdevice" /mnt/$usblabel
    fi
done <"$USBDEVICES"

#printf "Total mounted USB devices count: %d\n" $usbcount
#ls /mnt

