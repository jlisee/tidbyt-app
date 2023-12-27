SOURCES := $(wildcard *.star)
TARGETS := $(patsubst %.star,build/%.webp,$(SOURCES))
DEVICE := accordingly-enriching-droll-mongrel-bc7
IMAGE ?= hello_world
PIXLET := build/pixlet
OS := $(shell uname -s)

# Fetch pixlet based on OS
ifeq ($(OS),Darwin)
    PIXLET_URL := https://github.com/tidbyt/pixlet/releases/download/v0.29.1/pixlet_0.29.1_darwin_arm64.tar.gz
else
    PIXLET_URL := https://github.com/tidbyt/pixlet/releases/download/v0.29.1/pixlet_0.29.1_linux_amd64.tar.gz
endif

# Always compile everything
all: $(TARGETS)

clean:
	rm -rf build

# Fetch the pixlet tool
$(PIXLET):
	mkdir -p build
	curl -L $(PIXLET_URL) -o build/pixlet.tar.gz
	tar -xzf build/pixlet.tar.gz -C build

# Render each starlark file as webp image/animation
build/%.webp: %.star | $(PIXLET)
	$(PIXLET) render $< -o $@

# Push it to our device
publish: build/${IMAGE}.webp
	$(PIXLET) push $(DEVICE) $<

# View it locally
serve:
	$(PIXLET) serve ${IMAGE}.star
