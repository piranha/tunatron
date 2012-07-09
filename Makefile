all: release

build:
	xcodebuild CONFIGURATION_BUILD_DIR=Release

release: build
	mv Release/tunatron.app .
	zip -r tunatron.zip tunatron.app
	rm -rf Release
