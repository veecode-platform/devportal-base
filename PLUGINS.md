# DevPortal Plugins

This document explains the plugin architecture and how to work with plugins in VeeCode DevPortal.

## Understanding Plugins

### Static Plugins

Static plugins are compiled directly into the application bundle and will not be loaded dynamically. The base image includes only essential static plugins that provide core functionality required by basic operation and by the dynamic plugins who rely on them.

Derived images should not add more static plugins. Derived images will just add a set of dynamic plugins to the base image, composing a production-ready and competitive distribution.

We maintain a minimal set restricted to foundational features in the base image.

**Core static plugins:**

The core set of static plugins is defined in the base image. It provides core functionality required by basic operation and by the dynamic plugins who rely on them.

| Type     | Plugin | Purpose |
| :------- | :------| :-------|
| Both     | Notifications | Delivers messages to users about events that occur in the platform. |
| Both     | Signals | A pub/sub infrastructure for event-like communication between Backstage plugins/services. |
| Backend  | Permissions | Defines and enforces fine-grained access control rules across the platform. |
| Frontend | Permissions-React | React components for access control rules in the frontend. |
| Backend  | RBAC | Role-based access control for the platform. |
| Backend  | Github Auth | Github Authentication for the platform. |

Note: we may attempt to remove the auth plugins from static loading into dynamic loading in the future.

### Dynamic Plugins

Dynamic plugins "autowire" themselves to Backstage at runtime without requiring code changes or rebuilds. This removes friction from experimenting with new plugins and is a key component for DevPortal's extensibility and adaptability.

**Loading methods:**

- Downloaded from OCI registries
- Downloaded from NPM repositories
- Loaded from local filesystem ("preinstalled plugins")

The most common approach for production deployments is embedding plugins in the distro image as preinstalled plugins.

### Preinstalled Plugins

Preinstalled plugins are dynamic plugins embedded in the distro image but not necessarily loaded at runtime. This approach provides:

- **Self-sufficient distribution** - Works out of the box without external dependencies
- **Flexible deployment** - Enable only the plugins you need
- **Smaller footprint** - Plugins are available but not all loaded by default

**Base image preinstalled plugins:**

- **VeeCode Homepage** - Customizable landing page
- **VeeCode Global Header** - Unified navigation and branding
- **Tech Radar** - Technology adoption visualization (frontend + backend)
- **Tech Docs** - Documentation system (frontend + backend)

### Design Philosophy

**Base image:** Contains only the minimal set of plugins required for core functionality and a working out-of-the-box experience.

**Derived images:** Embed additional dynamic plugins to create a comprehensive, self-sufficient DevPortal distribution tailored for specific use cases.

## Building Preinstalled Plugins

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

When running DevPortal, the dynamic loader will load all plugins from the `dynamic-plugins-root` directory.

## Adding New Preinstalled Plugins

### For Native Dynamic Plugins

If the plugin is already available as a dynamic package:

1. Add it to `dynamic-plugins/downloads/plugins.json`
2. Run the [Build preinstalled plugins](#building-preinstalled-plugins) commands

### For Legacy Static Plugins

For older plugins that need a compatibility wrapper:

#### Option 1: Use the Helper Script (Experimental)

```sh
yarn new-wrapper @backstage-community/plugin-tech-radar@1.7.0
```

Then run the [Build preinstalled plugins](#building-preinstalled-plugins) commands.

⚠️ **Warning:** This script is highly experimental. It creates the necessary files and directories for both backend and frontend plugins, but use at your own risk.

#### Option 2: Copy from RHDH (Recommended)

Borrow existing wrappers from the [RHDH repository](https://github.com/redhat-developer/rhdh/tree/main/dynamic-plugins/wrappers):

1. Find the wrapper you need
2. Copy it to `dynamic-plugins/wrappers`
3. Run the [Build preinstalled plugins](#building-preinstalled-plugins) commands
