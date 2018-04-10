# Getting Started

[ROC-RK3328-CC] supports booting from the following storage devices:
 - SD card
 - eMMC

If you're using SD card to boot the board, and your host OS is Windows, visit straightly to 
[Flashing Firmware to SD Card in Windows](flash_sd_windows.html). Using the official flashing tool [SDCard Installer] has made everything simple and easy with a few clicks.

If you would like to know more detail or prefer to offline firmware flashing, then go ahead.

## Firmware Format

There are two firmware file formats used:
 - raw firmware
 - Rockchip firmware
 
The `raw firmware`, is the on-disk format, which means that it should be copied to storage devices bit by bit. In Linux, you can use the `dd` command directly to flash this type of firmware. While in Windows, you can use graphics tool like [Etcher], or [SDCard Installer] which is derived from the Rock64 installer and [Etcher].

The `Rockchip firmware`, is the firmware file packed in Rockchip's proprietary format, which shall be flashed to eMMC using Rockchip's `update_tool` in Linux or `android_tool` in Windows. It can also be flashed into SD card using Rockchip's [SD_Firmware_Tool].

`Rockchip firmware` can be converted to `raw firmware`, and vice versa. That sounds confused at first. But `Rockchip firmware` is the traditional firmware format for all Rockchip devices, especially in case of Android OS. And `raw firmware` is more suitable and natural for SD card flashing.

When you build the Android SDK, you'll get a list of `boot.img`, `kernel.img`, `system.img`, etc, which is called `partition image file` and will be flashed into the corresponding partition. For example, `kernel.img` is to be flashed to `kernel` partition of eMMC or SD card.

## Download & Flash

**Rockchip firmware** download list:
 - Android 7.1.2 [💾](http://www.t-firefly.com/share/index/listpath/id/08cb58f6a5f8e4977275bd45a446764f.html)
 - Ubuntu 16.04 [💾](http://www.t-firefly.com/share/index/listpath/id/b99bb982578de0acf7261f96be2b8ba2.html)

Rockchip firmware is meant to be flashed to eMMC, following instructions depending on your OS: [Windows](flash_emmc_windows.html), [Linux](flash_emmc_linux.html).

Android firmware with Rockchip format can also be flashed to SD card in Windows. Please check [here](flash_sd_windows.html#flashing-rockchip-firmware).

**Raw firmware** download list:
 - Android 7.1.2 [💾](http://t-firefly.oss-cn-hangzhou.aliyuncs.com/product/RK3328/Firmware/Android/ROC-RK3328-CC_Android7.1.2_180411/ROC-RK3328-CC_Android7.1.2_180411.img.gz)
 - Ubuntu 16.04 [💾](http://download.t-firefly.com/product/RK3328/Firmware/Linux/ROC-RK3328-CC_Ubuntu16.04_Arch64_20180315/ROC-RK3328-CC_Ubuntu16.04_Arch64_20180315.zip)
 - Station OS [💾](http://download.t-firefly.com/product/Station%20OS/Station_OS_for_ROC-RK3328-CC_SDCard_Installer_v1.2.3.zip)
 - LibreELEC [💾](http://download.t-firefly.com/product/RK3328/Firmware/Linux/LibreELEC/ROC-RK3328-CC_LibreELEC9.0_180324/ROC-RK3328-CC_LibreELEC9.0_180324.zip)

Raw firmware is meant to be flashed to SD card, following instructions depending on your OS: [Windows](flash_sd_windows.html), [Linux](flash_sd_linux.html).

If you want to build your own firmware, please check the Developer's Guide.

## System Boot Up

Before system boots up, make sure you have:
 - A bootable SD card or eMMC
 - 5V2A power adapter
 - Micro USB cable

Then follow the procedures below:

 1. Pull power adapter out of power socket.
 2. Use the micro USB cable to connect power adapter and main board.
 3. Plug in bootable SD card or eMMC (NOT BOTH).
 4. Plug in optional HDMI cable, USB mouse or keyboard.
 5. Check everything is okay, then plug the power adapter into the power socket to power on the board.

[ROC-RK3328-CC]: http://en.t-firefly.com/product/rocrk3328cc.html "ROC-RK3328-CC Official Website"
[SDCard Installer]: http://www.t-firefly.com/share/index/index/id/acd8e1e37176fba5bf61fb7bf4503998.html
[Etcher]: https://etcher.io
[SD_Firmware_Tool]: https://pan.baidu.com/s/1migPY1U#list/path=%2FPublic%2FDevBoard%2FROC-RK3328-CC%2FTools%2FSD_Firmware_Tool&parentPath=%2FPublic%2FDevBoard%2FROC-RK3328-CC
[AndroidTool]: https://pan.baidu.com/s/1migPY1U#list/path=%2FPublic%2FDevBoard%2FROC-RK3328-CC%2FTools%2FAndroidTool&parentPath=%2FPublic%2FDevBoard%2FROC-RK3328-CC
