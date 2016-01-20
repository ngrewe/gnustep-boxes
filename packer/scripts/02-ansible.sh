#!/bin/sh -eux
apt-get -y update
apt-get -y install libyaml-dev python-dev python-pip
# Use pip to install the version of ansible we tested with
pip install ansible==1.9.4
