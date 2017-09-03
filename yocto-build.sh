#!/bin/bash

#Get latest commit from master branch by default
YOCTO=	

#Usage and Input Arguments
if [ -n "$1" ]; then
	export YOCTO=$1
else
	echo "Usage: yocto-build yocto_release_name"
	exit 1
fi

mkdir -p working-dir
cd working-dir

#Get Source Code
rm -rf poky/
git clone -b $YOCTO git://git.yoctoproject.org/poky
cd poky
git clone -b $YOCTO git://git.yoctoproject.org/meta-raspberrypi
#source oe-init-build-env
#read -p 'Add "meta-raspberrypi" layer to conf/bblayers.conf and MACHINE ?= "raspberrypi3", GPU_MEM = "16" in conf/local.conf. Then press [Enter] to resume...'
#bitbake rpi-basic-image
