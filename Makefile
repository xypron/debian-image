all: prepare mount debootstrap mount2 copy flash unmount compress

prepare:
	sudo rm -f image image.*
	sudo dd if=/dev/zero of=image bs=1024 seek=3906249 count=1
	sudo sfdisk image < partioning
	sudo losetup -o 1048576 --sizelimit 1072693248 /dev/loop1 image
	sudo losetup -o 1073741824 /dev/loop2 image
	sudo mkfs.ext2 -L boot -U 9026d986-86a1-43f9-9322-c3e7baf355d9 /dev/loop1
	sudo mkfs.ext4 -L root -U 83289271-c790-4c10-9582-bd82a4154394 /dev/loop2
	sudo losetup -d /dev/loop2 || true
	sudo losetup -d /dev/loop1 || true

mount:
	sudo losetup -o 1048576 --sizelimit 1072693248 /dev/loop1 image
	sudo losetup -o 1073741824 /dev/loop2 image
	sudo mkdir -p mnt
	sudo mount /dev/loop2 mnt

debootstrap:
	sudo debootstrap --arch arm64 stretch mnt http://ftp.de.debian.org/debian/

mount2:
	sudo mount /dev/loop1 mnt/boot || true
	sudo mount --bind /proc mnt/proc || true
	sudo mount --bind /sys mnt/sys || true

copy:
	sudo cp fstab mnt/etc/
	sudo cp flash-kernel /mnt/etc/default/
	sudo cp xypron.list mnt/etc/apt/sources.list.d/
	sudo cp xypron mnt/etc/apt/preferences.d/
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
	xz -9 -k image
