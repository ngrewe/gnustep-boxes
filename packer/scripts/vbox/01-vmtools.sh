#!/bin/sh -eux
# Adapted from chef/bento:
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

set -e
set -x

mkdir -p /tmp/vbox;
ver="`cat /home/vagrant/.vbox_version`";
mount -o loop /home/vagrant/VBoxGuestAdditions_${ver}.iso /tmp/vbox;
sh /tmp/vbox/VBoxLinuxAdditions.run \
  || echo "VBoxLinuxAdditions.run exited $? and is suppressed." \
  "For more read https://www.virtualbox.org/ticket/12479";
umount /tmp/vbox;
rm -rf /tmp/vbox;
rm -f $HOME_DIR/*.iso;
