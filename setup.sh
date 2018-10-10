#!/bin/sh
export DEBIAN_FRONTEND=noninteractive
apt-get update --allow-insecure-repositories
apt-get install -y xypron-keyring --allow-unauthenticated
apt-get update
apt-get install -y apt-file bash-completion ca-certificates dnsutils \
  grub-efi-arm64 less locales ntp man open-iscsi ssh sudo vim
apt-get install -y -o Dpkg::Options::="--force-confold" flash-kernel
apt-get install -y odroid-c2-u-boot-image
apt-get install -y linux-image-arm64 --reinstall
adduser odroid --uid 9997 --disabled-password --gecos 'Default User,,,'
echo odroid:odroid | chpasswd
adduser odroid sudo
cp /root/.vimrc /home/odroid
chown odroid:odroid /home/odroid/.vimrc
