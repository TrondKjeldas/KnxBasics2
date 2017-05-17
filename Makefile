#
# Small makefile to simplify building and testing from the command line
#
default: build-macos build-ios

test: test-macos

build-macos:
	xcodebuild -workspace KnxBasics2.xcworkspace -scheme KnxBasics2

test-macos:
	xcodebuild -workspace KnxBasics2.xcworkspace -scheme KnxBasics2 test

build-ios:
	xcodebuild -workspace KnxBasics2.xcworkspace -scheme KnxBasics2Ios 

lint:
	swiftlint autocorrect

