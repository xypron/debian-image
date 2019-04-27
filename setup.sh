#!/bin/sh
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y apt-file bash-completion ca-certificates dnsutils \
  grub-efi-arm64 less locales ntp man open-iscsi ssh sudo vim
apt-get install -y -o Dpkg::Options::="--force-confold" flash-kernel
apt-get install -y u-boot-rpi raspi3-firmware
apt-get install -y linux-image-arm64 --reinstall
dpkg-reconfigure --frontend=noninteractive locales
update-locale LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8"
adduser rpi3 --uid 9997 --disabled-password --gecos 'Default User,,,'
echo rpi3:rpi3 | chpasswd
adduser rpi3 sudo
cp /root/.vimrc /home/rpi3
chown rpi3:rpi3 /home/rpi3/.vimrc
cp /usr/lib/raspi3-firmware/* /boot/
cp /usr/lib/u-boot/rpi_3/u-boot.bin /boot/
