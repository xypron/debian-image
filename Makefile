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
	sudo losetup -o 1048576 --sizelimit 535822336 /dev/loop1 image
	sudo losetup -o 536870912 /dev/loop2 image
	sudo mkfs.vfat -n boot -i 9026d986 /dev/loop1
	sudo mkfs.ext4 -L root -U 83289271-c790-4c10-9582-bd82a4154394 /dev/loop2
	sudo losetup -d /dev/loop2 || true
	sudo losetup -d /dev/loop1 || true

mount:
	sudo losetup -o 1048576 --sizelimit 535822336 /dev/loop1 image
	sudo losetup -o 536870912 /dev/loop2 image
	sudo mkdir -p mnt
	sudo mount /dev/loop2 mnt

debootstrap:
	sudo debootstrap --arch arm64 stretch mnt http://ftp.de.debian.org/debian/

mount2:
	sudo mount /dev/loop1 mnt/boot || true

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
	cd mnt/usr/lib/u-boot/odroid-c2/ && \
	  ./sd_fusing.sh ../../../../../image

unmount:
	sync
	sudo umount mnt/sys || true
	sudo umount mnt/proc || true
	sudo umount mnt/boot || true
	sudo umount mnt || true
	sudo losetup -d /dev/loop2 || true
	sudo losetup -d /dev/loop1 || true

compress:
	sha512sum image > image.sha512
	fakeroot xz -9 -k image
