# Compiling Android 7.1

## Preparation

### Hardware Requiremnts

Recommended hardware requirement of development workstation compiling Android 7.1:
 - 64 bit CPU
 - 16GB  Physical memory + Swap memory
 - 30GB  Free disk space is used for building, and the source tree takes about 8GB
    
See also the hardware and software configuration stated in Google official document:
 - [https://source.android.com/setup/build/requirements](https://source.android.com/setup/build/requirements)
 - [https://source.android.com/setup/initializing](https://source.android.com/setup/initializing)

### Software Requiements

**Installing JDK 8** 
```bash
sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install openjdk-8-jdk
```

**Installing required packages**

```bash
sudo apt-get install git-core gnupg flex bison gperf libsdl1.2-dev \
  libesd0-dev libwxgtk2.8-dev squashfs-tools build-essential zip curl \
  libncurses5-dev zlib1g-dev pngcrush schedtool libxml2 libxml2-utils \
  xsltproc lzop libc6-dev schedtool g++-multilib lib32z1-dev lib32ncurses5-dev \
  lib32readline-gplv2-dev gcc-multilib libswitch-perl

sudo apt-get install gcc-arm-linux-gnueabihf \
  libssl1.0.0 libssl-dev \
  p7zip-full
```

## Downloading Android SDK

Due to the huge size of the Android SDK, please select one of the following clouds to download `ROC-RK3328-CC_Android7.1.2_git_20171204.7z`:
 - [Baiduyun](https://pan.baidu.com/s/1eRT6isE "Android 7.1 SDK baiduyun")
 - [Google Drive](https://drive.google.com/drive/folders/1N8fpfoeWLD4-VJcYN6Qfh_3-YBYzXxGq "Android 7.1 SDK Google Drive")

After the download completes, verify the MD5 checksum before extraction:
```
$ md5sum /path/to/ROC-RK3328-CC_Android7.1.2_git_20171204.7z
6d34e51fd7d26e9e141e91b0c564cd1f ROC-RK3328-CC_Android7.1.2_git_20171204.7z
```

Then extract it:
```bash
mkdir -p ~/proj/roc-rk3328-cc
cd ~/proj/roc-rk3328-cc
7z x /path/to/ROC-RK3328-CC_Android7.1.2_git_20171204.7z
git reset --hard
```

Update the correct git remote:
```bash
git remote rm origin 
git remote add gitlab  https://gitlab.com/TeeFirefly/RK3328-Nougat.git
```

Synchronize source code from gitlab:
```bash
git pull gitlab roc-rk3328-cc:roc-rk3328-cc
```

You can also view the source code online at:
  [https://gitlab.com/TeeFirefly/RK3328-Nougat/tree/roc-rk3328-cc](https://gitlab.com/TeeFirefly/RK3328-Nougat/tree/roc-rk3328-cc)

## Compiling with Firefly Scripts

**Compiling Kernel**
```bash
./FFTools/make.sh -k -j8
```

**Compiling U-Boot**
```bash
./FFTools/make.sh -u -j8
```

**Compiling Android**    
```bash
./FFTools/make.sh -a -j8
```

**Compiling Everying**

This will compile kernel, U-Boot and Android with a single command:
```bash
./FFTools/make.sh -j8
```

## Compiling Without Script

Before compilation, execute the following commands to configure environment variables:

```bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
export PATH=$JAVA_HOME/bin:$PATH 
export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
```

**Compiling Kernel**
```bash
make ARCH=arm64 firefly_defconfig
make -j8 ARCH=arm64 rk3328-roc-cc.img
```

**Compiling U-Boot**
```bash
make rk3328_box_defconfig
make ARCHV=aarch64 -j8
```

**Compiling Android**
```bash
source build/envsetup.sh
lunch roc_rk3328_cc_box-userdebug
make installclean
make -j8
./mkimage.sh
```

## Packing Rockchp Firmware

**Packing Fimware in Linux**

After compiling you can use Firefly official script to pack all partition image files into the one true Rockchip firmware, by executing the following command:
```bash
./FFTools/mkupdate/mkupdate.sh update
```

The resulting file is `rockdev/Image-rk3328_firefly_box/update.img`.

**Packing Fimware in Windows**

It is also very simple in packaging Rockchip firmware `update.img` under Windows:
1. Copy all the compiled files in `rockdev/Image-rk3328_firefly_box/` to the `rockdev\Image` directory of AndroidTool
2. Run the `mkupdate.bat` batch file in the `rockdev` directory of AndroidTool.
3. `update.img` will be created in `rockdev\Image` directory.

## Partition Images

`update.img` is the firmware released to end users, which is convenient to upgrade the system of the deveopment board.

During development cycle, it is a great time saving to only flash modified partition images.

Here's a table summarising the partition image in various stage:

```
|------------------|---------------------|-----------|
| Stage            | Product             | Partition |
|------------------|---------------------|-----------|
| Compiling Kernel | kernel/kernel.img   | kernel    |
|                  | kernel/resource.img | resource  |
|------------------|---------------------|-----------|
| Compiling U-Boot | u-boot/uboot.img    | uboot     |
|------------------|---------------------|-----------|
| ./mkimage.sh     | boot.img            | boot      |
|                  | system.img          | system    |
|------------------|---------------------|-----------|
```

Note that by excuting `./mkimage.sh`, `boot.img` and `system.img` will be repacked wth the compiled results of Android in `out/target/product/rk3328_firefly_box/` directory, and all related image files will be copied to the directory `rockdev/Image-rk3328_firefly_box/`.

The following is a list of the image files:
 - `boot.img`: Android initramfs image, contains base filesystem of Android root directory, whcih is responsible for initializing and loading the system partition.
 - `system.img`: Android system partition image in ext4 filesystem format.
 - `kernel.img`: kernel image.
 - `resource.img`: Resource image, containing boot log and kernel device tree blob.
 - `misc.img`: misc partition image, responsible for starting the mode switch and first aid mode parameter transfer.
 - `recovery.img`: Recovery mode image.
 - `rk3328_loader_v1.08.244.bin`: Loader files
 - `uboot.img`: U-Boot image file
 - `trust.img`: Sleep wake up related files
 - `parameter.txt`: Partition layout and kernel command line
