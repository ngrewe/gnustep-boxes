#!/bin/sh -eux
set -e
set -x


echo "pre-up sleep 2" >> /etc/network/interfaces

# Update package cache
apt-get -y update

# Packages required for provisioning.
apt-get -y install build-essential curl unzip python-pip nfs-common linux-headers-`uname -r`;

# We need to terminate the ssh sessions, which doesn't work correctly in jessie,
# due to https://bugs.debian.org/751636
#systemctl stop ssh
#systemctl kill sshd@*
#/etc/init.d/networking stop
#sleep 5
#/sbin/reboot
#sleep 60
