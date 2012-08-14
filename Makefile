VERSION := $(shell /usr/libexec/PlistBuddy -c 'Print CFBundleVersion' tunatron/tunatron-Info.plist)
PRIVATE = ~/Documents/kb/tunatron-private.pem

default: tunatron-$(VERSION).zip

compile:
	xcodebuild CONFIGURATION_BUILD_DIR=Release > /dev/null

tunatron-$(VERSION).zip: compile
	@rm -rf tunatron.app tunatron*.zip
	mv Release/tunatron.app .
	zip -r $@ tunatron.app > /dev/null
	rm -rf Release

upload: tunatron-$(VERSION).zip
	github-upload.py $<

sign: tunatron-$(VERSION).zip
	openssl dgst -sha1 -binary < $< | openssl dgst -dss1 -sign $(PRIVATE) | openssl enc -base64

all: sign upload
