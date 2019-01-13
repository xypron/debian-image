#!/bin/sh
export DEBIAN_FRONTEND=noninteractive
apt-get install -y apt-file bash-completion ca-certificates dnsutils \
  grub-efi-arm less locales ntp man open-iscsi ssh sudo vim
apt-get install -y -o Dpkg::Options::="--force-confold" flash-kernel
apt-get install -y u-boot-sunxi
apt-get install -y linux-image-armmp-lpae --reinstall
dpkg-reconfigure --frontend=noninteractive locales
update-locale LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8"
adduser banana --uid 9997 --disabled-password --gecos 'Default User,,,'
echo banana:banana | chpasswd
adduser banana sudo
cp /root/.vimrc /home/banana
chown banana:banana /home/banana/.vimrc
