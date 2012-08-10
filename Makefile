VERSION := $(shell /usr/libexec/PlistBuddy -c 'Print CFBundleVersion' tunatron/tunatron-Info.plist)

default: tunatron-$(VERSION).zip

compile:
	xcodebuild CONFIGURATION_BUILD_DIR=Release

tunatron-$(VERSION).zip: compile
	@rm -rf tunatron.app tunatron*.zip
	mv Release/tunatron.app .
	zip -r tunatron-$(VERSION).zip tunatron.app
	rm -rf Release

upload: tunatron-$(VERSION).zip
	github-upload.py tunatron-$(VERSION).zip

install: tunatron-$(VERSION).zip
	rm -rf /Applications/tunatron.app
	mv tunatron.app /Applications/

all: upload install
