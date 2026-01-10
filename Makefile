VERSION ?= 0.1.0
LUACHECK ?= luacheck
LUACHECK_FLAGS ?= --config .luacheckrc
SRC_DIRS := BronzeScrape.lua core wow

.PHONY: check install-luacheck dist clean qc

check:
	find $(SRC_DIRS) -name '*.lua' -print | xargs $(LUACHECK) $(LUACHECK_FLAGS) || true

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
	zip -r BronzeScrape-$(VERSION).zip . -x '*.git*' 'tests/*' 'Makefile' '*.rockspec' '.luacheckrc' '*.md' '*.zip'

clean:
	rm -f BronzeScrape-*.zip