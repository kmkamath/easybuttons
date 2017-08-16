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
	export TDIR=/root/moloch
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

export MOLOCHUSER=daemon
export GROUPNAME=daemon
export PASSWORD=0mgMolochRules1
export INTERFACE=eth0
export BATCHRUN=yes

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
cp -a $TARGETDIR/usr/lib/libyara.so* $FILESDIR/$PREFIX/lib
cd ..

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
cp -a $TARGETDIR/usr/lib/libGeoIP.so* $FILESDIR/$PREFIX/lib
cd ..

#Get Source Code, Configure, Build and Install Moloch
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
#Install...
rm -rf $FILESDIR/$TDIR
#Moloch-Capture Binary
mkdir -p $FILESDIR/$TDIR/bin
cp capture/moloch-capture $FILESDIR/$TDIR/bin/
#Moloch-Viewer
mkdir -p $FILESDIR/$TDIR/viewer
cp -a viewer/* $FILESDIR/$TDIR/viewer/
#Moloch-Viewer
mkdir -p $FILESDIR/$TDIR/raw
# Install Moloch-Capture Parsers
mkdir -p $FILESDIR/$TDIR/parsers/
cp capture/parsers/*.so $FILESDIR/$TDIR/parsers/
cp capture/parsers/*.jade $FILESDIR/$TDIR/parsers/
#Moloch Configuration Templates
mkdir -p $FILESDIR/$TDIR/etc
cp single-host/etc/* $FILESDIR/$TDIR/etc
cat single-host/etc/elasticsearch.yml | sed -e "s,_TDIR_,${TDIR},g" > $FILESDIR/$TDIR/etc/elasticsearch.yml
./easybutton-config.sh "$FILESDIR/$TDIR"
cat $FILESDIR/${TDIR}/etc/config.ini.template | sed -e 's/_PASSWORD_/'${PASSWORD}'/g' -e 's/_USERNAME_/'${MOLOCHUSER}'/g' -e 's/_GROUPNAME_/'${GROUPNAME}'/g' -e 's/_INTERFACE_/'${INTERFACE}'/g'  -e "s,_TDIR_,${TDIR},g" > $FILESDIR/${TDIR}/etc/config.ini
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
gunzip GeoIP.dat.gz > $FILESDIR/$TDIR/etc/GeoIP.dat
wget http://www.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz
gunzip GeoIPASNum.dat.gz > $FILESDIR/$TDIR/etc/GeoIPASNum.dat
wget -O $FILESDIR/$TDIR/etc/ipv4-address-space.csv https://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.csv
cd ..

#Get Source Code, Configure, Build and Install fs-ext
NODEFSEXT=0.5.0
rm -rf v$NODEFSEXT.tar.gz
rm -rf node-fs-ext-$NODEFSEXT/
wget https://github.com/baudehlo/node-fs-ext/archive/v$NODEFSEXT.tar.gz
tar zxf v$NODEFSEXT.tar.gz
cd node-fs-ext-0.5.0/
#npm --arch=arm --target=v4.6.0 install
rm -rf $FILESDIR/$TDIR/viewer/node_modules/fs-ext
mkdir -p $FILESDIR/$TDIR/viewer/node_modules/fs-ext
cp -a * $FILESDIR/$TDIR/viewer/node_modules/fs-ext/
cd ..

#Get Source Code, Configure, Build and Install png
NODEPNG=3.0.3
rm -rf $NODEPNG.tar.gz
rm -rf node-png-$NODEPNG/
wget https://github.com/pkrumins/node-png/archive/$NODEPNG.tar.gz
tar zxf $NODEPNG.tar.gz
cd node-png-$NODEPNG/
#unzip -o node-png-node-v12.zip
#cd node-png-node-v12/
#npm --arch=arm --target=v4.6.0 install
rm -rf $FILESDIR/$TDIR/viewer/node_modules/png
mkdir -p $FILESDIR/$TDIR/viewer/node_modules/png
cp -a * $FILESDIR/$TDIR/viewer/node_modules/png/
cd ..
cd $BASEDIR

exit 0
