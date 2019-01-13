
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
	make flash
	make unmount
	make compress

prepare: unmount
	sudo rm -f banana-pi-image banana-pi-image.*
	sudo dd if=/dev/zero of=banana-pi-image bs=1024 seek=3145727 count=1
	sudo sfdisk banana-pi-image < partioning
	sudo losetup -o 1048576 --sizelimit 133169152 /dev/loop1 banana-pi-image
	sudo losetup -o 134217728 --sizelimit 402653184 /dev/loop2 banana-pi-image
	sudo losetup -o 536870912 /dev/loop3 banana-pi-image
	sudo mkfs.vfat -n EFI -i 1f97b63b /dev/loop1
	sudo mkfs.ext2 -L boot -U 84185ebb-74ba-4879-93ba-56adcdfbe8c7 /dev/loop2
	sudo mkfs.ext4 -L root -U afa724eb-deb7-4779-ba7d-b6553f4e34d3 /dev/loop3
	sudo losetup -d /dev/loop3 || true
	sudo losetup -d /dev/loop2 || true
	sudo losetup -d /dev/loop1 || true

mount:
	sudo losetup -o 1048576 --sizelimit 133169152 /dev/loop1 banana-pi-image
	sudo losetup -o 134217728 --sizelimit 402653184 /dev/loop2 banana-pi-image
	sudo losetup -o 536870912 /dev/loop3 banana-pi-image
	sudo mkdir -p mnt
	sudo mount /dev/loop3 mnt

debootstrap:
	sudo debootstrap $(FOREIGN) --arch armhf buster mnt \
	  http://ftp.de.debian.org/debian/

mount2:
	sudo mount /dev/loop2 mnt/boot || true
	sudo mkdir -p mnt/boot/efi
	sudo mount /dev/loop1 mnt/boot/efi || true

copy:
	sudo mkdir -p mnt/etc/network/interfaces.d/
	sudo cp eth0 mnt/etc/network/interfaces.d/
	sudo cp locale.gen mnt/etc/
	sudo cp fstab mnt/etc/
	sudo cp flash-kernel mnt/etc/default/
	sudo cp hostname mnt/etc/hostname
	sudo cp hosts mnt/etc/hosts
	sudo mkdir -p mnt/etc/flash-kernel/ubootenv.d/
	sudo mkdir -p mnt/proc/device-tree/
	sudo cp model mnt/proc/device-tree/
	sudo cp .vimrc mnt/root

stage2:
	sudo cp setup.sh mnt
	sudo chroot mnt ./setup.sh
	sudo rm -f mnt/setup.sh

stage2_qemu:
	sudo cp setup.sh mnt
	sudo cp /usr/bin/qemu-arm-static mnt/usr/bin
	test ! -f mnt/debootstrap/debootstrap || \
	sudo chroot mnt /bin/bash /debootstrap/debootstrap --second-stage
	sudo cp /usr/bin/qemu-arm-static mnt/usr/bin
	sudo chroot mnt /usr/bin/qemu-arm-static /bin/bash ./setup.sh
	sudo rm mnt/usr/bin/qemu-arm-static
	sudo rm mnt/setup.sh

flash:
	sudo dd if=mnt/usr/lib/u-boot/Bananapi/u-boot-sunxi-with-spl.bin \
	of=banana-pi-image conv=fsync,notrunc bs=1024 seek=8

unmount:
	sync
	sudo umount mnt/dev/pts || true
	sudo umount mnt/dev || true
	sudo umount mnt/sys || true
	sudo umount mnt/proc || true
	sudo umount mnt/boot/efi || true
	sudo umount mnt/boot || true
	sudo umount mnt || true
	sudo losetup -d /dev/loop3 || true
	sudo losetup -d /dev/loop2 || true
	sudo losetup -d /dev/loop1 || true

compress:
	fakeroot xz -9 -k banana-pi-image
	sha512sum banana-pi-image.xz banana-pi-image > banana-pi-image.sha512
	gpg -ab banana-pi-image.sha512

clean: unmount
	sudo rm -f banana-pi-image banana-pi-image.*
