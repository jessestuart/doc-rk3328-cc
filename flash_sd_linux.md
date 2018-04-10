# Flashing to SD Card in Linux

## Flashing Raw Firmware

There is currently no Linux release version of [SDCard Installer] yet.

You can use your favorite flashing tool like [Etcher], or use `dd` directly.

First, plug in the SD card, and unmount it if it is automatically mounted by the file manager.

Then find the device file of the SD card by checking kernel log:
> dmesg | tail

If the device file is `/dev/mmcblk0`, use the `dd` command to flash:
> sudo dd if=/path/to/your/raw/firmware of=/dev/mmcblk0 conv=notrunc

`dd` does not report the progress, we can use another tool `pv` to do this job.

First install `pv`:
> sudo apt-get install pv

Then add `pv` to the pipe to report progress:
> pv -tpreb /path/to/your/raw/firmware | sudo dd of=/dev/mmcblk0 conv=notrunc

## Flashing Rockchip Firmware

There are no tools available to flash the Rockchip format firmware to SD card in Linux.

You may extract the Rockchip format firmware, repack all the partition images into a raw format firmware, then use the method in the last section to proceed.

[SDCard Installer]: http://www.t-firefly.com/share/index/index/id/acd8e1e37176fba5bf61fb7bf4503998.html
