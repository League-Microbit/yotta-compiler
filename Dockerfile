# yotta-compiler — Docker-based yotta compiler for micro:bit local builds
#
# Replaces the deprecated pext/yotta image. Used by PXT when
# PXT_FORCE_LOCAL=1 is set during `pxt build` for projects
# with native C++ code.
#
# Published to GitHub Container Registry:
#   ghcr.io/league-microbit/yotta-compiler:latest

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Build toolchain: ARM cross-compiler, yotta, and dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip git build-essential cmake ninja-build srecord \
    gcc-arm-none-eabi binutils-arm-none-eabi \
    wget curl sudo python3-dev libssl-dev libffi-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install yotta

ENV CC=arm-none-eabi-gcc
ENV CXX=arm-none-eabi-g++

# Build user — PXT runs yotta as this user inside the container
RUN useradd -m -s /bin/bash build && \
    echo "build ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER build
WORKDIR /src

RUN sudo ln -sf /usr/bin/python3 /usr/bin/python

CMD ["python3", "build.py"]