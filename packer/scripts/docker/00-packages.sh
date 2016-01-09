#!/bin/sh -eux
set -e
set -x

apt-get -y update

# Packages required for provisioning.
apt-get -y install sudo
mkdir -p /vagrant
