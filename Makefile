#
# Small makefile to simplify building and testing from the command line
#
default: build-macos test-macos

build: build-macos

test: test-macos

build-macos:
	swift build

test-macos:
	swift test

lint:
	swiftlint autocorrect

doc:
	./doc_generation.sh
