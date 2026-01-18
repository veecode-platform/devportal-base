# Upgrading Guide

This document covers the upgrade procedures for VeeCode DevPortal Base.

## About This Image

This is the **base image** - intentionally kept lightweight with a minimal plugin set. The **distro image** (derived from this) is where additional plugins are packaged. Keep this distinction in mind when upgrading.

## Automated Upgrade with Claude Code

If you're using [Claude Code](https://claude.ai/code), the `/upgrade-and-test` skill automates the Backstage upgrade process:

```text
/upgrade-and-test
```

This skill will:

1. Run `yarn update-backstage` in both main and dynamic-plugins workspaces
2. Update metadata files (`backstage.json`, `build-metadata.json`)
3. Run type checks, tests, and linting
4. Start the dev server and verify the UI loads correctly
5. Report any issues encountered during the upgrade

For manual upgrade procedures, continue reading below.

## Overview

Components that may need upgrading:

1. **Backstage Core** - The base Backstage framework packages
2. **Backstage Plugins** - Community and third-party plugins (independent release cycles)
3. **Node.js Base Image** - The UBI9 container image
4. **Dynamic Plugins** - Preinstalled plugins in dynamic-plugins/

## 1. Upgrading Backstage Core

The `yarn update-backstage` command upgrades all `@backstage/*` core packages to a known compatible state. This is the recommended way to upgrade.

### Check for Breaking Changes

Before upgrading, review the Backstage release notes:

- [Backstage Releases](https://github.com/backstage/backstage/releases)
- [Backstage Upgrade Helper](https://backstage.github.io/upgrade-helper/)

### Run the Upgrade

```bash
# Upgrade main workspace - updates all @backstage/* packages
yarn update-backstage

# Upgrade dynamic-plugins workspace
cd dynamic-plugins
yarn update-backstage
cd ..
```

### Update Metadata Files

After upgrading, update the version references:

1. **backstage.json** - Should be auto-updated, verify it:

   ```bash
   cat backstage.json
   ```

2. **packages/app/src/build-metadata.json** - Update the Backstage Version:

   ```json
   {
     "card": {
       "Backstage Version": "1.XX.X"
     }
   }
   ```

### Verify the Upgrade

```bash
yarn install
yarn tsc
yarn test
yarn dev-local
```

## 2. Upgrading Backstage Plugins

Plugins have their **own release cycles** independent of Backstage core. They must be updated separately and checked for compatibility.

### Check for Plugin Updates

Periodically check for new releases of plugins you use:

- [Backstage Community Plugins](https://github.com/backstage/community-plugins)
- Individual plugin repositories and changelogs

### Update Individual Plugins

```bash
# Check current versions
yarn info @backstage-community/plugin-rbac

# Update specific plugin
yarn up @backstage-community/plugin-rbac@latest

# Or update to a specific version
yarn up @backstage-community/plugin-rbac@1.47.0
```

### Verify Plugin Compatibility

After updating plugins:

1. Check plugin changelog for breaking changes
2. Verify compatibility with your Backstage core version
3. Test the plugin functionality locally

## 3. Upgrading Node.js Base Image

The production Dockerfile uses Red Hat UBI9 Node.js images from `registry.redhat.io/ubi9/nodejs-22`.

> **Claude Code users:** Run `/update-base-image` to automate the steps below.

### Find the Latest Image Tag

```bash
skopeo list-tags docker://registry.redhat.io/ubi9/nodejs-22 \
  | jq -r '.Tags[]
           | select(startswith("9.7-"))
           | select(endswith("-source") | not)' \
  | sort -V \
  | tail -n 1
```

This returns the latest stable tag (e.g., `9.7-1765878606`).

### Update Dockerfile

**Automated (recommended):**

```bash
./scripts/update-base-image.sh
```

This script fetches the latest tag, updates the Dockerfile, and rebuilds the image.

**Manual:**

Update `packages/backend/Dockerfile`:

```dockerfile
FROM registry.redhat.io/ubi9/nodejs-22:9.7-XXXXXXXXXX
```

### Verify the Image

```bash
# Build the image locally
./scripts/build-local-image.sh --quick

# Verify it runs
docker run --rm veecode/devportal-base:latest node --version
```

## 4. Upgrading Dynamic Plugins

Dynamic plugins in `dynamic-plugins/` are preinstalled in the base image.

### Rebuild Preinstalled Plugins

```bash
cd dynamic-plugins
yarn install
yarn build
yarn export-dynamic
yarn copy-dynamic-plugins ../dynamic-plugins-root
```

### Update Plugin Versions

Edit `dynamic-plugins/package.json` to update plugin versions, then rebuild.

## 5. Post-Upgrade Checklist

After any upgrade:

- Run `yarn install` to update lockfile
- Run `yarn tsc` to check for type errors
- Run `yarn test` to verify tests pass
- Run `yarn lint:check` to verify code style
- Start the app locally (`yarn dev-local`) and test manually
- Update `packages/app/src/build-metadata.json` if versions changed
- Update CHANGELOG if significant changes

### Security Scanning

After building a new Docker image, scan it for vulnerabilities:

```bash
# Using Trivy directly
trivy image veecode/devportal-base:latest
```

> **Claude Code users:** Run `/security-scan` to scan the image and generate reports. If vulnerabilities are found, run `/fix-vulnerabilities` to remediate actionable issues.

## Troubleshooting

### Yarn Resolution Conflicts

If you encounter peer dependency conflicts:

```bash
# Check for resolution issues
yarn explain peer-requirements

# Add resolutions to package.json if needed
```

### Breaking Changes in Plugins

If a plugin breaks after upgrade:

1. Check the plugin's changelog
2. Look for migration guides
3. Consider pinning to a previous version temporarily

### Docker Build Failures

If the Docker build fails after base image upgrade:

1. Check if system packages changed (dnf install commands)
2. Verify Python version compatibility
3. Check Node.js native module compatibility (better-sqlite3, isolate-vm)

## Version Compatibility Matrix

| DevPortal Base | Backstage | Node.js | UBI Base Image |
| -------------- | --------- | ------- | -------------- |
| 1.1.x          | 1.46.x    | 22.x    | ubi9/nodejs-22 |

Update this table when major versions change.
