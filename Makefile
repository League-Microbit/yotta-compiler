# Makefile for building and publishing the yotta-compiler Docker image
# to GitHub Container Registry (ghcr.io).

IMAGE_NAME := ghcr.io/league-microbit/yotta-compiler
IMAGE_TAG  := latest
FULL_IMAGE := $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: build
build:
	@echo "Building Docker image: $(FULL_IMAGE)"
	docker build -t $(FULL_IMAGE) .
	@echo "Built: $(FULL_IMAGE)"

.PHONY: rebuild
rebuild:
	@echo "Rebuilding with no cache: $(FULL_IMAGE)"
	docker build --no-cache -t $(FULL_IMAGE) .

.PHONY: push
push: build
	@echo "Pushing: $(FULL_IMAGE)"
	docker push $(FULL_IMAGE)

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

.PHONY: shell
shell: build
	@echo "Opening shell in container..."
	docker run --rm -it $(FULL_IMAGE) /bin/bash

.PHONY: help
help:
	@echo "yotta-compiler Makefile"
	@echo "  build    - Build the Docker image"
	@echo "  rebuild  - Build with no cache"
	@echo "  push     - Push to ghcr.io"
	@echo "  pull     - Pull from ghcr.io"
	@echo "  clean    - Remove local image"
	@echo "  info     - Show image info"
	@echo "  test     - Build, then verify yotta --version"
	@echo "  shell    - Build, then open a shell in the container"