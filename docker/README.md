# Docker Build Guide

This document explains how to build VeeCode DevPortal container images for both development and production.

We have two different Dockerfiles:

- `Dockerfile-dev`: used for development purposes only
- `Dockerfile`: used for image release

## Development Docker Image

### Purpose

This is a helper tool to experiment building images for development purposes under OSX or Windows WSL, by forcing a build under Linux AMD/ARM using containers. This also allows building in a host without Node.js tools.

It is defined by the `Dockerfile-dev` file and exposes the same ports of running locally (3000 and 7007).

### Prerequisites

- Docker
- Docker Compose plugin
- Verdaccio (local npm registry)

### Workflow

Run the `docker-dev.sh` script from the project root path to start a "hanging" container, then use the same script to get into it and start as many builds as you need.

```bash
./docker-dev.sh build
./docker-dev.sh up
./docker-dev.sh shell
```

### What It Does

The Dockerfile performs these steps:

- Copies all the `package.json` files into an image layer
- Installs dependencies for workspaces
- Copies the rest of the project code

### Verdaccio Setup

Verdaccio is a local npm registry that can be used to publish and install packages. Start it locally with:

```bash
verdaccio -l 0.0.0.0:4873
```

The commands in `docker-dev.sh` script will use this registry.

## Production Docker Image

A definitive multiplatform image is built and published on Docker Hub from the CI/CD pipeline. It is defined by the `Dockerfile` file and exposes a single port (the backend port, 7007).

### Build Process

The production build:

- Creates a lightweight container image with minimal DevPortal runtime
- Bundles all required static plugins
- Includes preinstalled dynamic plugins
- Provides fast start time and good defaults
- Uses caching to speed up builds

### Image Characteristics

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

- Embed all preinstalled plugins for a self-sufficient distro
- Embed default configuration for all preinstalled plugins
