# Makefile for building and publishing the yotta-compiler Docker image
# to GitHub Container Registry (ghcr.io).
#
# `build` produces an image for THIS host's architecture — that is what you
# want for local micro:bit builds. `push-multiarch` publishes a manifest list
# covering both amd64 and arm64; CI (.github/workflows/docker-publish.yml)
# does this on every push, so you rarely need it by hand.

IMAGE_NAME := ghcr.io/league-microbit/yotta-compiler
IMAGE_TAG  := latest
FULL_IMAGE := $(IMAGE_NAME):$(IMAGE_TAG)

# PXT's codal build engine runs `docker run ... pext/yotta:latest`, so the
# image has to carry that name for local PXT builds to find it.
PXT_IMAGE  := pext/yotta:latest

PLATFORMS  := linux/amd64,linux/arm64

.PHONY: build
build:
	@echo "Building Docker image for this host: $(FULL_IMAGE)"
	docker build -t $(FULL_IMAGE) .
	@echo "Built: $(FULL_IMAGE) ($$(docker image inspect $(FULL_IMAGE) --format '{{.Architecture}}'))"

.PHONY: rebuild
rebuild:
	@echo "Rebuilding with no cache: $(FULL_IMAGE)"
	docker build --no-cache -t $(FULL_IMAGE) .

## pext-tag — tag the local image as pext/yotta:latest for local PXT builds
.PHONY: pext-tag
pext-tag: build
	docker tag $(FULL_IMAGE) $(PXT_IMAGE)
	@echo "Tagged $(PXT_IMAGE) — PXT_FORCE_LOCAL=1 builds will use it"

.PHONY: push
push: build
	@echo "Pushing: $(FULL_IMAGE)"
	docker push $(FULL_IMAGE)

## push-multiarch — build and push a manifest list for $(PLATFORMS)
##   Non-native architectures build under QEMU emulation and are SLOW; CI uses
##   native runners instead. Needs a buildx builder: make buildx-setup
.PHONY: push-multiarch
push-multiarch:
	@echo "Building and pushing $(FULL_IMAGE) for $(PLATFORMS)"
	docker buildx build --platform $(PLATFORMS) -t $(FULL_IMAGE) --push .
	@$(MAKE) verify

.PHONY: buildx-setup
buildx-setup:
	docker buildx create --name yotta-builder --use --bootstrap 2>/dev/null || \
		docker buildx use yotta-builder
	docker run --privileged --rm tonistiigi/binfmt --install all

## verify — check the published image really covers both architectures
.PHONY: verify
verify:
	@docker buildx imagetools inspect $(FULL_IMAGE)
	@for want in linux/amd64 linux/arm64; do \
		docker buildx imagetools inspect $(FULL_IMAGE) --raw \
		| jq -e --arg w "$$want" \
			'[.manifests[] | select(.platform) | "\(.platform.os)/\(.platform.architecture)"] | index($$w)' \
			> /dev/null \
		|| { echo "MISSING: $$want"; exit 1; }; \
	done
	@echo "OK: $(FULL_IMAGE) publishes linux/amd64 and linux/arm64"

.PHONY: pull
pull:
	@echo "Pulling: $(FULL_IMAGE)"
	docker pull $(FULL_IMAGE)

.PHONY: clean
clean:
	@echo "Removing: $(FULL_IMAGE)"
	docker rmi $(FULL_IMAGE) || true

.PHONY: info
info:
	@echo "Image: $(FULL_IMAGE)"
	@docker images $(IMAGE_NAME) || echo "Not found locally"

.PHONY: test
test: build
	@echo "Testing container..."
	docker run --rm $(FULL_IMAGE) yotta --version
	docker run --rm $(FULL_IMAGE) arm-none-eabi-gcc --version

.PHONY: shell
shell: build
	@echo "Opening shell in container..."
	docker run --rm -it $(FULL_IMAGE) /bin/bash

.PHONY: help
help:
	@echo "yotta-compiler Makefile"
	@echo "  build          - Build the image for this host's architecture"
	@echo "  rebuild        - Build with no cache"
	@echo "  pext-tag       - Build, then tag as pext/yotta:latest for local PXT builds"
	@echo "  push           - Push this host's architecture to ghcr.io"
	@echo "  push-multiarch - Build and push amd64 + arm64 as one manifest list"
	@echo "  buildx-setup   - Create a buildx builder and install QEMU emulators"
	@echo "  verify         - Check the published image covers both architectures"
	@echo "  pull           - Pull from ghcr.io"
	@echo "  clean          - Remove local image"
	@echo "  info           - Show image info"
	@echo "  test           - Build, then verify yotta and the ARM toolchain run"
	@echo "  shell          - Build, then open a shell in the container"
