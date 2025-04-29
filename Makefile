#!/usr/bin/make -f

#
# \brief  Build iso images as specified in appliances/.
# \author Johannes Schlatow
# \date   2021-07-01
#

ROOT_DIR := $(realpath $(dir $(MAKEFILE_LIST))/)

include $(ROOT_DIR)/mk/common.inc

define HELP_MESSAGE

  Build iso images as specified in appliances/.

  usage:

    $(firstword $(MAKEFILE_LIST)) [goa/<name>|app/<name>|share/<name>|mostlyclean|clean]

endef

include $(ROOT_DIR)/mk/front_end.inc

BUILD_DIR ?= $(ROOT_DIR)/build

share/%:
	$(VERBOSE)make $(SHARE_DIR)/Makefile -C $(SHARE_DIR) ROOT_DIR=$(ROOT_DIR) VERBOSE=$(VERBOSE) $*

app/%:
	$(VERBOSE)$(ROOT_DIR)/mk/dependencies $* ROOT_DIR=$(ROOT_DIR) BUILD_DIR=$(BUILD_DIR)
	$(VERBOSE)$(ROOT_DIR)/mk/iso $* ROOT_DIR=$(ROOT_DIR) BUILD_DIR=$(BUILD_DIR)

goa/%: app/%
	$(VERBOSE)mkdir -p goa/vm-$*/raw
	$(VERBOSE)cp $(BUILD_DIR)/$*.iso goa/vm-$*/raw/
	$(VERBOSE)date --iso-8601 > goa/vm-$*/version

mostlyclean:
	$(VERBOSE)rm -rf build

clean: mostlyclean
	$(VERBOSE)make $(SHARE_DIR)/Makefile -C $(SHARE_DIR) VERBOSE=$(VERBOSE) clean
	$(VERBOSE)rm -rf download
	$(VERBOSE)rm -rf goa/vm-*
