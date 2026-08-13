# Zephyr development base

A reproducible, multi-architecture OCI base image containing Zephyr, its modules, Python dependencies, binary blobs, and selected Zephyr SDK toolchains.

The image is intended to be the immutable lower layer for many application devcontainers:

```text
ghcr.io/zoomeez/zephyr-dev-base:4.4.2
├── Ubuntu 24.04 development tools
├── Zephyr v4.4.2 at /opt/zephyrproject
├── west and Zephyr Python packages
├── Espressif HAL blobs
└── Zephyr SDK 1.0.1
    ├── arm-zephyr-eabi
    ├── riscv64-zephyr-elf
    └── x86_64-zephyr-elf
```

The image build fetches Espressif HAL blobs with Zephyr's non-interactive license-acceptance flag. Review the blob licenses from the pinned Zephyr/module revisions before distributing or consuming the image in an environment with additional licensing requirements.

Container image layers are content-addressed and immutable. Projects based on the same image reuse those layers instead of maintaining separate `west update` results or SDK installations. Each running container receives a small writable overlay; application sources and build output should live in separate writable mounts.

## Use

```dockerfile
FROM ghcr.io/zoomeez/zephyr-dev-base:4.4.2

# Add only project-specific tools here.
```

The image exports:

```text
ZEPHYR_BASE=/opt/zephyrproject/zephyr
ZEPHYR_TOOLCHAIN_VARIANT=zephyr
ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-1.0.1
```

Build an out-of-tree application from any writable directory:

```sh
west build \
  -s /workspaces/my-project/app \
  -d /workspaces/.build/my-project \
  -b xiao_esp32c3/esp32c3
```

`west build` finds Zephyr extension commands through `ZEPHYR_BASE`; an application does not need to be inside `/opt/zephyrproject`.

## Build locally

```sh
podman build \
  -f Containerfile \
  -t zephyr-dev-base:4.4.2 \
  .
```

Override pins explicitly when testing a new release:

```sh
podman build \
  --build-arg ZEPHYR_REVISION=v4.4.2 \
  --build-arg ZEPHYR_SDK_VERSION=1.0.1 \
  -t zephyr-dev-base:test \
  .
```

## Publishing

The GitHub Actions workflow builds `linux/amd64` and `linux/arm64` images and publishes them to:

```text
ghcr.io/zoomeez/zephyr-dev-base:4.4.2
ghcr.io/zoomeez/zephyr-dev-base:latest
```

Tags beginning with `v` also produce a matching OCI tag.

## Versioning policy

- Pin `ZEPHYR_REVISION` to a release tag or immutable commit, never `main`.
- Pin the Zephyr SDK version.
- Update the explicit numeric image tag when either pin changes.
- Preserve older image tags so projects can upgrade independently.

## When not to use this image

This layout is optimized for application development. If a project modifies Zephyr itself or one of its west modules, use a writable Zephyr checkout instead of editing `/opt/zephyrproject` in a container overlay.
