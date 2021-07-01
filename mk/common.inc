#
# \brief  Common definitions, ROOT_DIR must be defined by the including makefile
# \author Johannes Schlatow
# \date   2021-06-30
#

VERBOSE      ?= @
DOWNLOAD_DIR ?= $(ROOT_DIR)/downloads
ARCHIVE_DIR  ?= $(ROOT_DIR)/archives
SHARE_DIR    ?= $(ROOT_DIR)/share

#
# other macros
#
dependencies_from_files = $(sort $(foreach dep,$(wildcard $(1)),$(file <$(dep))))
check_tool = $(if $(shell which $(1)),,$(error Need to have '$(1)' installed.))

