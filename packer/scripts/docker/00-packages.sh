#!/bin/sh -eux
set -e
set -x
apt-get -y update
apt-get -y install curl
sed -i "s/httpredir.debian.org/`curl -s -D - http://httpredir.debian.org/demo/debian/ | awk '/^Link:/ { print $2 }' | sed -e 's@<http://\(.*\)/debian/>;@\1@g'`/" /etc/apt/sources.list
apt-get -y update
# Packages required for provisioning.
apt-get -y install sudo
mkdir -p /vagrant
