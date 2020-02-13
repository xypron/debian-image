Build Debian SD card image for the Raspberry Pi 4 Model B Plus
==============================================================

This project provides files to generate a Debian SD card image
for the Hardkernel Raspberry Pi 4 Model B Plus.

The following command installs the dependencies:

    sudo apt-get install debootstrap dosfstools fakeroot xz-utils

When building on an architecture other than arm64 QEMU is needed:

    sudo apt-get install qemu-user-static

To create the SD card image execute

    make

A new image is created with three partions:

- efi partition
- boot partition
- root partition

Debootstrap is used to install a base system.

A sudo user *rpi4* with password *rpi4* is provided.

The created image file is called *rpi4-image*.

To copy the image to an SD card use

    sudo dd iflag=dsync oflag=dsync if=rpi4-image of=/dev/sdX bs=16M

Replace /dev/sdX by the actual device.
**Beware of overwriting your harddisk by specifying the wrong device.**

After first boot
----------------

Change the password of user rpi4.

    passwd

You can enlarge the root partition: Use fdisk to delete partition 3 and recreate
it with the same start sector. **Do not delete the signature.**
Use resize2fs to resize the file system to match the partition size.
