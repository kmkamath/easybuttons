easybuttons
=========

Our target ecosystem is comprised of Raspberry Pi hardware, lightweigh OpenWRT Distribution and popular NodeJS server side language. These easybutton scripts help us setup our target ecosystem quickly.

Considering non-existent updates to OpenWrt, lately I have also been looking into moving to Yocto or Raspbian Lite (Debian)

## Usage

### openwrt-build
```sh	
$openwrt-build /full/path/to/your/openwrt/files /full/path/to/your/config.diff /full/path/to/your/feeds.conf.default /full/path/to/your/dl [opwenwrt_version]
```
`/full/path/to/your/openwrt/files` The first input argument asks you to provide your custom file directory location as an absolute path.

*OpenWRT build system allows you to easily update pretty much any file in your root file system by simply placing them under **files** firectory (See [here](https://wiki.openwrt.org/doc/howto/build#custom_files) for more details).*

`/full/path/to/your/config.diff` The second input argument asks you to provide your custom default config.diff file location as an absolute path.

*OpenWRT has a very flexible package build and management system, almost too flexible. Its best to chose the packages you need before-hand as a default config (See [here](https://wiki.openwrt.org/doc/howto/build#configure_using_config_diff_file) for more details).*

`/full/path/to/your/feeds.conf.default` The third input argument asks you to provide your custom feeds.conf.default file location as an absolute path.

*OpenWRT package repositories aren't updated frequently, inspite of a package management system that enables frequent update! I fork the package feeds as necessary, make my changes and point the feeds.conf.default to this forked git repository*

`/full/path/to/your/dl` The fourth input argument asks you to provide your custom dl directories with downloaded source tarballs from successful build. If this is your first build and don't have any downloaded sources, you still need to provide a link to an empty directory.

*Even before these new packagae management systems like npm were devised, OpenWRT followed a similar principal i.e. it doesn't contain any executables or even sources. It's an automated system for downloading the sources, patching them to work with the given platform and compiling them correctly for the platform. Well, thats really neat, and basically what allowed OpenWRT to be one of the most universally supported distributions on multiple consumer grade AP and Router devices. However, atleast one site or mirror hosting the upstream repsository is almost always down resulting in download failures and subsequently build failures. Hence, once you have a successful build I suggest you copy the 'dl' directory so repeated builds dont fail*

`opwenwrt_version` The last input argument is optional, and represents the OpenWRT release version. If you do not provide this input argument the script simply picks the latest commit from OpenWRT master branch.

*As of writing this (15 Mar 2017) Raspberry Pi3 was not supported in any official OpenWRT release, and only supported in master branch.*


### openwrt-install
```sh	
$openwrt-install path/to/image /full/path/to/device
```
This script really doesn't do much, and purely for my own convenice. It simply does a 'dd' copy of the image provided as first input argument to device provided as second input argument. Please be very careful of executing this command as it has the potential of runing you host PC if you aren't careful with respect to providing second input argument.

### openwrt-nodejs
```sh	
$openwrt-install /full/path/to/your/openwrt/toolchain /full/path/to/your/openwrt/files [nodejs_version]
```

The NodeJS that comes packages with OpenWRT is 0.12.x version. In order to use the later 4.x or 6.x version of NodeJS on OpenWRT you need to build it from the source. This easybutton script simplifies this. Btw, the scripts borrows liberally from [this](http://techfindings.one/archives/2498) online blog.

`/full/path/to/your/openwrt/toolchain` The first input argument asks you to provide your openwrt toolchain as an absolute path. For ex: ~/easybuttons/openwrt/staging_dir/toolchain-arm_cortex-a53+neon-vfpv4_gcc-5.3.0_musl-1.1.16_eabi

`/full/path/to/your/openwrt/files` The first input argument asks you to provide your openwrt file directory location as an absolute path. For ex: ~/easybuttons/openwrt/files. The node/npm binaries and npm library modules are all copied to /usr/local under this absolute path. 

`nodejs_version` The last input argument is optional, and represents the NodeJS release version. If you do not provide this input argument the script simply picks NodeJS release v6.9.5. The script was tested to work on both 4.6.0 and 6.9.5, which is default version it downloads if user doesn't specify the nodejs_version third input argument.
