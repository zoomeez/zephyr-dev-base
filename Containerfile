FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
ARG ZEPHYR_REVISION=v4.4.2
ARG ZEPHYR_SDK_VERSION=1.0.1
ARG ZEPHYR_SDK_TOOLCHAINS="arm-zephyr-eabi riscv64-zephyr-elf x86_64-zephyr-elf"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ccache \
        cmake \
        device-tree-compiler \
        dfu-util \
        file \
        gcc \
        gdb \
        git \
        gperf \
        libmagic1 \
        libsdl2-dev \
        make \
        ninja-build \
        python3-dev \
        python3-tk \
        python3-venv \
        wget \
        xz-utils \
    && if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
        apt-get install -y --no-install-recommends gcc-multilib g++-multilib; \
    fi \
    && python3 -m venv /opt/zephyr-venv \
    && /opt/zephyr-venv/bin/pip install --no-cache-dir --upgrade pip west \
    && install -d -o vscode -g vscode /opt/zephyrproject "/opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}" \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/zephyr-venv/bin:${PATH}"
ENV ZEPHYR_BASE=/opt/zephyrproject/zephyr
ENV ZEPHYR_TOOLCHAIN_VARIANT=zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-1.0.1

USER vscode

RUN west init \
        -m https://github.com/zephyrproject-rtos/zephyr \
        --mr "${ZEPHYR_REVISION}" \
        /opt/zephyrproject \
    && cd /opt/zephyrproject \
    && west update \
    && west packages pip --install \
    && west blobs fetch --auto-accept hal_espressif \
    && west zephyr-export \
    && cd /opt/zephyrproject/zephyr \
    && read -r -a toolchains <<< "${ZEPHYR_SDK_TOOLCHAINS}" \
    && west sdk install \
        --version "${ZEPHYR_SDK_VERSION}" \
        --install-dir "/opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}" \
        --toolchains "${toolchains[@]}"

WORKDIR /workspaces

LABEL org.opencontainers.image.source="https://github.com/zoomeez/zephyr-dev-base"
LABEL org.opencontainers.image.description="Pinned, reusable Zephyr development base"
