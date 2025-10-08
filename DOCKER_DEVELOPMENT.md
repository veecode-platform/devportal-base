# Docker Development Setup

This guide helps you set up and use Docker for developing the DevPortal Base project.

## Understand the builds

### Local development build

This is the process explained in [Local Docker Build Guide](docker/README.md), where we just use the docker-compose file to build and run the containers *not meant for production use*, but just as an alternative to the local development process.

Just follow the referenced guide for more details.

### Production release build

This is the process that releases the official VeeCode Devportal base container image to Docker Hub. It is an automated build that runs in Github Actions, as defined in the [publish.yml](.github/workflows/publish.yml) file.

This pipeline publishes a new multiplatform image (amd/arm linux) on [VeeCode Base Image](https://hub.docker.com/r/veecode/devportal-base) repository at Docker Hub.

This image itself is defined by the [Dockerfile](packages/backend/Dockerfile) file and exposes a single port (the backend port, 7007).

## Production builds

### Build Process

The production build:

- Creates a lightweight container image with minimal DevPortal runtime
- Bundles all required static plugins
- Includes preinstalled dynamic plugins
- Provides fast start time and good defaults
- Uses caching to speed up builds

### Base Image Characteristics

The resulting base image:

- Very lightweight with minimal runtime footprint
- Defines mechanics for loading plugins dynamically
- Bundles all required static plugins
- Includes mechanics for bundling dynamic plugins (preinstalled plugins)
- Contains a minimal set of preinstalled plugins (homepage and global header)
- Provides default configuration for all preinstalled plugins
- Starts with none or minimal configuration required

### Derived Images

Derived images are expected to:

- Embed more preinstalled plugins for a self-sufficient distro
- Embed default configuration for all preinstalled plugins
