#!/bin/bash

#Usage and Input Arguments
if [ -z "$2" ]; then
	echo "Usage: openwrt-install path/to/image /full/path/to/device"
	echo "Please provide the path for following two, in same order: "
	echo "	1) Image File (ex: if=bin/brcm2708/openwrt-brcm2708-bcm2710-rpi-3-ext4-sdcard.img)" 
	echo "	2) Files Directory (ex: /dev/mmcblk0)"
	exit 1
fi

sudo dd if=$1 of=$2 bs=2M conv=fsync
echo "Flashed new image. Now resize second partition using gparted. Then refresh to mount partition and copy packages"
echo "sudo cp -a bin/<target type>/packages/ <mounted rootfs partition>/usr/"
