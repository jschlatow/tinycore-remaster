#!/usr/bin/make -f
#
# \brief  Build common components of TinyCore iso
# \author Johannes Schlatow
# \date   2021-07-01
#

ROOT_DIR := $(realpath $(dir $(MAKEFILE_LIST))/../)

include $(ROOT_DIR)/mk/common.inc

define HELP_MESSAGE

  Build iso images as specified in appliances/.

  usage:

    $(firstword $(MAKEFILE_LIST)) <name>

endef

include $(ROOT_DIR)/mk/front_end.inc

extract_from_iso = $(shell isoinfo -J -i $(1) -x $(2) > $(3))
unpack_initrd    = zcat $< | fakeroot -s $@.fakeroot cpio -i -H newc -d -D $@.incomplete
repack_initrd    = find $@.incomplete | sed s\#$@.incomplete\#.\# | fakeroot -i $@.fakeroot cpio -o -H newc -D $@.incomplete | gzip -2 > $@; advdef -z4 $@ > /dev/null
pack_initrd      = find $@.incomplete | sed s\#$@.incomplete\#.\# | cpio -R root:root -o -H newc -D $@.incomplete | gzip -2 > $@; advdef -z4 $@ > /dev/null
pack_squashfs    = mksquashfs $@.incomplete $@ -b 4k -no-xattrs > /dev/null

$(call check_tool,unsquashfs)
$(call check_tool,mksquashfs)
$(call check_tool,cpio)
$(call check_tool,fakeroot)
$(call check_tool,isoinfo)
$(call check_tool,advdef)
$(call check_tool,gzip)

########
# ISOs #
########

# extract from Core.iso
11.1/core.gz: $(DOWNLOAD_DIR)/Core-11.1.iso | 11.1
	$(call extract_from_iso,$<,'/boot/core.gz',$@)

13.1/corepure64.gz: $(DOWNLOAD_DIR)/CorePure64-13.1.iso | 13.1
	$(call extract_from_iso,$<,'/boot/corepure64.gz',$@)

16.0/corepure64.gz: $(DOWNLOAD_DIR)/CorePure64-16.0.iso | 16.0
	$(call extract_from_iso,$<,'/boot/corepure64.gz',$@)

# extract from TinyCore.iso
11.1/tinycore.gz: $(DOWNLOAD_DIR)/TinyCore-11.1.iso | 11.1
	$(call extract_from_iso,$<,'/boot/core.gz',$@)

13.1/tinycorepure64.gz: $(DOWNLOAD_DIR)/TinyCorePure64-13.1.iso | 13.1
	$(call extract_from_iso,$<,'/boot/corepure64.gz',$@)

16.0/tinycorepure64.gz: $(DOWNLOAD_DIR)/TinyCorePure64-16.0.iso | 16.0
	$(call extract_from_iso,$<,'/boot/corepure64.gz',$@)


################
# vbox modules #
################

# remove vboxguest.ko.gz from tinycore.gz
11.1/tinycore-novboxguest.gz: 11.1/tinycore.gz
	$(VERBOSE)mkdir -p $@.incomplete
	$(VERBOSE)$(unpack_initrd)
	$(VERBOSE)rm -r $@.incomplete/lib/modules/5.4.3-tinycore/kernel/drivers/virt/vboxguest || exit 1
	$(VERBOSE)$(repack_initrd)
	$(VERBOSE)rm -rf $@.*

# build initrd with vbox guest addition modules and dependencies
11.1/vboxga5244.gz: $(ARCHIVE_DIR)/vboxga5244-5.4.3-tinycore.tar.gz 11.1/tinycore.gz $(DOWNLOAD_DIR)/11.x/graphics-5.4.3-tinycore.tcz | 11.1
	$(VERBOSE)mkdir -p $@.incomplete
	$(VERBOSE)cd $@.incomplete && tar xf $<
	@# remove unneeded files
	$(VERBOSE)find $@.incomplete -type f \! \( -name \*init.d\* -o -name \*udev\* -o -name \*VBoxClient\* -o -name \*VBoxService\* -o -name \*vboxadd\* -o -wholename \*lib\/modules\/\*misc\/\* -o -name \*mount.vboxsf \) -delete
	$(VERBOSE)gzip $@.incomplete/lib/modules/5.4.3-tinycore/misc/* >/dev/null
	@# copy modules from graphics-5.4.3-tinycore
	$(VERBOSE)unsquashfs -d graphics.tmp $(DOWNLOAD_DIR)/11.x/graphics-5.4.3-tinycore.tcz > /dev/null
	$(VERBOSE)find graphics.tmp -type f \( -name drm.ko.gz -o -name drm_kms_helper.ko.gz -o -name drm_vram_helper.ko.gz -o -name vboxvideo.ko.gz -o -name ttm.ko.gz -o -name agpgart.ko.gz \) -exec cp '{}' $@.incomplete/lib/modules/5.4.3-tinycore/misc/ \;
	$(VERBOSE)rm -r graphics.tmp
	@# create etc/sysconfig/newmodules to trigger depmod on boot
	$(VERBOSE)mkdir -p $@.incomplete/etc/sysconfig
	$(VERBOSE)touch $@.incomplete/etc/sysconfig/newmodules
	@# create etc/skel/.X.d/vboxclient
	$(VERBOSE)mkdir -p $@.incomplete/etc/skel/.X.d
	$(VERBOSE)echo "VBoxClient --clipboard &" >  $@.incomplete/etc/skel/.X.d/vboxclient
	$(VERBOSE)echo "VBoxClient --display &"   >> $@.incomplete/etc/skel/.X.d/vboxclient
	@# copy etc/group, etc/passwd and opt/bootlocal.sh from core.gz to make additions
	@# TODO: for allowing persistent home or tce dir in shared folders, we would need
	@#       to hook into etc/init.d/tc-config to load vboxsf and start the service earlier
	$(VERBOSE)zcat 11.1/tinycore.gz | cpio -i -H newc -d -D $@.incomplete etc/group etc/passwd opt/bootlocal.sh
	$(VERBOSE)echo "vboxsf:x:1000:tc"                                 >> $@.incomplete/etc/group
	$(VERBOSE)echo "vboxadd:x:100:65534:1:/var/run/vboxadd:bin/false" >> $@.incomplete/etc/passwd
	$(VERBOSE)echo "modprobe vboxguest"                >> $@.incomplete/opt/bootlocal.sh
	$(VERBOSE)echo "modprobe vboxsf"                   >> $@.incomplete/opt/bootlocal.sh
	$(VERBOSE)echo "mkdir -p /media"                   >> $@.incomplete/opt/bootlocal.sh
	$(VERBOSE)echo "chown root:vboxsf /media"          >> $@.incomplete/opt/bootlocal.sh
	$(VERBOSE)echo "/etc/init.d/vboxadd-service start" >> $@.incomplete/opt/bootlocal.sh
	@# pack everything into initrd
	$(VERBOSE)$(pack_initrd)
	$(VERBOSE)rm -rf $@.incomplete

# build initrd with vbox guest additions support
16.x/vboxga_tools.gz: 16.0/tinycorepure64.gz | 16.x
	$(VERBOSE)mkdir -p $@.incomplete
	@# copy etc/group, etc/passwd and opt/bootlocal.sh from core.gz to make additions
	@# TODO: for allowing persistent home or tce dir in shared folders, we would need
	@#       to hook into etc/init.d/tc-config to load vboxsf and start the service earlier
	$(VERBOSE)zcat 16.0/tinycorepure64.gz | cpio -i -H newc -d -D $@.incomplete etc/group opt/bootlocal.sh
	$(VERBOSE)echo "vboxsf:x:1000:tc"                  >> $@.incomplete/etc/group
	$(VERBOSE)echo "modprobe vboxguest"                >> $@.incomplete/opt/bootlocal.sh
	$(VERBOSE)echo "modprobe vboxsf"                   >> $@.incomplete/opt/bootlocal.sh
	$(VERBOSE)echo "mkdir -p /media"                   >> $@.incomplete/opt/bootlocal.sh
	$(VERBOSE)echo "chown root:vboxsf /media"          >> $@.incomplete/opt/bootlocal.sh
	$(VERBOSE)echo "mount -t vboxsf -o 'gid=1000,dmode=770' shared /media" >> $@.incomplete/opt/bootlocal.sh
	@# pack everything into initrd
	$(VERBOSE)$(pack_initrd)
	$(VERBOSE)rm -rf $@.incomplete

#################
# audio support #
#################

11.x/audio-vbox.tcz.dep: | 11.x
	$(VERBOSE)echo "11.x/pulseaudio.tcz" > $@

13.x/audio-vbox.tcz.dep: | 13.x
	$(VERBOSE)echo "13.x/pulseaudio.tcz" > $@

16.x/audio-vbox.tcz.dep: | 16.x
	$(VERBOSE)echo "16.x/pulseaudio.tcz" > $@

# build minimalistic audio support package for virtualbox for 11.x
11.x/audio-vbox.tcz: $(DOWNLOAD_DIR)/11.x/alsa-config.tcz $(ARCHIVE_DIR)/asound.state 11.x/audio-vbox.tcz.dep | 11.x
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/etc/alsa/cards
	$(VERBOSE)unsquashfs -d alsa-config.tmp $< > /dev/null
	$(VERBOSE)cp $(ARCHIVE_DIR)/asound.state $@.incomplete/usr/local/etc/alsa
	$(VERBOSE)cp -r alsa-config.tmp/usr/local/etc/alsa/pcm $@.incomplete/usr/local/etc/alsa
	$(VERBOSE)cp    alsa-config.tmp/usr/local/etc/alsa/cards/HDA-Intel.conf $@.incomplete/usr/local/etc/alsa/cards/
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/share/alsa
	$(VERBOSE)cp -r alsa-config.tmp/usr/local/share/alsa/init $@.incomplete/usr/local/share/alsa
	$(VERBOSE)rm -rf alsa-config.tmp
	@# create tce.installed/audio-vbox
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/tce.installed
	$(VERBOSE)echo "#!/bin/sh"                                                      >  $@.incomplete/usr/local/tce.installed/audio-vbox
	$(VERBOSE)echo "echo \"/usr/local/etc/init.d/dbus start\" >> /opt/bootlocal.sh" >> $@.incomplete/usr/local/tce.installed/audio-vbox
	$(VERBOSE)echo "alsactl restore"                                                >> $@.incomplete/usr/local/tce.installed/audio-vbox
	$(VERBOSE)chmod +x $@.incomplete/usr/local/tce.installed/audio-vbox
	@# create autostart file for pulseaudio
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/etc/X.d
	$(VERBOSE)echo "start-pulseaudio-x11" > $@.incomplete/usr/local/etc/X.d/pulseaudio
	$(VERBOSE)chmod +x $@.incomplete/usr/local/etc/X.d/pulseaudio
	@# create squashfs package and cleanup
	$(VERBOSE)$(pack_squashfs)
	$(VERBOSE)rm -r $@.incomplete

# build minimalistic audio support package for virtualbox for 13.x
13.x/audio-vbox.tcz: $(DOWNLOAD_DIR)/13.x/alsa-config.tcz $(ARCHIVE_DIR)/asound.state 13.x/audio-vbox.tcz.dep | 13.x
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/etc/alsa/cards
	$(VERBOSE)unsquashfs -d alsa-config.tmp $< > /dev/null
	$(VERBOSE)cp $(ARCHIVE_DIR)/asound.state $@.incomplete/usr/local/etc/alsa
	$(VERBOSE)cp -r alsa-config.tmp/usr/local/etc/alsa/pcm $@.incomplete/usr/local/etc/alsa
	$(VERBOSE)cp    alsa-config.tmp/usr/local/etc/alsa/cards/HDA-Intel.conf $@.incomplete/usr/local/etc/alsa/cards/
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/share/alsa
	$(VERBOSE)cp -r alsa-config.tmp/usr/local/share/alsa/init $@.incomplete/usr/local/share/alsa
	$(VERBOSE)rm -rf alsa-config.tmp
	@# create tce.installed/audio-vbox
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/tce.installed
	$(VERBOSE)echo "#!/bin/sh"                                                      >  $@.incomplete/usr/local/tce.installed/audio-vbox
	$(VERBOSE)echo "echo \"/usr/local/etc/init.d/dbus start\" >> /opt/bootlocal.sh" >> $@.incomplete/usr/local/tce.installed/audio-vbox
	$(VERBOSE)echo "alsactl restore"                                                >> $@.incomplete/usr/local/tce.installed/audio-vbox
	$(VERBOSE)chmod +x $@.incomplete/usr/local/tce.installed/audio-vbox
	@# create autostart file for pulseaudio
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/etc/X.d
	$(VERBOSE)echo "start-pulseaudio-x11" > $@.incomplete/usr/local/etc/X.d/pulseaudio
	$(VERBOSE)chmod +x $@.incomplete/usr/local/etc/X.d/pulseaudio
	@# create squashfs package and cleanup
	$(VERBOSE)$(pack_squashfs)
	$(VERBOSE)rm -r $@.incomplete

# build minimalistic audio support package for virtualbox for 16.x
16.x/audio-vbox.tcz: $(DOWNLOAD_DIR)/16.x/alsa-config.tcz $(ARCHIVE_DIR)/asound.state 16.x/audio-vbox.tcz.dep | 16.x
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/etc/alsa/cards
	$(VERBOSE)unsquashfs -d alsa-config.tmp $< > /dev/null
	$(VERBOSE)cp $(ARCHIVE_DIR)/asound.state $@.incomplete/usr/local/etc/alsa
	$(VERBOSE)cp -r alsa-config.tmp/usr/local/etc/alsa/pcm $@.incomplete/usr/local/etc/alsa
	$(VERBOSE)cp    alsa-config.tmp/usr/local/etc/alsa/cards/HDA-Intel.conf $@.incomplete/usr/local/etc/alsa/cards/
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/share/alsa
	$(VERBOSE)cp -r alsa-config.tmp/usr/local/share/alsa/init $@.incomplete/usr/local/share/alsa
	$(VERBOSE)rm -rf alsa-config.tmp
	@# create tce.installed/audio-vbox
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/tce.installed
	$(VERBOSE)echo "#!/bin/sh"                                                      >  $@.incomplete/usr/local/tce.installed/audio-vbox
	$(VERBOSE)echo "echo \"/usr/local/etc/init.d/dbus start\" >> /opt/bootlocal.sh" >> $@.incomplete/usr/local/tce.installed/audio-vbox
	$(VERBOSE)echo "alsactl restore"                                                >> $@.incomplete/usr/local/tce.installed/audio-vbox
	$(VERBOSE)chmod +x $@.incomplete/usr/local/tce.installed/audio-vbox
	@# create autostart file for pulseaudio
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/etc/X.d
	$(VERBOSE)echo "start-pulseaudio-x11" > $@.incomplete/usr/local/etc/X.d/pulseaudio
	$(VERBOSE)chmod +x $@.incomplete/usr/local/etc/X.d/pulseaudio
	@# create squashfs package and cleanup
	$(VERBOSE)$(pack_squashfs)
	$(VERBOSE)rm -r $@.incomplete
	
##################
# webcam support #
##################

11.x/uvcvideo.tcz.dep: | 11.x
	$(VERBOSE)touch $@
	@true

13.x/uvcvideo.tcz.dep: | 13.x
	$(VERBOSE)touch $@
	@true

16.x/uvcvideo.tcz.dep: | 16.x
	$(VERBOSE)touch $@
	@true

# build minimalistic webcam support package for 11.x
11.x/uvcvideo.tcz: $(DOWNLOAD_DIR)/11.x/v4l-dvb-5.4.3-tinycore.tcz | 11.x
	$(VERBOSE)unsquashfs -d $@.incomplete $< > /dev/null
	$(VERBOSE)find $@.incomplete -type f \! \( -name uvcvideo.ko.gz -o -name videobuf2-v4l2.ko.gz -o -name videobuf2-common.ko.gz -o -name videobuf2-vmalloc.ko.gz -o -name videobuf2-memops.ko.gz \) -delete
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/tce.installed
	$(VERBOSE)echo "#!/bin/sh"         >  $@.incomplete/usr/local/tce.installed/uvcvideo
	$(VERBOSE)echo "modprobe uvcvideo" >> $@.incomplete/usr/local/tce.installed/uvcvideo
	$(VERBOSE)chmod +x $@.incomplete/usr/local/tce.installed/uvcvideo
	$(VERBOSE)$(pack_squashfs)
	$(VERBOSE)rm -r $@.incomplete

# build minimalistic webcam support package for 13.x
13.x/uvcvideo.tcz: $(DOWNLOAD_DIR)/13.x/v4l-dvb-5.15.10-tinycore64.tcz | 13.x
	$(VERBOSE)unsquashfs -d $@.incomplete $< > /dev/null
	$(VERBOSE)find $@.incomplete -type f \! \( -name uvcvideo.ko.gz -o -name videobuf2-v4l2.ko.gz -o -name videobuf2-common.ko.gz -o -name videobuf2-vmalloc.ko.gz -o -name videobuf2-memops.ko.gz \) -delete
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/tce.installed
	$(VERBOSE)echo "#!/bin/sh"         >  $@.incomplete/usr/local/tce.installed/uvcvideo
	$(VERBOSE)echo "modprobe uvcvideo" >> $@.incomplete/usr/local/tce.installed/uvcvideo
	$(VERBOSE)chmod +x $@.incomplete/usr/local/tce.installed/uvcvideo
	$(VERBOSE)$(pack_squashfs)
	$(VERBOSE)rm -r $@.incomplete

# build minimalistic webcam support package for 13.x
16.x/uvcvideo.tcz: $(DOWNLOAD_DIR)/16.x/v4l-dvb-6.12.11-tinycore64.tcz | 16.x
	$(VERBOSE)unsquashfs -d $@.incomplete $< > /dev/null
	$(VERBOSE)find $@.incomplete -type f \! \( -name uvc.ko.gz -o -name uvcvideo.ko.gz -o -name videobuf2-v4l2.ko.gz -o -name videobuf2-common.ko.gz -o -name videobuf2-vmalloc.ko.gz -o -name videobuf2-memops.ko.gz \) -delete
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/tce.installed
	$(VERBOSE)echo "#!/bin/sh"         >  $@.incomplete/usr/local/tce.installed/uvcvideo
	$(VERBOSE)echo "modprobe uvcvideo" >> $@.incomplete/usr/local/tce.installed/uvcvideo
	$(VERBOSE)chmod +x $@.incomplete/usr/local/tce.installed/uvcvideo
	$(VERBOSE)$(pack_squashfs)
	$(VERBOSE)rm -r $@.incomplete

######################
# KeePassXC AppImage #
######################

16.x/keepassxc.tcz.dep: | 16.x
	$(VERBOSE)echo "16.x/bash.tcz" > $@
	$(VERBOSE)echo "16.x/fuse.tcz" >> $@
	$(VERBOSE)echo "16.x/libgpg-error.tcz" >> $@
	$(VERBOSE)echo "16.x/libusb.tcz" >> $@

16.x/keepassxc.tcz: $(DOWNLOAD_DIR)/KeePassXC-2.7.10-x86_64.AppImage | 16.x
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/bin
	$(VERBOSE)mkdir -p $@.incomplete/usr/local/tce.installed
	$(VERBOSE)cp $< $@.incomplete/usr/local/bin/keepassxc
	$(VERBOSE)chmod +x $@.incomplete/usr/local/bin/keepassxc
	$(VERBOSE)echo "#!/bin/sh"                               >  $@.incomplete/usr/local/tce.installed/keepassxc
	$(VERBOSE)echo "[ -e /lib64 ] || sudo ln -s /lib /lib64" >> $@.incomplete/usr/local/tce.installed/keepassxc
	$(VERBOSE)chmod +x $@.incomplete/usr/local/tce.installed/keepassxc
	$(VERBOSE)$(pack_squashfs)
	$(VERBOSE)rm -r $@.incomplete

11.1 11.x 13.1 13.x 16.0 16.x:
	$(VERBOSE)mkdir $@

$(DOWNLOAD_DIR)/KeePassXC-2.7.10-x86_64.AppImage:
	@echo "Downloading $@"
	$(VERBOSE) curl -s -L -f -o $@ https://github.com/keepassxreboot/keepassxc/releases/download/2.7.10/KeePassXC-2.7.10-x86_64.AppImage
	$(VERBOSE)cd $(dir $@); (echo "3f8308a4d905d067367d541b4dccd5e80700798039046ffc388ede4f50887b36  $@" | sha256sum -c) || exit 1

$(DOWNLOAD_DIR)/%.iso:
	$(VERBOSE)make -f $(ROOT_DIR)/mk/download DOWNLOAD_DIR=$(DOWNLOAD_DIR) VERBOSE=$(VERBOSE) $*.iso

$(DOWNLOAD_DIR)/11.x/%.tcz:
	$(VERBOSE)make -f $(ROOT_DIR)/mk/download DOWNLOAD_DIR=$(DOWNLOAD_DIR) VERBOSE=$(VERBOSE) 11.x/$*.tcz

$(DOWNLOAD_DIR)/13.x/%.tcz:
	$(VERBOSE)make -f $(ROOT_DIR)/mk/download DOWNLOAD_DIR=$(DOWNLOAD_DIR) VERBOSE=$(VERBOSE) 13.x/$*.tcz

$(DOWNLOAD_DIR)/16.x/%.tcz:
	$(VERBOSE)make -f $(ROOT_DIR)/mk/download DOWNLOAD_DIR=$(DOWNLOAD_DIR) VERBOSE=$(VERBOSE) 16.x/$*.tcz

clean:
	$(VERBOSE)rm -f */*.gz
	$(VERBOSE)rm -f */*.tcz
	$(VERBOSE)rm -rf */*.incomplete
