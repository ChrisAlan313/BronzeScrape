ADDON_NAME := BronzeScrape
VERSION ?= 0.0.1
LUACHECK ?= luacheck
LUACHECK_FLAGS ?= --config .luacheckrc
SRC_DIRS := BronzeScrape.lua core wow
DIST_DIR := dist/$(ADDON_NAME)

.PHONY: check install-luacheck dist clean qc

check:
	find $(SRC_DIRS) -name '*.lua' -print0 | xargs -0 $(LUACHECK) $(LUACHECK_FLAGS)

install-luacheck:
	luarocks install luacheck

install-busted:
	luarocks install busted

.PHONY: test install-busted

test:
	cd core && busted

# `qc` runs quality checks: lint then tests. It fails if either step fails.
qc: check test

dist:
	rm -rf dist
	mkdir -p $(DIST_DIR)

	# Core addon files
	cp BronzeScrape.lua BronzeScrape.toc $(DIST_DIR)

	# Runtime code only
	cp -R wow $(DIST_DIR)

	# Optional: include core only if used at runtime
	# cp -R core $(DIST_DIR)

	@echo "Built addon into $(DIST_DIR)"

clean:
	rm -f BronzeScrape-*.zip