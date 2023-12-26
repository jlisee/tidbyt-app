SOURCES := $(wildcard *.star)
TARGETS := $(SOURCES:.star=.webp)
DEVICE := accordingly-enriching-droll-mongrel-bc7
IMAGE ?= hello_worldls

all: $(TARGETS)

%.webp: %.star
	./pixlet render $<
	touch $@

publish: ${IMAGE}.webp
	./pixlet push $(DEVICE) $<
