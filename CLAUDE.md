# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this repository.

## Project Overview

VeeCode DevPortal is an open-source Backstage distribution designed for production use. It provides a minimal, extensible foundation with dynamic plugin loading capabilities. This is **not** a fork of RHDH but draws inspiration and patterns from Red Hat Developer Hub.

**Key characteristics:**

- Yarn 4 monorepo with workspaces (always try to use the same yarn version, latest stable)
- Frontend app: packages/app folder
- Backend app: packages/backend folder
- Internal static plugins: plugins/\* folders
- Static plugins: the ones imported in packages.json (backend plugins in Backend app, frontend plugins in Frontend app)
- Dynamic plugin architecture replicated from RHDH
- Dynamic plugin architecture replicated from RHDH (using Scalprum)
- Node.js 20 or above required

## Understanding the codebase

- docs/adr/ - Architecture Decision Records (ADRs) explaining why decisions were made
- docs/UPGRADING.md - How to upgrade Backstage, Node.js base image, and dependencies
- docs/ROADMAP_FEATURES.md - Planned features and product evolution
- docs/ROADMAP_BACKLOG.md - Technical debt, skipped tests, and outdated documentation
- docs/BACKSTAGE_ARCHITECTURE.md - Core Backstage architecture, frontend/backend components, and plugin system
- docs/CONFIGURATION_GUIDE.md - YAML-based configuration hierarchy and core settings (outdated)
- docs/DEVELOPMENT_GUIDE.md - Getting started, prerequisites, and development workflow (outdated)
- docs/DOCKER_DEVELOPMENT.md - Docker setup for local development and production builds (outdated)
- docs/DYNAMIC_PLUGINS_ARCHITECTURE.md - Scalprum-based dynamic plugin system (outdated)
- docs/DYNAMIC_PLUGIN_TRANSLATIONS.md - Internationalization for dynamic plugin menu items
- docs/MONOREPO_STRUCTURE.md - Yarn workspaces, package management, and repository organization (outdated)
- docs/MUI_MIGRATION_STATUS.md - Material-UI v4 to v5 migration progress and compatibility layer (outdated)
- docs/PLUGINS.md - Static vs dynamic plugins, core plugin list, and plugin architecture
- docs/PROJECT_CONTEXT.md - Technology stack, architecture overview, and AI assistant guidance (outdated)
- docs/RBAC.md - Role-based access control configuration and policies

## Known Issues

Testing coverage is low due to migration to DevPortal Base repository. See Testing Strategy below.

## Common Commands

### Initial Setup

```bash
make full && yarn check-dynamic-plugins   # Or: yarn init-local
```

### Development

```bash
yarn dev-local                            # Start with local config (app-config.local.yaml)
yarn dev                                  # Start with base config only
LOG_LEVEL=debug yarn dev-local            # With debug logging
yarn debug-local                          # With Node.js inspector enabled
```

### Building

```bash
yarn build                                # Build all packages (turbo)
yarn build:backend                        # Build backend only
yarn tsc                                  # TypeScript check all packages
```

### Testing

```bash
yarn test                                 # Run tests (turbo)
yarn test:all                             # Run all tests with coverage
yarn test:e2e                             # Run Playwright e2e tests
```

### Linting

```bash
yarn lint:check                           # Check linting (turbo)
yarn lint:fix                             # Fix linting issues (turbo)
yarn prettier:check                       # Check formatting
```

### Single Package Operations

```bash
yarn workspace backend test               # Test backend package
yarn workspace app build                  # Build app package
yarn workspace @internal/plugin-dynamic-plugins-info test
```

### Dynamic Plugins

```bash
cd dynamic-plugins/
yarn install && yarn build && yarn export-dynamic
yarn copy-dynamic-plugins $(pwd)/../dynamic-plugins-root
```

## Architecture

### Monorepo Structure

```pre
packages/
  app/           # Frontend application (Scalprum-based dynamic shell)
  backend/       # Backend server with static plugins
  plugin-utils/  # Shared utilities

plugins/         # Internal plugins (workspace packages)
  dynamic-plugins-info/          # Frontend plugin for viewing loaded plugins
  dynamic-plugins-info-backend/  # Backend API for plugin info
  scalprum-backend/              # Backend support for dynamic frontend loading

dynamic-plugins/                 # Build workspace for preinstalled plugins
  wrappers/      # Compatibility wrappers for legacy static plugins
  downloads/     # Native dynamic plugins (defined in plugins.json)
  _utils/        # Build utilities

dynamic-plugins-root/            # Runtime directory for loaded dynamic plugins
```

### Plugin Types

1. **Static Plugins**: Compiled into the application bundle (backend: auth providers, catalog, scaffolder, permissions, RBAC; frontend: minimal core)

2. **Dynamic Plugins**: Loaded at runtime from `dynamic-plugins-root/` directory

   - **Preinstalled**: Baked into image, optionally enabled via config
   - **Downloaded**: Fetched from registries at startup

3. **Internal Plugins** (`@internal/*`): Workspace packages in `plugins/` directory

### Frontend Architecture

The frontend uses Scalprum for dynamic plugin loading instead of standard Backstage routing. Key files:

- `packages/app/src/App.tsx` - Root component with ScalprumRoot
- `packages/app/src/components/DynamicRoot/` - Dynamic plugin mounting infrastructure
- `packages/app/src/apis.ts` - API factories

Dynamic plugins builds (frontend or backend) use `janus-cli` or its more recent version `rhdh-cli`.

### Backend Architecture

The backend (`packages/backend/src/index.ts`) initializes:

1. Default service factories with custom logging
2. Dynamic plugin feature loader with custom module resolution for wrapper packages
3. Static plugins (catalog, auth, scaffolder, permissions, search, etc.)
4. Internal plugins (dynamic-plugins-info-backend, scalprum-backend)

### Configuration Files

- `app-config.yaml` - Base configuration (guest auth, local SQLite)
- `app-config.dynamic-plugins.yaml` - Dynamic plugin configurations
- `app-config.local.yaml` - Local overrides (gitignored, for secrets)
- `app-config.github.yaml` - GitHub auth profile
- `app-config.keycloak.yaml` - Keycloak auth profile
- `app-config.azure.yaml` - Azure AD auth profile
- `app-config.production.yaml` - Container/production paths

**Profile selection** via `VEECODE_PROFILE` env var: `github`, `keycloak`, `azure`, `local`

## Tech Docs Setup

For local TechDocs generation:

```bash
python3 -m venv $(pwd)/venv
source venv/bin/activate
pip install -r python/requirements.txt
```

Keep the venv activated when running DevPortal.

## Default Ports

- Frontend: `http://localhost:3000`
- Backend: `http://localhost:7007`

## Testing Backend APIs

This is very important: testing backend APIs directly is an excellent way to investigate issues and to build automated backend tests.

```bash
# Get user token via guest auth
USER_TOKEN="$(curl -s -X POST http://localhost:7007/api/auth/guest/refresh \
  -H 'Content-Type: application/json' -d '{}' | jq -r '.backstageIdentity.token')"

# Use token for API calls
curl -H "Authorization: Bearer $USER_TOKEN" http://localhost:7007/api/catalog/entities
```

## Testing Strategy

**Principle: Test as you go, don't stop to backfill.**

Testing improves organically alongside feature work. No dedicated "testing sprints" that block delivery.

### Rules for when to write tests

| Situation | Action |
|-----------|--------|
| Writing new code | Add unit test |
| Fixing a bug | Add regression test |
| Refactoring old code | Add test first |
| Just reading/using old code | Leave it alone |

### Priority areas (when you have time)

1. **Backend APIs** - Easy to test, high value
2. **Internal plugins** (`plugins/*`) - Isolated, testable units
3. **Shared utilities** (`packages/plugin-utils`)

### Skip for now

- Complex frontend component tests (DynamicRoot, Scalprum integration)
- E2E tests (high maintenance cost)

### CI enforcement

- PR checks run `yarn test` - prevents new regressions
- Pre-commit hooks catch issues early
