all: prepare mount debootstrap

prepare:
	sudo rm -f image
	sudo dd if=/dev/zero of=image bs=1024 seek=3906249 count=1
	sudo sfdisk image < partioning
	sudo losetup -o 1048576 --sizelimit 1072693248 /dev/loop1 image
	sudo losetup -o 1073741824 /dev/loop2 image
	sudo mkfs.ext3 -L boot -U 9026d986-86a1-43f9-9322-c3e7baf355d9 /dev/loop1
	sudo mkfs.ext4 -L root -U 83289271-c790-4c10-9582-bd82a4154394 /dev/loop2

mount:
	sudo mkdir -p mnt
	sudo mount /dev/loop2 mnt

debootstrap:
	sudo debootstrap --arch arm64 stretch mnt http://ftp.de.debian.org/debian/

unmount:
	sudo umount mnt || true
	sudo losetup -d /dev/loop2 || true
	sudo losetup -d /dev/loop1 || true
