# Local Docker Build Guide

This document explains how to build VeeCode DevPortal container images for local development.

We use a single [Dockerfile-dev](Dockerfile-dev) file to build DevPortal locally even without a local Node.js environment.

**This is not the Dockerfile used to build the production image.**. A definitive multiplatform image is built and published on Docker Hub from the CI/CD pipeline. It is defined by the [Dockerfile](packages/backend/Dockerfile) file and exposes a single port (the backend port, 7007).

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

From this shell you can run the same yarn commands you would run in a local environment.

When you are done, just discard it:

```bash
./docker-dev.sh down
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

## Tips

To find out the latest Red Hat Node.js version, run:

```bash
skopeo list-tags docker://registry.redhat.io/ubi9/nodejs-22 \
  | jq -r '.Tags[]
           | select(startswith("9.6-"))
           | select(endswith("-source") | not)' \
  | sort -V \
  | tail -n 1
```

## Integration with Existing Workflow

This Docker setup is designed to work alongside your existing development workflow:

- All your existing `yarn` commands work inside the container
- The Makefile commands can be run inside the container
- Dynamic plugins development is fully supported
