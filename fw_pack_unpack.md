# Unpack/Packing Rockchip Firmware

## Rockchip Firmware Format

The rockchip firmware `release_update.img`, contains the boot loader `loader.img` and the real firmware data `update.img`:

release_update.img
```bash
|- loader.img
`- update.img
```

`update.img` is packed with multiple image files, described by a control file named `package-file`. A typical `package-file` is:
```bash
# NAME Relative path
package-file    package-file
bootloader      Image/MiniLoaderAll.bin
parameter       Image/parameter.txt
trust           Image/trust.img
uboot           Image/uboot.img
misc            Image/misc.img
resource        Image/resource.img
kernel          Image/kernel.img
boot            Image/boot.img
recovery        Image/recovery.img
system          Image/system.img
backup          RESERVED
#update-script  update-script
#recover-script recover-script
```

 - `package-file`: packing description of `update.img`, which is also included by `update.img`.
 - `Image/MiniLoaderAll.bin`: The first bootloader loaded by cpu rom code.
 - `Image/parameter.txt`: Parameter file where you can set the kernel boot parameters and partition layout.
 - `Image/trust.img`: The Arm Trusted Image.
 - `Image/misc.img`: misc partition image, used to control boot mode of Android.
 - `Image/kernel.img`: Android kernel image.
 - `Image/resource.img`: Resource image with boot log and kernel device tree blob.
 - `Image/boot.img`: Android initramfs, a root filesystem loaded in normal boot, contains important initialization and services description.
 - `Image/recovery.img`: Recovery mode image.
 - `Image/system.img`: Android system partition image.
    

Unpacking is extracting `update.img` from `release_update.img`,  and then unpacking all the image files inside.

While repacking, it is the inverse process. It synthesizes the image files described by the `package-file`, into `update.img`, which will be further packed together with the bootloader to create the final `release_update.img`.

## Installation of Tools

```bash
git clone https://github.com/TeeFirefly/rk2918_tools.git
cd rk2918_tools
make
sudo cp afptool img_unpack img_maker mkkrnlimg /usr/local/bin
```

## Unpacking Rockchip Firmware

 - Unpacking `release_update.img`:
  ```
  $ cd /path/to/your/firmware/dir
  $ img_unpack Firefly-RK3399_20161027.img img
  rom version: 6.0.1
  build time: 2016-10-27 14:58:18
  chip: 33333043
  checking md5sum....OK
  ```
 - Unpacking `update.img`:
  ```bash
  $ cd img
  $ afptool -unpack update.img update
  Check file...OK
  ------- UNPACK -------
  package-file	0x00000800	0x00000280
  Image/MiniLoaderAll.bin	0x00001000	0x0003E94E
  Image/parameter.txt	0x00040000	0x00000350
  Image/trust.img	0x00040800	0x00400000
  Image/uboot.img	0x00440800	0x00400000
  Image/misc.img	0x00840800	0x0000C000
  Image/resource.img	0x0084C800	0x0003FE00
  Image/kernel.img	0x0088C800	0x00F5D00C
  Image/boot.img	0x017EA000	0x0014AD24
  Image/recovery.img	0x01935000	0x013C0000
  Image/system.img	0x02CF5000	0x2622A000
  RESERVED	0x00000000	0x00000000
  UnPack OK!
  ```
 - Check the file tree in the update directory:
  ```bash
  $ cd update/
  $ tree
  .
  ├── Image
  │   ├── boot.img
  │   ├── kernel.img
  │   ├── MiniLoaderAll.bin
  │   ├── misc.img
  │   ├── parameter.txt
  │   ├── recovery.img
  │   ├── resource.img
  │   ├── system.img
  │   ├── trust.img
  │   └── uboot.img
  ├── package-file
  └── RESERVED

  1 directory, 12 files
  ```

## Packing Rockchip Firmware

First of all, make sure `system` partition in `parameter.txt` file is larger enough to hold `system.img`. You can reference [Parameter file format](http://www.t-firefly.com/download/Firefly-RK3399/docs/Rockchip%20Parameter%20File%20Format%20Ver1.3.pdf) to understand the partition layout.

For example, in the line prefixed with "CMDLINE" in `parameter.txt`, you will find the description of `system` partition similiar to the following content:
```bash
0x00200000@0x000B0000(system)
```

The heximal string before the "@" is the partiton size in sectors (1 sector = 512 bytes here), therefore the size of the system partition is:
```bash
$ echo $(( 0x00200000 * 512 / 1024 / 1024 ))M
1024M
```

To create `release_update_new.img`:
```bash
# The current directory is still update/, which contains package-file, 
# and files that package-file lists still exist
# Copy the parameter file to paramter, because afptool is used by default

$ afptool -pack . ../update_new.img
------ PACKAGE ------
Add file: ./package-file
Add file: ./Image/MiniLoaderAll.bin
Add file: ./Image/parameter.txt
Add file: ./Image/trust.img
Add file: ./Image/uboot.img
Add file: ./Image/misc.img
Add file: ./Image/resource.img
Add file: ./Image/kernel.img
Add file: ./Image/boot.img
Add file: ./Image/recovery.img
Add file: ./Image/system.img
Add file: ./RESERVED
Add CRC...
------ OK ------
Pack OK!

$ img_maker -rk33 loader.img update_new.img release_update_new.img
generate image...
append md5sum...
success!
```
## Customization

### Customizing system.img

system.img is an ext4 file system format image file which can be mounted directly to the system for modification:

```bash
sudo mkdir -p /mnt/system
sudo mount Image/system.img /mnt/system
cd /mnt/system
# Modify the contents of the inside.
# Pay attention to the free space, 
# You can not add too many APKs

# When finished, you need to unmount it
cd /
sudo umount /mnt/system
```

Note that the free space of `system.img` is almost 0. If you need to expand the image file, do adjust the partition layout in `parameter.txt` accordingly.

The following is an example of how to increase the size of the image file by 128MB.

Before expanding, make sure `system.img` is not mounted by running:
```
mount | grep system
```

Resize the image file:
```bash
dd if=/dev/zero bs=1M count=128 >> Image/system.img
# Expand file system information
e2fsck -f Image/system.img
resize2fs Image/system.img
```
