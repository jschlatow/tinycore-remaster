This directory contains static archives that have been generated/built
on an installed TinyCore (TC) 11.1 system.


# 11.x/firefox.tcz

This archive has been built following the default instructions for installing
the latest firefox on TC.
More precisely, this is achieved by installing `firefox_getLatest` and running
the corresponding shell script, which consequently creates the firefox.tcz.

```
tce-load -wi firefox_getLastest
firefox_getLatest.sh
```


# 11.x/i3.tcz

TC 11.1 does not provide a working package for the i3 window manager.
Yet, you can compile i3 4.7.2 using the following instructions.
Note, that 4.7.2 is the latest version of i3 that still supports yajl < 2.0.

First, install the following dependencies:

```
tce-load -wi linux-kernel-source-env # installs all required build tools
tce-load -wi libyajl-dev
tce-load -wi pango-dev
tce-load -wi pcre-dev
tce-load -wi libev-dev
tce-load -wi squashfs-tools
```

Second, download and unpack i3 4.7.2 and run:

```
cd i3-4.7.2
make
mkdir /tmp/i3
make DESTDIR=/tmp/i3 install
strip -g /tmp/i3/usr/bin/*
```

Adding an executable file `/tmp/i3/usr/local/tce.installed/i3` with
the following content sets i3 as the default window manager:

```
#!/bin/sh
echo "i3" > /etc/sysconfig/desktop
```

In a last step, we create the tcz package:

```
cd /tmp
mksquashfs i3 i3.tcz
```


# 11.x/i3-minimal.tcz

To strip down the i3 package to a minimum, we only keep the following
binaries/scripts in /tmp/i3/usr/bin: i3, i3-with-shmlog and i3-sensible-\*.
Furthermore, we should adapt /tmp/i3/etc/i3/config to remove the status bar 
and any occurence of i3-nagbar, i3-config-wizard and dmenu.


# vboxga5244-5.4.3-tinycore.tar.gz

This archives contains the files installed from VirtualBox Guest Additions 5.2.44
on TC 11.1 with Kernel 5.4.3.
In order to install the VBox Guest Additions on an existing TC installation,
download the VBox Guest Additions ISO and make it available to your TC installation
as a CD/DVD drive.

You can build and install the guest additions by running the following commands.
Note, that we do not need to build a new kernel but only download the source code
by modifying `linux-kernel-sources-env.sh`.

```
tce-load -wi linux-kernel-sources-env
cd ~
sed 's/^make/#\0/' $(which linux-kernel-sources-env.sh) > ./linux-sources.sh
./linux-sources.sh
mount /dev/sr0 /mnt/sr0
cd /mnt/sr0
touch /tmp/mark
./VBoxLinuxAddition.sh
```

Now, we create an archive from all files newer than `/tmp/mark`:

```
find /opt /sbin /usr /lib /etc -cnewer /tmp/mark -not -type d > /tmp/files
tar -T /tmp/files -czvf ~/vboxga5244-5.4.3-tinycore.tar.gz
```
