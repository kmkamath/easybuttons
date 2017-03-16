#!/bin/bash

NODE=6.9.5

#Usage and Input Arguments
if [ -n "$2" ]; then
	export TOOLCHAINDIR=$1
	export DESTDIR=$2
	if [ -n "$3" ]; then
		export NODE=$3
	fi
	export PREFIX=/usr/local
else
	echo "Usage: easybutton-openwrt-nodejs <build_toolchain_dir> <install_destination_dir> [node_version]"
	echo "Please provide the FULL path as input arguments, in same order: "
	echo "	1) Toolchain Directory for Compile (ex: ~/openwrt/staging/toolchain_...), and" 
	echo "	2) Destination Directory for Install (ex: ~/openwrt/files/)"
	exit 1
fi
export STAGING_DIR="${TOOLCHAINDIR}/.."

#Tools
export TOOLCHAINDIR_INC=${TOOLCHAINDIR}/include
export TOOLCHAINDIR_LIB=${TOOLCHAINDIR}/lib
export CC="arm-openwrt-linux-gcc"
export CXX="arm-openwrt-linux-g++"
export LD="arm-openwrt-linux-ld"
export CFLAGS="-isystem${TOOLCHAINDIR_INC} -march=armv6j"
export CPPFLAGS="-isystem${TOOLCHAINDIR_INC} -march=armv6j"
export LDFLAGS='-Wl,-rpath-link '${TOOLCHAINDIR_LIB}
export PATH="${TOOLCHAINDIR}/bin:$PATH"

#Get Source Code
rm -rf node-v$NODE.tar.gz
rm -rf node-v$NODE/
wget https://nodejs.org/dist/v$NODE/node-v$NODE.tar.gz
tar zxf node-v$NODE.tar.gz
cd node-v$NODE/

#Configure
if [[ $NODE =~ [0-4] ]]; then
	./configure --without-snapshot --dest-cpu=arm --dest-os=linux --without-ssl
else
	./configure --without-snapshot --dest-cpu=arm --dest-os=linux --without-ssl --without-intl --without-inspector
fi
sed -i "s@'cflags': \[\]@'cflags': \['-D__STDC_LIMIT_MACROS' ,'-D__STDC_CONSTANT_MACROS'\],'ldflags': \[ '-Wl,-rpath,$TOOLCHAINDIR_LIB'\]@g" config.gypi
find . -type f -exec sed -i 's/nearbyintf/roundf/g' {} \;
find . -type f -exec sed -i 's/nearbyint/round/g' {} \;

#Build
make -j9

#Install
make install

exit 0

