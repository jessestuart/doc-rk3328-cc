# Flashing to eMMC in Linux

## Flashing Raw Firmware

Raw firmware needs to be flashed to offset 0 of eMMC storage. However, in [Rockusb Mode], you cannot do this because all LBA writes are offset by 0x2000 sectors. Therefore, the device has to be forced into [Maskrom Mode].

The steps of flashing raw firmware are:
1. Force the device into [Maskrom Mode].
2. Use `rkdeveloptool` to flash the raw firmware.
    ```
    rkdeveloptool db     out/u-boot/rk3328_loader_ddr786_v1.06.243.bin
    rkdeveloptool wl 0x0 out/system.img
    rkdeveloptool rd     # reset device to boot
    ```

For more information about installation and usage of `rkdeveloptool`， check [here](#rkdeveloptool).

## Flashing Rockchip Firmware

Rockchip firmware can be flashed to eMMC storage using `upgrade_tool`, either in [Rockusb Mode] or [Maskrom Mode].

The steps of flashing Rockchip firmware are:
1. Force the device into [Rockusb Mode] or [Maskrom Mode].
2. Use `upgrade_tool` to flash Rockchip firmware.
    ```
    upgrade_tool uf /path/to/rockchip/firmware
    ```

For more information about installation and usage of `upgrade_tool`， check [here](#upgrade-tool).

## Flashing Partition Image

You can write individual partition image to eMMC storage. Depending on the original firmware format, the instructions can be somewhat different.

**Raw Firmware**

If the original firmware format is raw, chances are that it is using the `GPT` partition scheme, and the predefined offset and size of each partition can be found in `build/partitions.sh`.

1. Force the device into [Maskrom Mode].
2. Use `rkdeveloptool` to flash partition image:
    ```
    rkdeveloptool db         out/u-boot/rk3328_loader_ddr786_v1.06.243.bin
    rkdeveloptool wl 0x40    out/u-boot/idbloader.img
    rkdeveloptool wl 0x4000  out/u-boot/uboot.img
    rkdeveloptool wl 0x6000  out/u-boot/trust.img
    rkdeveloptool wl 0x8000  out/boot.img
    rkdeveloptool wl 0x40000 out/linaro-rootfs.img
    rkdeveloptool rd         # reset device to boot
    ```

Partition offset can be found [here](#linux-partition-offset).

For more information about installation and usage of `rkdeveloptool`， check [here](#rkdeveloptool).

**Rockchip Firmware**

If the original firmware format is Rockchip, it is using the `parameter` file for partition scheme, and you can use the partition name to flash partition image.


1. Force the device into [Rockusb Mode] or [Maskrom Mode].
2. Use `upgrade_tool` to flash partition image:
    ```
    upgrade_tool di -b /path/to/boot.img
    upgrade_tool di -k /path/to/kernel.img
    upgrade_tool di -s /path/to/system.img
    upgrade_tool di -r /path/to/recovery.img
    upgrade_tool di -m /path/to/misc.img
    upgrade_tool di resource /path/to/resource.img
    upgrade_tool di -p parameter   # flash parameter
    upgrade_tool ul bootloader.bin # flash bootloader
    ```

Note:
- `-b` is a predefined shortcut for `boot` partition. If no shortcuts are available, use partition name as `resource` instead.
- You can customize kernel parameters and partition layout according to [Parameter file format](http://www.t-firefly.com/download/Firefly-RK3399/docs/Rockchip%20Parameter%20File%20Format%20Ver1.3.pdf). Once the partition layout is changed, you must reflash the corresponding partitions.

For more information about installation and usage of `upgrade_tool`， check [here](#upgrade-tool).

## Flashing Tools

### rkdeveloptool

`rkdeveloptool` is an open-source command line flashing tool developed by Rockchip, which is an alternative to the close-source `upgrade_tool`(#upgrade-tool).

`rkdeveloptool` do not support firmware in proprietary Rockchip format. 

Install `rkdeveloptool`:

    #install libusb and libudev
    sudo apt-get install pkg-config libusb-1.0 libudev-dev libusb-1.0-0-dev dh-autoreconf
    # clone source and make
    git clone https://github.com/rockchip-linux/rkdeveloptool
    cd rkdeveloptool
    autoreconf -i
    ./configure
    make
    sudo make install

**NOTE**: Add `udev` rules by instructions [here](#udev), in order to have permission for the normal user to flash Rockchip devices. If you do not do this, you shall prefix the following commands with `sudo`.

To flash partition images:

    rkdeveloptool db           out/u-boot/rk3328_loader_ddr786_v1.06.243.bin
    rkdeveloptool wl 0x40      out/u-boot/idbloader.img
    rkdeveloptool wl 0x4000    out/u-boot/uboot.img
    rkdeveloptool wl 0x6000    out/u-boot/trust.img
    rkdeveloptool wl 0x8000    out/boot.img
    rkdeveloptool wl 0x40000   out/linaro-rootfs.img
    rkdeveloptool rd           # reset device to boot

To flash raw image:

    rkdeveloptool db           out/u-boot/rk3328_loader_ddr786_v1.06.243.bin
    rkdeveloptool wl 0x0       out/system.img
    rkdeveloptool rd           # reset device to boot

Partition offset can be found [here](#partition%20offset).

### upgrade_tool

`upgrade_tool** is a close-sourced command line tool provided by Rockchip, which supports flashing partition image and firmware in the proprietary Rockchip format.

Download  [Linux_Upgrade_Tool](https://gitlab.com/TeeFirefly/RK3328-Nougat/blob/roc-rk3328-cc/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.24.zip**, and install it to your host:

    unzip Linux_Upgrade_Tool_v1.24.zip
    cd Linux_UpgradeTool_v1.24
    sudo mv upgrade_tool /usr/local/bin
    sudo chown root:root /usr/local/bin/upgrade_tool

**NOTE**: Add `udev` rules by instructions [here](#udev), in order to have permission for the normal user to flash Rockchip devices. If you do not do this, you shall prefix the following commands with `sudo`.

Flash Rockchip firmware:

    upgrade_tool uf update.img

Flash partition images:

    upgrade_tool di -b /path/to/boot.img
    upgrade_tool di -k /path/to/kernel.img
    upgrade_tool di -s /path/to/system.img
    upgrade_tool di -r /path/to/recovery.img
    upgrade_tool di -m /path/to/misc.img
    upgrade_tool di resource /path/to/resource.img
    upgrade_tool di -p parameter   # flash parameter
    upgrade_tool ul bootloader.bin # flash bootloader

If errors occur due to flash storage problem, you can try to low format or erase the flash by:

    upgrade_tool lf   # low format flash
    upgrade_tool ef   # erase flash

### udev
Create `/etc/udev/rules.d/99-rk-rockusb.rules` with following content[1](https://github.com/rockchip-linux/rkdeveloptool/blob/master/99-rk-rockusb.rules). Replace the group `users` with your actual Linux group if neccessary:
```
SUBSYSTEM!="usb", GOTO="end_rules"

# RK3036
ATTRS{idVendor}=="2207", ATTRS{idProduct}=="301a", MODE="0666", GROUP="users"
# RK3229
ATTRS{idVendor}=="2207", ATTRS{idProduct}=="320b", MODE="0666", GROUP="users"
# RK3288
ATTRS{idVendor}=="2207", ATTRS{idProduct}=="320a", MODE="0666", GROUP="users"
# RK3328
ATTRS{idVendor}=="2207", ATTRS{idProduct}=="320c", MODE="0666", GROUP="users"
# RK3368
ATTRS{idVendor}=="2207", ATTRS{idProduct}=="330a", MODE="0666", GROUP="users"
# RK3399
ATTRS{idVendor}=="2207", ATTRS{idProduct}=="330c", MODE="0666", GROUP="users"

LABEL="end_rules"
```

Reload the udev rules to take effect without reboot:

    sudo udevadm control --reload-rules
    sudo udevadm trigger


## FAQ

### Linux Partition Offset

The offset of partition image can be obained by following command(assuming you are in the directory of Firefly Linux SDK):

    (. build/partitions.sh ; set | grep _START | \
    while read line; do start=${line%=*}; \
    printf "%-10s 0x%08x\n" ${start%_START*} ${!start}; done )

which gives result of:

    ATF        0x00006000
    BOOT       0x00008000
    LOADER1    0x00000040
    LOADER2    0x00004000
    RESERVED1  0x00001f80
    RESERVED2  0x00002000
    ROOTFS     0x00040000
    SYSTEM     0x00000000

[rkdeveloptool]: https://github.com/rockchip-linux/rkdeveloptool
[Rockusb Mode]: bootmode.html#rockusb-mode
[Maskrom Mode]: bootmode.html#maskrom-mode
