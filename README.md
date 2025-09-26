# DevPortal base image

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

Some app-config examples are provided in the `app-config.local.template.yaml` and `app-config.dynamic-plugins.template.yaml` files. You can copy them to their proper places and edit them at will.

```sh
cp app-config.local.template.yaml app-config.local.yaml
cp app-config.dynamic-plugins.template.yaml ./dynamic-plugins-root/app-config.dynamic-plugins.yaml
```

Note: we gitignore the target files to prevent team conflicts, mess with them freely.

### Build code

To build and start the app, run:

```sh
yarn install
yarn build
# may fail until you build required preinstalled plugins (see below)
LOG_LEVEL=debug yarn dev-local
```

### Build preinstalled plugins

All preinstalled plugins are defined in `dynamic-plugins/wrappers` and `dynamic-plugins/downloads` directories. Each wrapper is a construct that exports a dynamic plugin from a pre-existing static plugin (backend or frontend), working as a compatibility layer for older plugins. Newer plugins are already dynamic plugins by themselves, so there is no need to create wrappers for them, just add them to `dynamic-plugins/downloads` list.

If you want to build all preinstalled plugins, run:

```sh
cd dynamic-plugins/
yarn install
yarn build
yarn export-dynamic
yarn copy-dynamic-plugins $(pwd)/../dynamic-plugins-root
```

Note: you only have to do this once - the output is generated in `dynamic-plugins-root` directory and picked by the dynamic loader at runtime when the app starts. Wrapper plugins are built, exported and copied, downloaded plugins are just copied and unpacked.

### Build container image

TODO

## Understanding plugins

### Static plugins

Derived images will not embed more static plugins, so all plugins that cannot be loaded dynamically must be embedded in this base image.

### Dynamic plugins

Dynamic plugin "autowire" themselves to Backstage at runtime, so you do not need extra coding to import them to DevPortal and a lot of friction is removed from the process of experimenting with new plugins.

Dynamic plugins can be loaded in many ways or even downloaded from the internet (OCI or NPM repositories), but a very common way is embedding them in the distro image.

### Preinstalled plugins

Preinstalled plugins are dynamic plugins that are embedded in the distro image but not necessarily loaded at runtime. Their intent is to provide a self-sufficient distro out of the box for many possible deployment scenarios, yet still requiring a smaller footprint than loading them all.

List of preinstalled plugins:

- VeeCode Homepage
- VeeCode Global Header
- Notifications (frontend and backend)
- Signals (frontend and backend)

### Motivation

Only the minimal amount of required plugins should be embedded in this base image, in order for it to work out of the box.

Derived images will embed all the dynamic plugins a generic and self-sufficient distro should have.

## Development tips

### Local Development

The steps described above ([Build code](#build-code) and [Build preinstalled plugins](#build-preinstalled-plugins)) are meant for local development. The Dockerfile will take care of running similar steps to build the DevPortal base image.

### Adding new preinstalled plugins

Adding new plugins that are already available as dynamic packages is simple: just add them to the `dynamic-plugins/downloads/plugins.json` file and repeat the [Build preinstalled plugins](#build-preinstalled-plugins) commands.

For older plugins that require a compatibility layer we created a helper script to ease the process of adding new preinstalled plugins. It will create the necessary files and directories and update the necessary configuration files and it understands both backend and frontend plugins.

Just invoke `yarn new-wrapper <plugin-name>` and repeat the [Build preinstalled plugins](#build-preinstalled-plugins) commands:

```sh
yarn new-wrapper @backstage-community/plugin-tech-radar@1.7.0
```

**IMPORTANT:** this is *highly* experimental yet, but beats doing it all manually. Use at your own risk.

Another **great** alternative for older plugins is to just shamelessly rip off the [equivalent wrappers that exist on RHDH repo](https://github.com/redhat-developer/rhdh/tree/main/dynamic-plugins/wrappers). Pick the ones you need and copy them to `dynamic-plugins/wrappers`.

### Relaxing security

You can relax a bit of security locally to:

- expose backend plugins endpoints with a fixed token
- disable authentication (guest provider) with an assumed identity

This can be done by creating a `app-config.local.yaml` file with the following content:

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

### Reaching backend endpoints

Backstage frontend is bound to port `3000` and backend to port `7007`. You can reach backend endpoints at `http://localhost:7007/api/`, but you will need a token to authenticate.

The snippet below shows how to get a token and use it to authenticate requests to the backend (assumes the relaxed configuration above):

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

### RHDH code mechanics

A lot of the code and mechanics here are based on [Red Hat Developer Hub (RHDH)](https://github.com/redhat-developer/rhdh) codebase.

VeeCode DevPortal is *not* a fork of RHDH though. It is an independent project that borrows some mechanics (and OSS code) from RHDH to achieve its goal: to be an OSS ready-to-use Backstage distro fit for production use.

### Temporary fix for better-sqlite3

We added a root import for `better-sqlite3` to define it globally in a resolution.

A symbolic must be manually created to solve a runtime issue still under investigation:

```sh
cd node_modules/better-sqlite3/build
ln -s Release/better_sqlite3.node better_sqlite3.node
```
