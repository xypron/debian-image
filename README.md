Build Debian SD card image for the Odroid C2
============================================

This project provides files to generate a Debian SD card image
for the Hardkernel Odroid C2 on an arm64 system.

The following command installs the dependencies:

    sudo apt-get install debootstrap dosfstools fakeroot xz-utils

To create the SD card image execute

    make

A new image is created with two partions:

- boot partition
- root partition

Debootstrap is used to install a base system.
The U-Boot and Linux kernel images are added from
http://debian.xypron.de/.

A sudo user *odroid* with password *odroid* is provided.

The created image file is called *image*.

To copy the image to an SD card use

    sudo if=image of=/dev/sdX bs=16M

Replace /dev/sdX by the actual device.
**Beware of overwriting your harddisk by specifying the wrong device.**
