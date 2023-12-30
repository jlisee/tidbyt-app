PIXLET := build/pixlet
SOURCES := $(wildcard *.star)
TARGETS := $(patsubst %.star,build/%.webp,$(SOURCES))

OS := $(shell uname -s)

# My tidbyt
DEVICE := accordingly-enriching-droll-mongrel-bc7
IMAGE ?= hello_world

# We can only a-z, A-Z, 0-9
INSTALLATION_ID=$(subst _,,${IMAGE})

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
	if [ -f ./$*/config.sh ]; then \
		CONFIG=$$(./$*/config.sh); \
	else \
		CONFIG=""; \
	fi; \
	$(PIXLET) render $< $$CONFIG -o $@

# Push it to our device
push: build/${IMAGE}.webp
	$(PIXLET) push $(DEVICE) $<

# Push it to our device
deploy: build/${IMAGE}.webp
	$(PIXLET) push --installation-id $(INSTALLATION_ID) $(DEVICE) $<

# View it locally
serve:
	$(PIXLET) serve ${IMAGE}.star
