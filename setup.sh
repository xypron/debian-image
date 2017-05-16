#!/bin/sh
echo root:odroid | chpasswd
apt-get update
apt-get install xypron-keyring --allow-unauthenticated -y
apt-get update
apt-get install flash-kernel -y
apt-get install odroid-c2-u-boot-image -y
apt-get install odroid-c2-kernel-image --reinstall -y
