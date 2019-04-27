#!/bin/sh
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y apt-file bash-completion ca-certificates dnsutils \
  less locales ntp man open-iscsi ssh sudo vim
apt-get install -y -o Dpkg::Options::="--force-confold" raspi3-firmware
apt-get install -y linux-image-rpi --reinstall
dpkg-reconfigure --frontend=noninteractive locales
update-locale LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8"
adduser rpi0 --uid 9997 --disabled-password --gecos 'Default User,,,'
echo rpi0:rpi0 | chpasswd
adduser rpi0 sudo
cp /root/.vimrc /home/rpi0
chown rpi0:rpi0 /home/rpi0/.vimrc
