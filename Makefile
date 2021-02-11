
MK_ARCH="${shell uname -m}"
ifeq ("arm64", $(MK_ARCH))
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
	sudo rm -f odroid-hc4-image odroid-hc4-image.*
	sudo dd if=/dev/zero of=odroid-hc4-image bs=1024 seek=3145727 count=1
	sudo sfdisk odroid-hc4-image < partioning
	sudo losetup -o 1048576 --sizelimit 133169152 /dev/loop1 odroid-hc4-image
	sudo losetup -o 134217728 --sizelimit 402653184 /dev/loop2 odroid-hc4-image
	sudo losetup -o 536870912 /dev/loop3 odroid-hc4-image
	sudo mkfs.vfat -n EFI -i 1f97b63b /dev/loop1
	sudo mkfs.ext2 -L boot -U 84185ebb-74ba-4879-93ba-56adcdfbe8c7 /dev/loop2
	sudo mkfs.ext4 -L root -U afa724eb-deb7-4779-ba7d-b6553f4e34d3 /dev/loop3
	sudo losetup -d /dev/loop3 || true
	sudo losetup -d /dev/loop2 || true
	sudo losetup -d /dev/loop1 || true

mount:
	sudo losetup -o 1048576 --sizelimit 133169152 /dev/loop1 odroid-hc4-image
	sudo losetup -o 134217728 --sizelimit 402653184 /dev/loop2 odroid-hc4-image
	sudo losetup -o 536870912 /dev/loop3 odroid-hc4-image
	sudo mkdir -p mnt
	sudo mount /dev/loop3 mnt

debootstrap:
	sudo debootstrap $(FOREIGN) --arch arm64 buster mnt \
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
	sudo cp xypron.list mnt/etc/apt/sources.list.d/
	sudo mkdir -p mnt/etc/flash-kernel/ubootenv.d/
	sudo mkdir -p mnt/proc/device-tree/
	sudo cp model mnt/proc/device-tree/
	sudo cp .vimrc mnt/root
	sudo cp meson-sm1-odroid-hc4.dtb mnt/boot/efi

stage2:
	sudo cp setup.sh mnt
	sudo chroot mnt ./setup.sh
	sudo rm -f mnt/setup.sh

stage2_qemu:
	sudo cp setup.sh mnt
	sudo cp /usr/bin/qemu-aarch64-static mnt/usr/bin
	test ! -f mnt/debootstrap/debootstrap || \
	sudo chroot mnt /bin/bash /debootstrap/debootstrap --second-stage
	sudo cp /usr/bin/qemu-aarch64-static mnt/usr/bin
	sudo chroot mnt /usr/bin/qemu-aarch64-static /bin/bash ./setup.sh
	sudo rm mnt/usr/bin/qemu-aarch64-static
	sudo rm mnt/setup.sh

flash:
	sudo dd if=mnt/usr/lib/u-boot/odroid-hc4/bl1.bin.hardkernel \
	  of=odroid-hc4-image conv=fsync,notrunc bs=1 count=442
	sudo dd if=mnt/usr/lib/u-boot/odroid-hc4/bl1.bin.hardkernel \
	  of=odroid-hc4-image conv=fsync,notrunc bs=512 skip=1 seek=1
	sudo dd if=mnt/usr/lib/u-boot/odroid-hc4/u-boot.bin \
	  of=odroid-hc4-image conv=fsync,notrunc bs=512 seek=97

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
	fakeroot xz -9 -k odroid-hc4-image
	sha512sum odroid-hc4-image.xz odroid-hc4-image > odroid-hc4-image.sha512
	gpg -ab odroid-hc4-image.sha512

clean: unmount
	sudo rm -f odroid-hc4-image odroid-hc4-image.*
