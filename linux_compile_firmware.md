# Compiling Linux Firmware

In this chapter, we'll walk through the steps of compiling Linux firmware for [ROC-RK3328-CC].

## Preparation

The Linux firmware is built under the following environment:
 - 64 bit CPU
 - Ubuntu 16.04

Install following packages:
```bash
sudo apt-get install git repo gnupg flex bison gperf build-essential \
     zip tar curl libc6-dev gcc-arm-linux-gnueabihf \
     gcc-aarch64-linux-gnu device-tree-compiler lzop libncurses5-dev \
     libssl1.0.0 libssl-dev mtools
```

## Download Linux SDK

Create project directory:
```bash
# create project dir
mkdir ~/proj/roc-rk3328-cc
cd ~/proj/roc-rk3328-cc
```

Download Linux SDK:
```
# U-Boot
git clone -b release https://github.com/FireflyTeam/u-boot
# Kernel
git clone -b release-4.4 https://github.com/FireflyTeam/kernel
# Build
git clone -b debian https://github.com/FireflyTeam/build
# Rkbin
git clone -b master https://github.com/FireflyTeam/rkbin
```

You can also browse the source code online using the github links above.

TODO: kernel.git is too big to download from github

The board build config is inside:

    build/board_configs.sh 

## Compiling U-Boot

Compile U-Boot:
```
./build/mk-uboot.sh roc-rk3328-cc
```

Ouput:
```
out/u-boot/
├── idbloader.img
├── rk3328_loader_ddr786_v1.06.243.bin
├── trust.img
└── uboot.img
```
 - `rk3328_loader_ddr786_v1.06.243.bin`: A DDR init bin
 - `idbloader.img`: Image combined with DDR init bin and miniloader bin
 - `trust.img`: ARM trusted firmware
 - `uboot.img`: U-Boot image


Related files:
- `configs/roc-rk3328-cc_defconfig`: default U-Boot config

## Compiling Kernel

Compile kernel:
```
./build/mk-kernel.sh roc-rk3328-cc
```

Ouput:
```
out/
├── boot.img
└── kernel
    ├── Image
    └── rk3328-roc-cc.dtb
```

 - `boot.img`: A image file containing `Image` and `rk3328-roc-cc.dtb`, in fat32 filesystem format.
 - `Image`: Kernel image
 - `rk3328-roc-cc.dtb`: Device tree blob
 
Related files:
- `arch/arm64/configs/fireflyrk3328_linux_defconfig`: default kernel config
- `arch/arm64/boot/dts/rockchip/rk3328-roc-cc.dts`: board dts
- `arch/arm64/boot/dts/rockchip/rk3328.dtsi`: soc dts
 
To customize the kernel config and update the default config:
```
# this is important!
export ARCH=arm64

cd kernel

# first use default config
make fireflyrk3328_linux_defconfig

# customize your kernel
make menuconfig

# save as default config
make savedefconfig
cp defconfig arch/arm64/configs/fireflyrk3328_linux_defconfig
```

**NOTE**: The build script does not copy kernel modules to the root filesystem. You have to do it yourself.

## Building Root Filesystem

You can download the prebuilt root filesystem:
 
Or build one yourself by following [Linux Building Root Filesystem](linux_build_rootfilesystem.html).

## Packing Raw Format Firmware

Place your Linux root filesystem image file as `out/rootfs.img`.

The `out` directory should contain the following files:
```
$ tree out
out
├── boot.img
├── kernel
│   ├── Image
│   └── rk3328-roc-cc.dtb
├── rootfs.img
└── u-boot
    ├── idbloader.img
    ├── rk3328_loader_ddr786_v1.06.243.bin
    ├── trust.img
    └── uboot.img

2 directories, 8 files
```

To create the raw format firmware:
```
./build/mk-image.sh -c rk3328 -t system -r out/rootfs.img
```

The command above will pack the neccessary image files into `out/system.img`, according to this [storage map](http://opensource.rock-chips.com/wiki_Partitions#Default_storage_map).

To flash this raw format firmware, please follow the [Getting Started](started.html) chapter.

[ROC-RK3328-CC]: http://en.t-firefly.com/product/rocrk3328cc.html "ROC-RK3328-CC Official Website"
