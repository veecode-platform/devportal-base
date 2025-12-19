# Upgrading

This document shows the steps to upgrade VeeCode Platform to the latest base Backstage version.

## Upgrade Backstage

To upgrade base Backstage version:

```bash
yarn update-backstage
cd dynamic-plugins
yarn update-backstage
```

Please check breaking changes before upgrading.

## Update VeeCode Metadata

Steps:

- Update `backstage.json` version
- Update `packages/app/src/build-metadata.json` version

This is yet to be automated in the pipelina.
