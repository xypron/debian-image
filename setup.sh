#!/bin/sh
apt-get update
apt-get install xypron-keyring --allow-unauthenticated -y
apt-get update
apt-get install less locales ssh sudo vim ca-certificates open-iscsi dnsutils \
  apt-file ntp bash-completion -y
apt-get install flash-kernel -y
apt-get install odroid-c2-u-boot-image -y
apt-get install linux-image-arm64 --reinstall -y
adduser odroid --uid 9997 --disabled-password --gecos 'Default User,,,'
echo odroid:odroid | chpasswd
adduser odroid sudo
