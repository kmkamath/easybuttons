#!/bin/bash

#Get latest commit from master branch by default
OPENWRT=	

#Usage and Input Arguments
if [ -n "$3" ]; then
	export FILESDIR=$1
	export DIFFCONFIG=$2
	export DLDIR=$3
	export OPENWRT=$4
else
	echo "Usage: easybutton-openwrt /full/path/to/your/openwrt/files /full/path/to/your/config.diff /full/path/to/your/dl [opwenwrt_version]"
	echo "Please provide the FULL path for following two directories as input arguments, in same order: "
	echo "	1) Files Directory (ex: ~/openwrt-defconfig/files/)"
	echo "	2) Config File (ex: ~/config.diff)" 
	echo "	3) Download Directory (ex: ~/archive/dl-master/)"
	exit 1
fi

#Get Source Code
if [ -n "$OPENWRT" ]; then
	rm -rf v$OPENWRT.tar.gz
	rm -rf openwrt-$OPENWRT/
	wget https://github.com/openwrt/openwrt/archive/v$OPENWRT.tar.gz
	tar zxf v$OPENWRT.tar.gz
	cd openwrt-$OPENWRT
else
	rm -rf openwrt/
	git clone https://github.com/openwrt/openwrt.git
	cd openwrt
fi

#Configure
./scripts/feeds update -a
./scripts/feeds install -a
cp $DIFFCONFIG .config
make defconfig
cp -a $FILESDIR .
rm -rf dl
ln -sf $DLDIR dl

#Build
time make -j9

exit 0
