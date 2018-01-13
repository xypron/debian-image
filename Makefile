all:
	make prepare
	make mount
	make debootstrap
	make mount2
	make copy
	make flash
	make unmount
	make compress

prepare:
	sudo rm -f image image.*
	sudo dd if=/dev/zero of=image bs=1024 seek=3145727 count=1
	sudo sfdisk image < partioning
	sudo losetup -o 1048576 --sizelimit 133169152 /dev/loop1 image
	sudo losetup -o 134217728 --sizelimit 402653184 /dev/loop2 image
	sudo losetup -o 536870912 /dev/loop3 image
	sudo mkfs.vfat -i 1f97b63b /dev/loop1
	sudo mkfs.ext2 -L boot -U 84185ebb-74ba-4879-93ba-56adcdfbe8c7 /dev/loop2
	sudo mkfs.ext4 -L root -U afa724eb-deb7-4779-ba7d-b6553f4e34d3 /dev/loop3
	sudo losetup -d /dev/loop3 || true
	sudo losetup -d /dev/loop2 || true
	sudo losetup -d /dev/loop1 || true

mount:
	sudo losetup -o 1048576 --sizelimit 133169152 /dev/loop1 image
	sudo losetup -o 134217728 --sizelimit 402653184 /dev/loop2 image
	sudo losetup -o 536870912 /dev/loop3 image
	sudo mkdir -p mnt
	sudo mount /dev/loop3 mnt

debootstrap:
	sudo debootstrap --arch arm64 buster mnt http://ftp.de.debian.org/debian/

mount2:
	sudo mount /dev/loop2 mnt/boot || true
	sudo mkdir -p mnt/boot/efi
	sudo mount /dev/loop1 mnt/boot/efi || true

copy:
	sudo cp eth0 mnt/etc/network/interfaces.d/
	sudo cp fstab mnt/etc/
	sudo cp flash-kernel mnt/etc/default/
	sudo cp xypron.list mnt/etc/apt/sources.list.d/
	sudo mkdir -p mnt/etc/flash-kernel/ubootenv.d/
	sudo cp fdtfile mnt/etc/flash-kernel/ubootenv.d/
	sudo mkdir -p mnt/proc/device-tree/
	sudo cp model mnt/proc/device-tree/
	sudo cp setup.sh mnt
	sudo chroot mnt ./setup.sh
	sudo rm mnt/setup.sh

flash:
	sudo dd if=mnt/usr/lib/u-boot/odroid-c2/bl1.bin.hardkernel \
	  of=image conv=fsync,notrunc bs=1 count=442
	sudo dd if=mnt/usr/lib/u-boot/odroid-c2/bl1.bin.hardkernel \
	  of=image conv=fsync,notrunc bs=512 skip=1 seek=1
	sudo dd if=mnt/usr/lib/u-boot/odroid-c2/u-boot.bin \
	  of=image conv=fsync,notrunc bs=512 seek=97

unmount:
	sync
	sudo umount mnt/sys || true
	sudo umount mnt/proc || true
	sudo umount mnt/boot/efi || true
	sudo umount mnt/boot || true
	sudo umount mnt || true
	sudo losetup -d /dev/loop3 || true
	sudo losetup -d /dev/loop2 || true
	sudo losetup -d /dev/loop1 || true

compress:
	sha512sum image > image.sha512
	fakeroot xz -9 -k image
