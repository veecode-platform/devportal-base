# DevPortal base image

VeeCode DevPortal is an open-source [Backstage](https://backstage.io) distro meant to be ready to use in production from day 1.

This repo is a work in progress meant to rationallize and accelerate DevPortal release process.

The resulting base image must:

- be a very lightweight container image with a minimal DevPortal runtime and a fast start time
- define the mechanics for loading plugins dynamically
- bundle all the static plugins
- bundle only the required dynamic plugins (homepage and global header)
- have good defaults (starts with none or minimal config)

Derived images are expected to:

- embed all preloaded plugins for a distro
- embed a default configuration for all preloaded plugins

## Build

To build and start the app, run:

```sh
yarn install
yarn start
```

## Static plugins

Derived images will not embed more static plugins, so all plugins that cannot be loaded dynamically must be embedded in the base image.

## Dynamic plugins (required)

Only the minimal amount of required plugins should be embedded in the base image, in order for it to work out of the box.

Derived images will embed all the dynamic plugins a generic and self-sufficient distro should have.

The list of required plugins is informed....

## Development tips

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
