commit:=1e9bf8151513b054f60f34bc89507c31dc242cf0
archive:=$(commit).tar.gz
url:=https://github.com/crosstool-ng/crosstool-ng/archive/$(archive)

root_dir:=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

crosstool-ng/$(archive):
	mkdir -p crosstool-ng
	curl -L $(url) -o $@

crosstool-ng/source: crosstool-ng/$(archive)
	rm -rf $@ && mkdir $@ && tar -C $@ --strip-components 1 -xf $^

crosstool-ng/build: crosstool-ng/source
	rm -rf crosstool-ng/tmp && cp -r $^ crosstool-ng/tmp
	cd crosstool-ng/tmp; ./bootstrap
	cd crosstool-ng/tmp; ./configure --prefix $(root_dir)/$@
	make -C crosstool-ng/tmp
	make -C crosstool-ng/tmp install

targets/%/toolchain: targets/%/.config crosstool-ng/build
	cd $(dir $@); env -u LD_LIBRARY_PATH $(root_dir)/crosstool-ng/build/bin/ct-ng build

clean: clean-toolchains
	rm -rf crosstool-ng/

clean-toolchains:
	find targets/ -mindepth 2 -maxdepth 2 ! -name .config -exec rm -rf {} +

.PHONY: clean
