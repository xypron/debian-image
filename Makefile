
MK_ARCH="${shell uname -m}"
ifeq ("armv7l", $(MK_ARCH))
	undefine FOREIGN
	export STAGE2=stage2
else
	export FOREIGN="--foreign"
	export STAGE2=stage2_qemu
endif
undefine MK_ARCH

all:
	make prepare
	make mount
	make debootstrap
	make mount2
	make copy
	make $(STAGE2)
	make unmount
	make compress

prepare: unmount
	sudo rm -f rpi3-32bit-image rpi3-32bit-image.*
	sudo dd if=/dev/zero of=rpi3-32bit-image bs=1024 seek=3670015 count=1
	sudo sfdisk rpi3-32bit-image < partioning
	sudo losetup -o 1048576 --sizelimit 535822336 /dev/loop1 rpi3-32bit-image
	sudo losetup -o 536870912 --sizelimit 67108864 /dev/loop2 rpi3-32bit-image
	sudo losetup -o 603979776 --sizelimit 469762048 /dev/loop3 rpi3-32bit-image
	sudo losetup -o 1073741824 /dev/loop4 rpi3-32bit-image
	sudo mkfs.vfat -n FIRMWARE -i 1f78a30b /dev/loop1
	sudo mkfs.vfat -n EFI -i 1f97b63b /dev/loop2
	sudo mkfs.ext2 -L boot -U 84185ebb-74ba-4879-93ba-56adcdfbe8c7 /dev/loop3
	sudo mkfs.ext4 -L root -U afa724eb-deb7-4779-ba7d-b6553f4e34d3 /dev/loop4
	sudo losetup -d /dev/loop4 || true
	sudo losetup -d /dev/loop3 || true
	sudo losetup -d /dev/loop2 || true
	sudo losetup -d /dev/loop1 || true

mount:
	sudo losetup -o 1048576 --sizelimit 535822336 /dev/loop1 rpi3-32bit-image
	sudo losetup -o 536870912 --sizelimit 67108864 /dev/loop2 rpi3-32bit-image
	sudo losetup -o 603979776 --sizelimit 469762048 /dev/loop3 rpi3-32bit-image
	sudo losetup -o 1073741824 /dev/loop4 rpi3-32bit-image
	sudo mkdir -p mnt
	sudo mount /dev/loop4 mnt

debootstrap:
	sudo debootstrap $(FOREIGN) --arch armhf buster mnt \
	  http://ftp.de.debian.org/debian/

mount2:
	sudo mount /dev/loop3 mnt/boot || true
	sudo mkdir -p mnt/boot/efi
	sudo mount /dev/loop2 mnt/boot/efi || true
	sudo mkdir -p mnt/boot/firmware
	sudo mount /dev/loop1 mnt/boot/firmware || true

copy:
	sudo mkdir -p mnt/etc/network/interfaces.d/
	sudo cp eth0 mnt/etc/network/interfaces.d/
	sudo cp locale.gen mnt/etc/
	sudo cp fstab mnt/etc/
	sudo cp sources.list mnt/etc/apt/
	sudo cp hostname mnt/etc/hostname
	sudo cp hosts mnt/etc/hosts
	sudo mkdir -p mnt/proc/device-tree/
	sudo cp model mnt/proc/device-tree/
	sudo cp .vimrc mnt/root/
	sudo cp config.txt mnt/boot/
	sudo cp raspi3-firmware mnt/etc/default

stage2:
	sudo cp setup.sh mnt
	sudo chroot mnt ./setup.sh
	sudo rm -f mnt/setup.sh

stage2_qemu:
	sudo cp setup.sh mnt
	sudo cp /usr/bin/qemu-arm-static mnt/usr/bin
	test -f mnt/debootstrap/debootstrap && \
	sudo chroot mnt /bin/bash /debootstrap/debootstrap --second-stage
	sudo cp /usr/bin/qemu-arm-static mnt/usr/bin
	sudo chroot mnt /usr/bin/qemu-arm-static /bin/bash ./setup.sh
	sudo rm mnt/usr/bin/qemu-arm-static
	sudo rm mnt/setup.sh

unmount:
	sync
	sudo umount mnt/dev/pts || true
	sudo umount mnt/dev || true
	sudo umount mnt/sys || true
	sudo umount mnt/proc || true
	sudo umount mnt/boot/efi || true
	sudo umount mnt/boot/firmware || true
	sudo umount mnt/boot || true
	sudo umount mnt || true
	sudo losetup -d /dev/loop4 || true
	sudo losetup -d /dev/loop3 || true
	sudo losetup -d /dev/loop2 || true
	sudo losetup -d /dev/loop1 || true

compress:
	fakeroot xz -9 -k rpi3-32bit-image
	sha512sum rpi3-32bit-image.xz rpi3-32bit-image > rpi3-32bit-image.sha512
	gpg -ab rpi3-32bit-image.sha512

clean: unmount
	sudo rm -f rpi3-32bit-image rpi3-32bit-image.*
