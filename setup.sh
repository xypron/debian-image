#!/bin/sh
apt-get update
apt-get install xypron-keyring --allow-unauthenticated -y
apt-get update
apt-get install less locales sudo vim -y
apt-get install flash-kernel -o Dpkg::Options::="--force-confold" -y
apt-get install odroid-c2-u-boot-image -y
apt-get install odroid-c2-kernel-image --reinstall -y
adduser odroid --uid 9997 --disabled-password --gecos 'Default User,,,'
echo odroid:odroid | chpasswd
adduser odroid sudo
