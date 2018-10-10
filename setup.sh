#!/bin/sh
DEBIAN_FRONTEND=noninteractive
apt-get update --allow-insecure-repositories
apt-get install -yq xypron-keyring --allow-unauthenticated
apt-get update
apt-get install -yq apt-file bash-completion ca-certificates dnsutils \
  flash-kernel grub-efi-arm64 less locales ntp man open-iscsi ssh sudo vim
apt-get install -yq odroid-c2-u-boot-image
apt-get install -yq linux-image-arm64 --reinstall
adduser odroid --uid 9997 --disabled-password --gecos 'Default User,,,'
echo odroid:odroid | chpasswd
adduser odroid sudo
