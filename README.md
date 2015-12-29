Virtual Objective-C Development Environment
===========================================

This project orchestrates a couple of components to facilitate bootstrapping a
development environment for 'modern' Objective-C in a Linux setting.

The main idea is to spin up a virtual machine and install all the software
required to begin developing Objective-C applications on Linux on it
automatically, regardless of whether the host system is a Mac OS, Windows or
Linux machine.

Requirements
------------
* [Vagrant](https://www.vagrantup.com), a tool to automate setup of virtual
  machines
* A virtual machine hypervisor supported by Vagrant (e.g. VirtualBox).
* [Ansible](https://ansible.com), used to provision the required software into
  the VM.


Included components
-------------------

The ansible playbook includes the following components

### LLVM and clang


The provisioner builds LLVM and clang version 3.7.1 from source. The build will
be a release build with the X86, ARM, AArch64 and Mips targets enabled. The
reason for doing this is that the clang packages that ship with Debian/Ubuntu
depend on the Objective-C runtime shipped with GCC, which does not support
things like ARC etc.

### GNUstep Objective-C runtime

The GNUstep Objective-C runtime is included as a git submodule, tracking the
master branch on github. This provides not only the Objective-C runtime
interface, but also the blocks runtime that would conventionally be provided by
the libBlocksRuntime library.

### libdispatch


libdispatch provides a thread-pool and work scheduling abstraction centered
around execution of blocks. libdispatch is included as a git submodule tracking
a fork of [nickhutchinson/libdispatch](https://github.com/nickhutchinson/libdispatch)
that allows it to work with the GNUstep Objective-C runtime instead of
libBlocksRuntime.

### GNUstep Make

GNUstep Make is a set of makefiles for GNU make that constitutes the build
system used to build GNUstep applications. The git submodule references the
github mirror of the GNUstep SVN repository.

### GNUstep Base

GNUstep Base is the GNUstep implementation of the Foundation API. The git
submodule references the github mirror of the GNUstep SVN repository.

*Others forthcoming*


Known Issues
------------

* The base image for VMware hypervisors doesn't seem to install the tools
  correctly that are required for mounting the shared folder. A workaround is
  to manually ssh into the machine (`vagrant ssh`) and execute
  `sudo vmware-config-tools.pl` to rebuild the kernel modules. If the system is
  missing kernel headers, try running `sudo apt-get install linux-headers-amd64`.
* Linking clang is memory intensive. The Vagrantfile allocates 3GB of RAM to
  the virtual machine. If that still gives you failures when building LLVM/clang,
  trying increasing this value or allocating some swap to the VM.

License
-------

The referenced modules are covered by their respective licenses. The original
content in this project is governed by the MIT License:

Copyright (c) 2015 Niels Grewe

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
