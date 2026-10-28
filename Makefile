PICORUBY_DIR  ?= ../picoruby
BUILD_NAME     = picoruby-jail
ROOT          != pwd
BUILD_CONFIG   = $(ROOT)/build_config/$(BUILD_NAME).rb
BUILD_DIR      = $(PICORUBY_DIR)/build/$(BUILD_NAME)
SOURCES       != find mrblib src test -type f 2>/dev/null | sort
BUILD_STAMP    = tmp/build.stamp

.PHONY: all build test clean distclean

all: test

build: $(BUILD_STAMP)

$(BUILD_STAMP): mrbgem.rake $(BUILD_CONFIG) $(SOURCES)
	mkdir -p tmp
	cd $(PICORUBY_DIR) && MRUBY_CONFIG=$(BUILD_CONFIG) rake all
	touch $(BUILD_STAMP)

test: build
	ruby tool/picotest.rb

clean:
	rm -f $(BUILD_STAMP)
	cd $(PICORUBY_DIR) && MRUBY_CONFIG=$(BUILD_CONFIG) rake clean

distclean: clean
	rm -rf $(BUILD_DIR)
