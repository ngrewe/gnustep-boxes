#!/bin/sh -eux
apt-get -y update
apt-get -y install libyaml-dev libffi-dev libssl-dev python-dev python-pip
apt-get -y --purge remove python-cffi
# Use pip to install the version of ansible we tested with
pip install -U cffi
pip install ansible==1.9.4
