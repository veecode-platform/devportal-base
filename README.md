# DevPortal Base Image

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
![Backstage](https://img.shields.io/badge/Backstage-Latest-9BF0E1?logo=backstage)
![Docker](https://img.shields.io/badge/docker-TBD-blue?logo=docker)

VeeCode DevPortal is an open-source [Backstage](https://backstage.io) distribution designed to be production-ready from day one.

This repository provides a lightweight and extensible Backstage distribution with:

- **Minimal runtime footprint** with fast startup
- **Dynamic plugin loading** for flexibility and extensibility
- **Essential static plugins** for core functionality
- **Preinstalled plugins** ready to enable
- **Good defaults** requiring minimal configuration (or none at all)

The repository is structured for local development with a Node runtime, but it also helps running containerized builds and helps building a definitive and production-ready container image.

## Quick Links

There are a few sections for later reading if you want some deeper understanding of this project:

- **[Plugin Architecture & Management](PLUGINS.md)** - Understanding and working with plugins
- **[Docker Development](DOCKER_DEVELOPMENT.md)** - Explains the current container development options
- **[Local Docker Build Guide](docker/README.md)** - Building container images locally for development

## Local development

### Copy app-config examples

Some app-config examples are provided in the `app-config.local.template.yaml` and `app-config.dynamic-plugins.local.template.yaml` files. You can copy them to their proper places and edit them at will.

```sh
cp app-config.local.template.yaml app-config.local.yaml
cp app-config.dynamic-plugins.local.template.yaml app-config.dynamic-plugins.local.yaml
```

**Note:** The target files are gitignored to prevent team conflicts, so you can modify them freely.

### Build and run

**Step 1: Build preinstalled plugins** (see [PLUGINS.md](PLUGINS.md) for details):

This step isnt exactly a build itself, but it prepares pre-built plugins for dynamic loading under DevPortal. It deals with native dynamic plugins and with wrappers around older plugins, exporting them as ready-to-load dynamic plugins under a `dynamic-plugins-root` directory:

```sh
cd dynamic-plugins/
yarn install
yarn build
yarn export-dynamic
yarn copy-dynamic-plugins $(pwd)/../dynamic-plugins-root
```

You can read [Plugin Architecture & Management](PLUGINS.md) for more details.

**Step 2: Build and start the application**:

```sh
yarn install
yarn build
# change log level at will
LOG_LEVEL=debug yarn dev-local
```

**Default ports:**

- Frontend: `http://localhost:3000`
- Backend: `http://localhost:7007`

## Development Tips

### Relaxing Security for Local Development

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

### Accessing Backend Endpoints

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

# send notification
# token defined by "backend.auth.externalAccess[0].options.token"
NOTIFY_TOKEN="test-token"
curl -X POST http://localhost:7007/api/notifications/notifications \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $NOTIFY_TOKEN" \
  -d '{
        "recipients": {
          "type": "broadcast"
        },
        "payload": {
          "title": "Title of broadcast message",
          "description": "The description of the message.",
          "link": "http://example.com/link",
          "severity": "high",
          "topic": "general"
        }
      }'
```

## Additional Notes

### Relationship to RHDH

Many code patterns and mechanics in this project are inspired by [Red Hat Developer Hub (RHDH)](https://github.com/redhat-developer/rhdh). Some files have been copied or adapted from RHDH, both manually and with AI assistance, in accordance with its open-source license. We include attribution notices in files derived from RHDH where required. If you find any missing attributions, please let us know so we can correct them.

**Important:** VeeCode DevPortal is **not** a fork of RHDH. It is an independent open-source project that leverages proven patterns and code from RHDH to deliver a production-ready Backstage distribution.

### Temporary fix for better-sqlite3

A root import for `better-sqlite3` has been added to define it globally in package resolutions.

⚠️ **Known issue:** you may need to create a symbolic link to resolve a runtime issue (under investigation):

```sh
cd node_modules/better-sqlite3/build
ln -s Release/better_sqlite3.node better_sqlite3.node
```

## License

Check the [LICENSE](LICENSE) file for details. Yes, we are full open source and we welcome contributions.
