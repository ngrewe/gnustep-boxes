#!/bin/sh -eux

# Set build time
date > /etc/vagrant_box_build_time

# Set up password-less sudo for the vagrant user
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/99_vagrant;
chmod 440 /etc/sudoers.d/99_vagrant;

# shared folder mount
mkdir -p /vagrant
chown vagrant:vagrant /vagrant
