Virtual GNUstep Development Environments
========================================

This project orchestrates a couple of components to facilitate bootstrapping a
development environment for 'modern' Objective-C in a Linux setting.

The main idea is to spin up a virtual machine and install all the software
required to begin developing Objective-C applications on Linux using GNUstep,
regardless of whether the host system is a Mac OS, Windows or Linux machine.

This works by bootstrapping a basic Debian system into a virtual machine using
[packer](https://www.packer.io) and then adding the required dependencies and
GNUstep components into it using [ansible](http://www.ansible.com). The virtual
machine can either be a true VM that is exported as a
[Vagrant](https://www.vagrantup.com) box, or a lightweight Docker container.

The ansible playbook can also be run outside a VM context on any Linux system
that uses apt as a package manager. Since it modifies system behaviour
extensively, this is only recommended if you understand the consequences.

Requirements
------------

### Vagrant Boxes

* Vagrant
* Virtual Box or VMWare Fusion/Workstation
* If you intended to run GUI applications from within the VM: An X server.

### Docker Containers

* Docker

Getting Started
---------------

### Vagrant Boxes

To clone an instance of the vagrant box, run the following in an empty directory:

```
vagrant init ngrewe/gnustep-gui
vagrant up
```

This will download and install the GUI development image. If you don't need
GUI components you can use `ngrewe/gnustep-headless` instead. After this process has
finished, you can ssh into the box using

```
vagrant ssh
```

If you are running the VM on a host that provides an X server, you can even
export GUI applications from the VM to your host:

```
vagrant ssh -- -Y Gorm
```

### Docker Containers

The builder produces two ‘flavours’ of images. The first one is the
`gnustep-headless-dev` image, which contains all the compile-time
dependencies *and* a Docker binary. The intended use of this is to share
the docker socket from your docker host with the container and run a build script
that compiles a Objective-C application and installs it in container derived
from the `gnustep-headless-rt` flavoured runtime image.

To pull the dev image, execute:

```
docker pull ngrewe/gnustep-headless-dev
```

Similarly, the runtime image can be obtained using

```
docker pull ngrewe/gnustep-headless-rt
```

Components
----------

### Headless

The main provisioning run by ansible is implemented by a number of roles that
are layered unto each other. The basic useful role is the gnustep-headless role
that provides the following components for developing Objective-C applications
without a GUI:

#### LLVM and clang

The provisioner builds LLVM and clang version 3.7.1 from source. The build will
be a release build with the X86, ARM, AArch64 and Mips targets enabled. The
reason for doing this is that the clang packages that ship with Debian/Ubuntu
depend on the Objective-C runtime shipped with GCC, which does not support
things like ARC etc. and introduces a confusion that we want to avoid.

#### GNUstep Objective-C runtime

The GNUstep Objective-C runtime is included as a git submodule, tracking the
master branch on github. This provides not only the Objective-C runtime
interface, but also the blocks runtime that would conventionally be provided by
compiler-rt or the libBlocksRuntime library.

#### libdispatch

libdispatch provides a thread-pool and work scheduling abstraction centered
around execution of blocks. libdispatch is included as a git submodule tracking
a fork of [nickhutchinson/libdispatch](https://github.com/nickhutchinson/libdispatch)
that allows it to work with the GNUstep Objective-C runtime instead of
libBlocksRuntime.

#### GNUstep Make

GNUstep Make is a set of makefiles for GNU make that constitutes the build
system used to build GNUstep applications. The git submodule references the
github mirror of the GNUstep SVN repository. GNUstep make is configured to use
the non-fragile ABI.

#### GNUstep Base

GNUstep Base is the GNUstep implementation of the Foundation API. The git
submodule references the github mirror of the GNUstep SVN repository. The
library has the following configuration points to note:

* It's configured to use the timsort sorting algorithm. It's the most performant
of the available algorithms for real-world workloads, but it hasn't seen much
testing because it's not the default.
* The distributed objects nameserver (gdomap) has been moved to a port > 1024 so
that it can run as a normal user without special privileges. It's automatically
started by a systemd unit.

### GUI

On top of that the gnustep-gui play provides the following:

#### GNUstep GUI

GNUstep GUI provides an AppKit implementation with plugabble eventing and
rendering mechanisms. The git submodule references the github mirror of the
GNUstep SVN repository.

#### GNUstep Back

GNUstep Back implements the concrete rendering and event handling for gnustep-gui.
The git submodule references the github mirror of the GNUstep SVN repository.
It is configured for a cairo/X11 backend.

#### Gorm

Gorm is the interface builder for GNUstep. While you should be able to use nibs build by
Apple's InterfaceBuilder on GNUstep, it's quite useful to have the ability to sanity check
and tweak the GNUstep UIs using Gorm.
The git submodule references the github mirror of the GNUstep SVN repository.

### Rik.theme

The default look of GNUstep is very reminiscent of NeXTStep, which is not very
attractive to many people nowadays. For that reason the GUI boxes include the
[Rik.theme](https://github.com/AlessandroSangiuliano/rik.theme) as a git
submodule.

### Vagrantfile

The project also includes a Vagrantfile that runs the provisioning playbook on
an existing box (using `vagrant provision`). This provides the following
advantages over building a new box using packer and is hence useful to quickly
test changes:

* OS image download and installation can be skipped.
* While only few operations in the playbook are actually idempotent,
they are at least *similipotent* (so to speak), meaning that they will complete
faster after the initial run (modulo any changes).
* You can work on local changes to the git submodules and rebuild everything
quickly.

Building boxes using packer
---------------------------

We build the boxes in two passes: First the headless image (build tools, runtime, and
gnustep-base) and then the GUI one based on the output of the first:

```
packer build gnustep-headless-debian-8-x64.json
packer build gnustep-gui-debian-8-x64.json
```

The resulting Vagrant boxes are placed in the `builds/` directory.
Intermediate artifacts may be available in the `output-*` directories.

Building the runtime Docker container can be done using:

```
packer build -var container_flavour=rt gnustep-headless-debian-8-x64.json
```

Building boxes using Gulp
-------------------------

Building all components (headless and GUI Vagrant boxes, as well as development
and runtime  Docker images) can be achieved using [Gulp](http://gulpjs.com). This is currently not
very useful if you want to push to a non-standard location or customise the
packer options in any way, but generally, it would work like this (assuming a
working node.js installation):

```
npm install --global gulp-cli
npm install
gulp --docker-hub-email=foo@example.com
```

Prior to building the boxes, Gulp will ask you for the docker hub password to
use when pushing the box. It will be stored in an environment variable for packer (so that it doesn't appear on any command line). The following command line switches are currently supported:

* `--docker-hub-email` (string) specifies the email address of the docker hub account
  used for pushing the image.
* `--parallel` (boolean) turns on parallel building in packer. Your system needs a lot
  of memory to support this
* `--noninteractive` (boolean) turns of the password prompt.


Known Issues
------------

* If you upgrade the kernel shipped with the box, you will also need to rebuild
  the VM integration kernel modules.
* Linking clang is memory intensive. The Vagrantfile used to test the provisioning
  allocates 3GB of RAM to the virtual machine. If that still gives you failures
  when building LLVM/clang, trying increasing this value or allocating some more
  swap to the VM.

License and Authors
-------

The referenced git submodules are covered by their respective licenses.

Some of the packer provisioning scripts originate from [chef/bento](https://github.com/chef/bento),
licensed under the Apache license.

The original content in this project is governed by the MIT License:

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
