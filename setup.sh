#!/bin/sh
apt-get update --allow-insecure-repositories
apt-get install xypron-keyring --allow-unauthenticated -y
apt-get update
apt-get install apt-file bash-completion ca-certificates dnsutils \
  grub-efi-arm64 less locales ntp man open-iscsi ssh sudo vim -y
apt-get install flash-kernel -y
apt-get install odroid-c2-u-boot-image -y
apt-get install linux-image-arm64 --reinstall -y
adduser odroid --uid 9997 --disabled-password --gecos 'Default User,,,'
echo odroid:odroid | chpasswd
adduser odroid sudo
