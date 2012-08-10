default: tunatron.zip

compile:
	xcodebuild CONFIGURATION_BUILD_DIR=Release

tunatron.zip: compile
	@rm -rf tunatron.app tunatron.zip
	mv Release/tunatron.app .
	zip -r tunatron.zip tunatron.app
	rm -rf Release

upload: tunatron.zip
	github-upload.py tunatron.zip

install: tunatron.zip
	rm -rf /Applications/tunatron.app
	mv tunatron.app /Applications/

all: upload install
