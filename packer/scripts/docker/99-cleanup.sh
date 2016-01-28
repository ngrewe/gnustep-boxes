#!/bin/sh -eux

# If running on docker:
# The /vagrant directory is bound in from the host, so we don't want
# to leave any unclean repositories
cd /vagrant/gnustep-make
make clean
cd /vagrant/gnustep-base
make clean

if [ "x${CONTAINER_FLAVOUR}" = "xrt" ]
then

rm -f  /usr/local/lib/libLLVM*.a
rm -f  /usr/local/lib/libclang*.a
rm -f  /usr/local/lib/libclang.so*
rm -f  /usr/local/lib/LLVMHello.so
rm -f  /usr/local/lib/BugpointPasses.so
rm -f  /usr/local/lib/libLTO.*
rm -rf /usr/local/lib/clang
rm -rf /usr/local/include/llvm
rm -rf /usr/local/include/llvm-c
rm -rf /usr/local/include/clang
rm -rf /usr/local/include/clang-c

rm -f /usr/local/bin/bugpoint
rm -f /usr/local/bin/clang*
rm -f /usr/local/bin/git-clang-format
rm -f /usr/local/bin/llc
rm -f /usr/local/bin/lli
rm -f /usr/local/bin/llvm-*
rm -f /usr/local/bin/macho-dump
rm -f /usr/local/bin/obj2yaml
rm -f /usr/local/bin/opt
rm -f /usr/local/bin/verify-uselistorder
rm -f /usr/local/bin/yaml2obj

rm -rf /usr/local/share/llvm
rm -rf /usr/local/shae/clang

export SUDO_FORCE_REMOVE=yes
apt-get -y purge subversion git automake autoconf make ninja libtool m4 \
build-essential curl nfs-common zip unzip cmake \
g++ lemon zlib1g-dev libkqueue-dev libpthread-workqueue-dev \
pkg-config libgnutls28-dev libgmp-dev libffi-dev libicu-dev libxml2-dev \
libxslt1-dev libssl-dev libavahi-client-dev zlib1g-dev sudo
fi
