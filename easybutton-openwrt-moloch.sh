#!/bin/bash

YARA=3.5.0
GEOIP=1.6.0
MOLOCH=0.17.1

#Usage and Input Arguments
if [ -n "$3" ]; then
	export TOOLCHAINDIR=$1
	export TARGETDIR=$2
	export FILESDIR=$3
	export PREFIX=/usr
	export TDIR=$FILESDIR/root/moloch
else
	echo "Usage: easybutton-openwrt-moloch /full/path/to/your/openwrt/toolchain /full/path/to/your/openwrt/target /full/path/to/your/openwrt/install"
	echo "Please provide the FULL path for following three directories as input arguments, in same order: "
	echo "	1) Toolchain Directory for Compile (ex: ~/openwrt/staging/toolchain_...), and" 
	echo "	2) Target Directory for Compile Dependencies (ex: ~/openwrt/staging/target_...), and" 
	echo "	3) Destination Directory for Install (ex: ~/openwrt/files/)"
	exit 1
fi
export STAGING_DIR="${TOOLCHAINDIR}/.."
export BASEDIR=$PWD

mkdir -p working-dir
cd working-dir

#Tools
export CFLAGS="-I${TARGETDIR}/usr/include"
export CPPFLAGS="-I${TARGETDIR}/usr/include"
export CXXFLAGS="-I${TARGETDIR}/usr/include"
export LDFLAGS="-L${TARGETDIR}/usr/lib"
export PKG_CONFIG_PATH="${TARGETDIR}/usr/lib/pkgconfig"
export AR=$TOOLCHAINDIR/bin/arm-openwrt-linux-ar
export AS=$TOOLCHAINDIR/bin/arm-openwrt-linux-as
export LD=$TOOLCHAINDIR/bin/arm-openwrt-linux-ld
export NM=$TOOLCHAINDIR/bin/arm-openwrt-linux-nm
export CC=$TOOLCHAINDIR/bin/arm-openwrt-linux-gcc
export CPP=$TOOLCHAINDIR/bin/arm-openwrt-linux-cpp
export GCC=$TOOLCHAINDIR/bin/arm-openwrt-linux-gcc
export CXX=$TOOLCHAINDIR/bin/arm-openwrt-linux-g++
export LINK=$TOOLCHAINDIR/bin/arm-openwrt-linux-g++
export RANLIB=$TOOLCHAINDIR/bin/arm-openwrt-linux-ranlib

#Get Source Code, Configure, Build and Install Yara
rm -rf yara-$YARA.tar.gz
rm -rf yara-$YARA/
wget https://github.com/VirusTotal/yara/archive/v$YARA.tar.gz
tar zxf v$YARA.tar.gz
cd yara-$YARA/
./bootstrap.sh
./configure --host=arm-openwrt-linux \
	--prefix=$TARGETDIR/$PREFIX/ \
	--exec_prefix=$TARGETDIR/$PREFIX
make
make install
cd ..
cp -a $TARGETDIR/usr/lib/libyara.so* $FILESDIR/$PREFIX/lib

#Get Source Code, Configure, Build and Install GeoIP
rm -rf GeoIP-$GEOIP.tar.gz
rm -rf GeoIP-$GEOIP/
wget http://www.maxmind.com/download/geoip/api/c/GeoIP-$GEOIP.tar.gz
tar zxf GeoIP-$GEOIP.tar.gz
cd GeoIP-$GEOIP/
export ac_cv_func_malloc_0_nonnull=yes
export ac_cv_func_realloc_0_nonnull=yes
./configure --host=arm-openwrt-linux \
	--prefix=$TARGETDIR/$PREFIX/ \
	--exec_prefix=$TARGETDIR/$PREFIX/
make
make install
cd ..
cp -a $TARGETDIR/usr/lib/libGeoIP.so* $FILESDIR/$PREFIX/lib

#Get Source Code, Configure and Build Moloch
rm -rf v$MOLOCH.tar.gz
rm -rf moloch-$MOLOCH/
wget https://github.com/aol/moloch/archive/v$MOLOCH.tar.gz
tar zxf v$MOLOCH.tar.gz
cd moloch-$MOLOCH
patch -p1 < $BASEDIR/moloch-$MOLOCH-patch
export LIBS="-lz"
./configure --host=arm-openwrt-linux \
	--prefix=$TARGETDIR/$PREFIX/ \
	--exec_prefix=$TARGETDIR/$PREFIX/
make

# Install Moloch-Capture Binary
mkdir -p $TDIR/bin
cp capture/moloch-capture $TDIR/bin/

# Install Moloch-Capture Parsers
mkdir -p $TDIR/parsers/
cp capture/parsers/*.so $TDIR/parsers/
cp capture/parsers/*.jade $TDIR/parsers/

# Install Moloch-Viewer
mkdir -p $TDIR/viewer
cp -a viewer/* $TDIR/viewer/

# Install Moloch Configuration Templates
mkdir -p $TDIR/etc
cp ${INSTALL_DIR}/single-host/etc/* ${TDIR}/etc
cat ${INSTALL_DIR}/single-host/etc/elasticsearch.yml | sed -e "s,_TDIR_,${TDIR},g" > ${TDIR}/etc/elasticsearch.yml
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
gunzip GeoIP.dat.gz
wget http://www.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz
gunzip GeoIPASNum.dat.gz
wget https://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.csv

cd $BASEDIR

exit 0
