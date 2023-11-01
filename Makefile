.PHONY: all build
build:
	cd cmd/gogtp5g-link
	sudo go build -o ../../tools/gtp5g-link
	cd ../..
	cd cmd/gogtp5g-tunnel
	sudo go build -o ../../tools/gtp5g-tunnel
all:
	sudo ./run.sh SimpleUPTest
