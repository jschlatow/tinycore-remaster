This repository provides Makefile-based tools to create customized TinyCore
images aka _appliances_.

# Folders

This repositories contains the following subdirectories:

* [appliances]: contains the build instruction of your appliances
* [mk]: contains the Makefile-based tools `download`, `iso` and `dependencies`
* [downloads]: default download directory for official iso and tcz files
* [share]: contains instructions for building custom initramfs or tcz files
* [archive]: contains static archives

[appliances]: ./appliances/
[mk]: ./mk/
[downloads]: ./downloads/
[share]: ./share/
[archive]: ./archive/

# Usage

To build an appliance for which build instruction already exist, simply run:

```
make app/<name>
```

Here, `<name>` refers to the subdirectory in `./appliances/` which must contain
an `iso.mk` file containing the instructions.
After a successful build, you will find the resulting iso image under
`./build/<name>.iso`.

The `iso.mk` file solely contains a few variable definitions that are used
by the tools in `./mk/` to assemble the iso image. E.g.:

```
BASE_ISO       := Core-11.1.iso
CORE_GZ        := 11.1/tinycore-novboxguest.gz
EXTRA_INITRDS  := 11.1/vboxga5244.gz
APPS(DOWNLOAD) := 11.x/Xorg-7.7 \
                  11.x/pavucontrol
APPS(ARCHIVE)  := i3 \
                  firefox
APPS(SHARE)    := 11.x/audio-vbox \
                  11.x/uvcvideo
```

`BASE_ISO` and `CORE_GZ` are mandatory. The former specifies what official
TinyCore image shall be used as a basis whereas the latter explicitly states
what initramfs is used.
The `core.gz` file of the base iso will thus be replaced with the specified file.
You can specify an arbitrary number of additional initramfs files in
`EXTRA_INITRDS`.
In the example above, we take a slightly modified initramfs from the TinyCore
iso in which we removed the vboxguest kernel module and add a second initramfs
containing the VirtualBox Guest Additions.
The build instructions for files referenced by `CORE_GZ` and `EXTRA_INITRDS`
are found in `./share/`.

The variables `APPS(DOWNLOAD)`, `APPS(ARCHIVE)` and `APPS(SHARE)` specify what
packages (tcz) shall be loaded on startup.
The packages are searched/built in `./downloads/`, `./archive/` or `./share/`
respectively.
Package dependencies are automatically resolved, downloaded and included in
the iso.

In addition to the definitions in `iso.mk`, one can add a folder `mydata`.
The entire files and folder structure beneath `mydata` will be packaged into
a `mydata.tgz` file that will be copied onto the root file system by TinyCore
on startup.
