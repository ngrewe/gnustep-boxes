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
set -x
set -e
mkdir -p /tmp/vmfusion;
mkdir -p /tmp/vmfusion-archive;
mount -o loop /home/vagrant/linux.iso /tmp/vmfusion;
tar xzf /tmp/vmfusion/VMwareTools-*.tar.gz -C /tmp/vmfusion-archive;
/tmp/vmfusion-archive/vmware-tools-distrib/vmware-install.pl --force-install;
umount /tmp/vmfusion;
rm -rf  /tmp/vmfusion;
rm -rf  /tmp/vmfusion-archive;
rm -f /home/vagrant/*.iso;
