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

    $(firstword $(MAKEFILE_LIST)) [app/<name>|share/<name>|mostlyclean|clean]

endef

include $(ROOT_DIR)/mk/front_end.inc

BUILD_DIR ?= $(ROOT_DIR)/build

share/%:
	$(VERBOSE)make $(SHARE_DIR)/Makefile -C $(SHARE_DIR) ROOT_DIR=$(ROOT_DIR) VERBOSE=$(VERBOSE) $*

app/%:
	$(VERBOSE)$(ROOT_DIR)/mk/dependencies $* ROOT_DIR=$(ROOT_DIR) BUILD_DIR=$(BUILD_DIR)
	$(VERBOSE)$(ROOT_DIR)/mk/iso $* ROOT_DIR=$(ROOT_DIR) BUILD_DIR=$(BUILD_DIR)

mostlyclean:
	$(VERBOSE)rm -rf build

clean: mostlyclean
	$(VERBOSE)make $(SHARE_DIR)/Makefile -C $(SHARE_DIR) VERBOSE=$(VERBOSE) clean
	$(VERBOSE)rm -rf download
