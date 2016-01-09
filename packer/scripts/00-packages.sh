#!/bin/sh -eux
set -e
set -x


if [ "x$PACKER_BUILDER_TYPE" != "xdocker" ]
then
  echo "pre-up sleep 2" >> /etc/network/interfaces

  # Update package cache
  apt-get -y update
  HEADERS_PKG=linux-headers-`uname -r`
else
  HEADERS_PKG=""
fi

# Packages required for provisioning.
apt-get -y install build-essential curl unzip python-pip nfs-common $HEADERS_PKG

# We need to terminate the ssh sessions, which doesn't work correctly in jessie,
# due to https://bugs.debian.org/751636
#systemctl stop ssh
#systemctl kill sshd@*
#/etc/init.d/networking stop
#sleep 5
#/sbin/reboot
#sleep 60
