# Release Cycle — Base Image

**Artifact:** `veecode/devportal-base:<version>` on Docker Hub

## Motivations

A base image release is justified by one or more of:

- **UBI base image update** — Red Hat publishes a new `ubi10/nodejs-22` tag
- **Backstage core update** — New Backstage release available
- **Base plugin fixes** — Fixes or updates to the few plugins embedded in the base

## Flow

1. Make changes on `main` (one or more motivations above)
2. Commit to `main`
3. Run `make release`

`make release` does:

- Generates release notes from commits since last tag → `CHANGELOG.md`
- Bumps patch version in `package.json`
- Commits, pushes to `main`, creates and pushes a git tag

The tag push triggers CI (`.github/workflows/publish.yml`), which:

- Validates tag matches `package.json` version and is on `main`
- Builds the full project (tsc, lint, test, build, dynamic plugins)
- Publishes multi-arch image (amd64 + arm64) to Docker Hub

## Common Commands by Motivation

| Motivation | Command |
|---|---|
| UBI base image | `./scripts/update-base-image.sh` (updates `FROM` in Dockerfile) |
| Backstage core | `yarn update-backstage` in root and `dynamic-plugins/` |
| Plugin fixes | `yarn up <plugin>@<version>` |

After any of these, update `packages/app/src/build-metadata.json` if versions changed.

## Available Skills (Claude Code)

| Skill | Purpose |
|---|---|
| `/upgrade-and-test` | Full Backstage upgrade with validation |
| `/update-base-image` | Update UBI Node.js base image |
| `/upgrade-static-plugins` | Check and upgrade static plugins |
| `/upgrade-dynamic-plugins` | Check and upgrade dynamic plugins |
| `/security-scan` | Scan image for vulnerabilities |

