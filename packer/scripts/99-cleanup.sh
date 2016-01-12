#!/bin/sh -eux
# adapted from chef/bento
#
# Copyright 2012-2015, Chef Software, Inc. (<legal@chef.io>)
# Copyright 2011-2012, Tim Dysinger (<tim@dysinger.net>)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Delete all Linux headers
dpkg --list \
  | awk '{ print $2 }' \
  | grep 'linux-headers' \
  | xargs apt-get -y purge;

dpkg --list \
    | awk '{ print $2 }' \
    | grep 'linux-image-[234].*' \
    | grep -v `uname -r` \
    | xargs apt-get -y purge;

# Delete Linux source
dpkg --list \
    | awk '{ print $2 }' \
    | grep linux-source \
    | xargs apt-get -y purge;

pip uninstall -y ansible
rm -rf /usr/local/lib/python2.7

apt-get -y purge libyaml-dev python-dev python-pip ppp pppconfig pppoeconf popularity-contest

if [ "x${CONTAINER_FLAVOUR}" = "xrt" ]
then

# we don't need python or perl anymore anymore
apt-get -y purge python2.7 python perl perl-modules

# locales still occupy way too much space
cat > /tmp/localepurge.preseed << EOF
localepurge	localepurge/remove_no	note
localepurge localepurge/use-dpkg-feature boolean true
localepurge	localepurge/dontbothernew	boolean	false
localepurge	localepurge/showfreedspace	boolean	true
localepurge	localepurge/none_selected	boolean	false
localepurge	localepurge/verbose	boolean	false
localepurge	localepurge/nopurge	multiselect	en
localepurge	localepurge/quickndirtycalc	boolean	true
localepurge	localepurge/mandelete	boolean	true
EOF
debconf-set-selections < /tmp/localepurge.preseed
rm -f /tmp/localepurge.preseed

apt-get -y install localepurge

dpkg-reconfigure -f noninteractive localepurge
localepurge
apt-get -y purge localepurge locales

fi

apt-get -y autoremove
apt-get -y clean
rm -rf /var/lib/apt/lists/*

/usr/local/bin/defaults read
echo "Removing build files"
rm -rf $HOME/builds
rm -rf $HOME/llvm

if [ "x$PACKER_BUILDER_TYPE" != "xdocker" ]
then
  # The docker builder doesn't need the rest of the cleanup. It uses a bind
  # mounted source volume and doesn't benefit from any disk cleanup.
  echo "Removing sources"
  rm -rf /vagrant/*


echo "cleaning up dhcp leases"
rm -f /var/lib/dhcp/*

# Make sure Udev doesn't block our network
echo "cleaning up udev rules"
rm -rf /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -rf /lib/udev/rules.d/75-persistent-net-generator.rules


# clean up swap and disk memory for better compaction
set +e
swapuuid="`/sbin/blkid -o value -l -s UUID -t TYPE=swap`";
case "$?" in
	2|0) ;;
	*) exit 1 ;;
esac
set -e

if [ "x${swapuuid}" != "x" ]; then
    # Whiteout the swap partition to reduce box size
    # Swap is disabled till reboot
    swappart="`readlink -f /dev/disk/by-uuid/$swapuuid`";
    /sbin/swapoff "$swappart";
    dd if=/dev/zero of="$swappart" bs=1M || echo "dd exit code $? is suppressed";
    /sbin/mkswap -U "$swapuuid" "$swappart";
fi

dd if=/dev/zero of=/EMPTY bs=1M || echo "dd exit code $? is suppressed";
rm -f /EMPTY;
# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync;

fi
