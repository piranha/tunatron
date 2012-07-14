all: tunatron.zip

build:
	xcodebuild CONFIGURATION_BUILD_DIR=Release

tunatron.zip: build
	mv Release/tunatron.app .
	cd Release && zip -r tunatron.zip tunatron.app
	rm -rf Release

upload: tunatron.zip
	github-upload.py tunatron.zip
