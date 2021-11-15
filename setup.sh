#!/bin/sh
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install locales
dpkg-reconfigure --frontend=noninteractive locales
update-locale LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8"
adduser ubuntu --uid 9997 --disabled-password --gecos 'Default User,,,'
echo ubuntu:ubuntu | chpasswd
adduser ubuntu sudo
