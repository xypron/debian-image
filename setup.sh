#!/bin/sh
export DEBIAN_FRONTEND=noninteractive
apt-get update --allow-insecure-repositories
apt-get update
apt-get install -y apt-file bash-completion ca-certificates dnsutils \
  grub-efi-riscv64 less locales ntp man open-iscsi ssh sudo vim
apt-get install -y linux-image-riscv64 --reinstall
dpkg-reconfigure --frontend=noninteractive locales
update-locale LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8"
adduser qemu --uid 9997 --disabled-password --gecos 'Default User,,,'
echo qemu:qemu | chpasswd
adduser qemu sudo
cp /root/.vimrc /home/qemu
chown qemu:qemu /home/qemu/.vimrc
