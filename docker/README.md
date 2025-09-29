# VeeCode Base Developer Docker Image

This folder contains the Dockerfile for the VeeCode Base Docker Image.

You are expected to build this image locally using the `docker-dev.sh` script from the project root path.

## Purpose

This is a helper tool to experiment buiding images for development purposes under OSX or Windows WSL, by forcing a build under Linux AMD/ARM using containers. This also allows to build in a host without Node.js tools.

## Pre-requisites

- Docker
- Docker Compose plugin
- Verdaccio (local npm registry)

## Workflow

Just run the `docker-dev.sh` script from the project root path to start a "hanging" container, then use the same script to get into it and start as many build as you need.

```bash
./docker-dev.sh build
./docker-dev.sh up
./docker-dev.sh shell
```

## What it does

The Dockerfile does these steps:

- copies all the `package.json` files into an image layer
- installs dependencies for workspaces
- copies the rest of the project code

## Verdaccio

Verdaccio is a local npm registry that can be used to publish and install packages. Start it locally with:

```bash
verdaccio -l 0.0.0.0:4873
```

The commands in `docker-dev.sh` script will use this registry.

## Production Docker image

A definitive multiplatform image is built and published on Docker Hub from the CI/CD pipeline.
