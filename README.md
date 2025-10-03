# DevPortal base image

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

VeeCode DevPortal is an open-source [Backstage](https://backstage.io) distro meant to be ready to use in production from day 1.

This repo is a work in progress meant to rationalize and accelerate DevPortal release process.

The resulting base image must:

- be a very lightweight container image with a minimal DevPortal runtime and a fast start time
- define the mechanics for loading plugins dynamically
- bundle all the required static plugins
- define the mechanics for bundling dynamic plugins (i.e. preinstalled plugins)
- bundle a minimal set of preinstalled plugins (homepage and global header)
- bundle a default configuration for all preinstalled plugins
- have good defaults (starts with none or minimal config)

Derived images are expected to:

- embed all preinstalled plugins for a self-sufficient distro
- embed a default configuration for all preinstalled plugins

## Local development

### Copy app-config examples

Some app-config examples are provided in the `app-config.local.template.yaml` and `app-config.dynamic-plugins.local.template.yaml` files. You can copy them to their proper places and edit them at will.

```sh
cp app-config.local.template.yaml app-config.local.yaml
cp app-config.dynamic-plugins.local.template.yaml app-config.dynamic-plugins.local.yaml
```

**Note:** The target files are gitignored to prevent team conflicts, so you can modify them freely.

### Build code

To build and start the app, run:

```sh
yarn install
yarn build
# may fail until you build required preinstalled plugins (see below)
LOG_LEVEL=debug yarn dev-local
```

### Build preinstalled plugins

All preinstalled plugins are defined in `dynamic-plugins/wrappers` and `dynamic-plugins/downloads` directories:

- **Wrappers**: Compatibility layer that exports dynamic plugins from pre-existing static plugins (backend or frontend)
- **Downloads**: Native dynamic plugins that don't require wrappers - just add them to `dynamic-plugins/downloads/plugins.json`

To build all preinstalled plugins:

```sh
cd dynamic-plugins/
yarn install
yarn build
yarn export-dynamic
yarn copy-dynamic-plugins $(pwd)/../dynamic-plugins-root
```

**Note:** You only need to do this once. The output is generated in `dynamic-plugins-root` directory and loaded by the dynamic loader at runtime. Wrapper plugins are built, exported and copied; downloaded plugins are unpacked and copied.

When running `yarn dev-local`, the dynamic loader will load all plugins from the `dynamic-plugins-root` directory.

### Build container image

Please read [docker/README.md](docker/README.md) for instructions on how to build the container image.

## Understanding plugins

### Static plugins

Static plugins are compiled directly into the application bundle and cannot be loaded dynamically. The base image includes only essential static plugins that provide core functionality required by all dynamic plugins.

Derived images should not add more static plugins. We maintain a minimal set restricted to foundational features:

**Core static plugins:**

| Type     | Plugin | Purpose |
| :------- | :------| :-------|
| Both     | Notifications | Delivers messages to users about events that occur in the platform. |
| Both     | Signals | A lower-level pub/sub infrastructure for event-like communication between Backstage plugins/services. |
| Backend  | Permissions | Defines and enforces fine-grained access control rules across the platform. |
| Frontend | Permissions-React | React components for access control rules in the frontend. |
| Both     | RBAC | Role-based access control for the platform. |

### Dynamic plugins

Dynamic plugins "autowire" themselves to Backstage at runtime without requiring code changes or rebuilds. This removes friction from experimenting with new plugins and is a key component for DevPortal's extensibility and adaptability.

**Loading methods:**

- Downloaded from OCI registries
- Downloaded from NPM repositories
- Loaded from local filesystem ("preinstalled plugins")

The most common approach for production deployments is embedding plugins in the distro image as preinstalled plugins.

### Preinstalled plugins

Preinstalled plugins are dynamic plugins embedded in the distro image but not necessarily loaded at runtime. This approach provides:

- **Self-sufficient distribution** - Works out of the box without external dependencies
- **Flexible deployment** - Enable only the plugins you need
- **Smaller footprint** - Plugins are available but not all loaded by default

**Base image preinstalled plugins:**

- **VeeCode Homepage** - Customizable landing page
- **VeeCode Global Header** - Unified navigation and branding
- **Tech Radar** - Technology adoption visualization (frontend + backend)
- **Tech Docs** - Documentation system (frontend + backend)

### Design philosophy

**Base image:** Contains only the minimal set of plugins required for core functionality and a working out-of-the-box experience.

**Derived images:** Embed additional dynamic plugins to create a comprehensive, self-sufficient distribution tailored for specific use cases.

## Development tips

### Local Development

The steps described above ([Build code](#build-code) and [Build preinstalled plugins](#build-preinstalled-plugins)) are meant for local development. The Dockerfile will take care of running similar steps to build the DevPortal base image.

### Adding new preinstalled plugins

#### For native dynamic plugins

If the plugin is already available as a dynamic package:

1. Add it to `dynamic-plugins/downloads/plugins.json`
2. Run the [Build preinstalled plugins](#build-preinstalled-plugins) commands

#### For legacy static plugins

For older plugins that need a compatibility wrapper:

##### Option 1: Use the helper script (experimental)

```sh
yarn new-wrapper @backstage-community/plugin-tech-radar@1.7.0
```

Then run the [Build preinstalled plugins](#build-preinstalled-plugins) commands.

⚠️ **Warning:** This script is highly experimental. It creates the necessary files and directories for both backend and frontend plugins, but use at your own risk.

##### Option 2: Copy from RHDH (recommended)

Borrow existing wrappers from the [RHDH repository](https://github.com/redhat-developer/rhdh/tree/main/dynamic-plugins/wrappers):

1. Find the wrapper you need
2. Copy it to `dynamic-plugins/wrappers`
3. Run the [Build preinstalled plugins](#build-preinstalled-plugins) commands

### Relaxing security for local development

For local development, you can simplify authentication by:

- Using a fixed backend token
- Enabling the guest auth provider with an assumed identity

⚠️ **Warning:** Only use this configuration in local development environments.

Create or edit `app-config.local.yaml` with:

```yaml
# Backstage override configuration for your local development environment
backend:
  auth:
    secret: mysecret
    #dangerouslyDisableDefaultAuthPolicy: true

auth:
  # see https://backstage.io/docs/auth/ to learn about auth providers
  providers:
    # See https://backstage.io/docs/auth/guest/provider
    guest:
      userEntityRef: user:default/admin
      ownershipEntityRefs: [group:default/admins]
      dangerouslyAllowOutsideDevelopment: true
```

### Accessing backend endpoints

**Default ports:**

- Frontend: `http://localhost:3000`
- Backend: `http://localhost:7007`

Backend API endpoints require authentication. The examples below show how to obtain and use a token (requires the relaxed security configuration above):

```sh
# get a Backstage user token via the guest provider
USER_TOKEN="$(curl -s -X POST http://localhost:7007/api/auth/guest/refresh \
  -H 'Content-Type: application/json' -d '{}' | jq -r '.backstageIdentity.token')"

# list loaded dynamic plugins
curl -H "Authorization: Bearer $USER_TOKEN" \
  http://localhost:7007/api/dynamic-plugins-info/loaded-plugins

# list catalog components
curl -H "Authorization: Bearer $USER_TOKEN" \
  http://localhost:7007/api/catalog/entities\?filter\=kind\=Component

# healthcheck (no auth)
curl -vvv http://localhost:7007/healthcheck

# version (no auth)
curl -vvv http://localhost:7007/version
```

## Additional Notes

### Relationship to RHDH

Many code patterns and mechanics in this project are inspired by [Red Hat Developer Hub (RHDH)](https://github.com/redhat-developer/rhdh).

**Important:** VeeCode DevPortal is **not** a fork of RHDH. It is an independent open-source project that leverages proven patterns from RHDH to deliver a production-ready Backstage distribution.

### Temporary fix for better-sqlite3

A root import for `better-sqlite3` has been added to define it globally in package resolutions.

⚠️ **Known issue:** A symbolic link must be manually created to resolve a runtime issue (under investigation):

```sh
cd node_modules/better-sqlite3/build
ln -s Release/better_sqlite3.node better_sqlite3.node
```

## License

Copyright (c) 2025-2026 by Vertigo Tecnologia (VeeCode controller). Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
