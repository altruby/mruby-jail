# Makefile for mruby-jail
#
# Prerequisites:
#   ../mruby    # mruby checkout (sibling directory)
#
# Quick start:
#   make        # build toolchain and run tests
#   make test   # run tests
#   make clean  # clean build artifacts

MRUBY_DIR    ?= ../mruby
BUILD_CONFIG  = build.rb
BUILD_NAME    = mruby-jail
BUILD_DIR     = $(MRUBY_DIR)/build/$(BUILD_NAME)
BUILD ?= test

TOOLCHAIN_BIN  = bin/mruby bin/mrbc bin/mruby-config
TOOLCHAIN_STAMP = tmp/toolchain.$(BUILD).stamp

##
# Sources that require the toolchain to be rebuilt. The `!=` assignment
# runs the command at read time and is understood by both bmake and
# GNU make (>= 4.0)
SOURCES != find mrblib spec src -type f 2>/dev/null | sort

.PHONY: all test toolchain clean distclean

all: toolchain test

test: toolchain
	ENV=TEST bin/mruby -r./spec/setup.rb spec/jail_spec.rb

toolchain: $(TOOLCHAIN_STAMP)

$(TOOLCHAIN_STAMP): $(BUILD_CONFIG) mrbgem.rake $(SOURCES)
	mkdir -p tmp bin
	ruby -C $(MRUBY_DIR) minirake clean 2>/dev/null || true
	BUILD=$(BUILD) ruby -C $(MRUBY_DIR) minirake MRUBY_CONFIG=$$(pwd)/$(BUILD_CONFIG)
	cp -r $(BUILD_DIR)/bin/* bin/
	touch $(TOOLCHAIN_STAMP)

clean:
	rm -f $(TOOLCHAIN_BIN)
	rm -f tmp/toolchain.*.stamp

distclean: clean
	rm -rf $(BUILD_DIR)
