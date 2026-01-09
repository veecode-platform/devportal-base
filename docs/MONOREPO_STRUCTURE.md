# Monorepo Structure & Workspaces

## Overview

This is a Backstage-based monorepo using **Yarn Workspaces** and **Lerna** for package management. The project is organized into multiple packages and plugins that work together to create a developer portal.

## Package Manager

- **Yarn 4.10.3** (Berry) - Modern Yarn with PnP support
- **Lerna** - Multi-package repository management
- **Turbo** - Build system orchestration

## Workspace Structure

### `/packages/*` - Core Application Packages

Main application packages that form the foundation of the portal:

- **`packages/app/`** - Frontend React application

  - Main Backstage UI application
  - Entry point: `src/App.tsx`
  - Routing configuration in `src/components/AppBase/`
  - Uses MUI v5 with v4 compatibility layer (@mui/styles)
  - Includes Scalprum for dynamic plugin loading

- **`packages/backend/`** - Backend Node.js application

  - Express-based backend server
  - Plugin backend integrations
  - API endpoints and services

- **`packages/plugin-utils/`** - Shared utilities
  - Common utilities used across plugins
  - Shared types and helpers

### `/plugins/*` - Custom Plugins

Custom Backstage plugins developed for this portal:

- **`plugins/about/`** - About page plugin (frontend)

  - Displays portal information
  - Uses MUI v5 with @mui/styles compatibility

- **`plugins/about-backend/`** - About plugin backend

  - Backend services for about page

- **`plugins/dynamic-plugins-info/`** - Dynamic plugins information page

  - Frontend plugin to display loaded dynamic plugins
  - Route: `/extensions`
  - Uses MUI v5 (fully migrated)

- **`plugins/dynamic-plugins-info-backend/`** - Dynamic plugins backend
  - API to retrieve dynamic plugin information
  - Scans `dynamic-plugins-root/` folder

### `/dynamic-plugins/*` - Dynamic Plugin System

Infrastructure for loading plugins dynamically at runtime:

- **`dynamic-plugins/downloads/`** - Plugin download scripts

  - `download-packages.sh` - Downloads external plugins
  - `plugins.json` - Configuration of plugins to download

- **`dynamic-plugins/scripts/`** - Plugin development tools

  - `new-wrapper.mjs` - Creates new dynamic plugin wrappers

- **`dynamic-plugins/_utils/`** - Shared utilities for dynamic plugins
  - `copy-plugins.js` - Copies plugins to runtime location

### `/dynamic-plugins-root/` - Runtime Plugin Directory

Directory where dynamic plugins are loaded from at runtime. Plugins are copied here during build/startup.

### `/examples/*` - Example Catalog Entities

Sample YAML files for Backstage catalog:

- `entities.yaml` - Component entities
- `apis.yaml` - API entities
- `clusters.yaml` - Kubernetes cluster entities
- `template/` - Software templates

### `/docs/*` - Documentation

Project documentation:

- `DYNAMIC_PLUGIN_TRANSLATIONS.md` - Dynamic plugin translation guide
- `PLUGINS.md` - Plugin development guide
- `RBAC.md` - Role-based access control

### `/auth-examples/*` - Authentication Examples

Example configurations for different auth providers:

- `github/` - GitHub OAuth setup examples

## Key Configuration Files

### Root Level

- **`package.json`** - Root package with workspace definitions
- **`lerna.json`** - Lerna configuration for multi-package management
- **`turbo.json`** - Turbo build pipeline configuration
- **`yarn.lock`** - Dependency lock file
- **`.yarnrc.yml`** - Yarn 4 configuration
- **`tsconfig.json`** - Root TypeScript configuration

### Backstage Configuration

- **`app-config.yaml`** - Main Backstage configuration
- **`app-config.production.yaml`** - Production overrides
- **`app-config.local.template.yaml`** - Local development template
- **`app-config.dynamic-plugins.local.template.yaml`** - Dynamic plugins local config
- **`backstage.json`** - Backstage version and metadata
- **`catalog-info.yaml`** - Self-registration in catalog

### Build & Deploy

- **`Makefile`** - Build automation commands
- **`docker-compose.yml`** - Local development with Docker

### Code Quality

- **`.eslintrc.js`** - ESLint configuration
- **`.prettierignore`** - Prettier ignore patterns
- **`playwright.config.ts`** - E2E test configuration

### Security & Access

- **`rbac-policy.csv`** - RBAC permissions configuration

## Workspace Dependencies

### Internal Dependencies

Packages can depend on each other using workspace protocol:

```json
{
  "dependencies": {
    "@internal/plugin-utils": "workspace:^"
  }
}
```

### External Dependencies

- **@backstage/\*** - Core Backstage packages
- **@mui/material** - Material-UI v5 (migrated from v4)
- **@mui/styles** - MUI v4 compatibility layer
- **@scalprum/react-core** - Dynamic plugin loading
- **React 18** - Frontend framework

## Build & Development Commands

### Common Commands

```bash
# Install dependencies
yarn install

# Start development server
yarn dev

# Build all packages
yarn build

# Run tests
yarn test

# Lint code
yarn lint

# Type check
yarn tsc
```

### Lerna Commands

```bash
# Run command in all packages
yarn lerna run <command>

# Run command in specific package
yarn lerna run <command> --scope=<package-name>

# Bootstrap packages
yarn lerna bootstrap
```

## Migration Notes

### MUI v4 → v5 Migration Status

- ✅ **dynamic-plugins-info** - Fully migrated to MUI v5
- ⚠️ **about plugin** - Using MUI v5 with @mui/styles compatibility
- ⚠️ **app package** - Using MUI v5 with @mui/styles compatibility
- 📝 **Compatibility layer** - @mui/styles provides v4 makeStyles support

### Backstage Version

- Currently on **Backstage 1.44.1+**
- Includes fix for dark mode font color issues

## Dynamic Plugin Architecture

### Static Plugin Loading (Hardcoded)

Plugins can be hardcoded in `packages/app/src/components/ScalprumRoot/baseFrontendConfig.ts`:

```typescript
export const baseFrontendConfig = {
  dynamicPlugins: {
    frontend: {
      'internal.plugin-dynamic-plugins-info': {
        dynamicRoutes: [
          {
            path: '/extensions',
            importName: 'DynamicPluginsInfoPage',
            menuItem: { text: 'Extensions' },
          },
        ],
      },
    },
  },
};
```

### Dynamic Plugin Loading (Runtime)

Plugins in `dynamic-plugins-root/` are automatically discovered and loaded at runtime using Scalprum.

## Important Patterns

### Plugin Development

1. Create plugin in `/plugins/<plugin-name>/`
2. Add to workspace in root `package.json`
3. Export from plugin's `src/index.ts`
4. Import in app's `packages/app/src/App.tsx`

### Dynamic Plugin Development

1. Create wrapper in `/dynamic-plugins/wrappers/<plugin-name>/`
2. Configure in `dynamic-plugins/downloads/plugins.json`
3. Build and copy to `dynamic-plugins-root/`

### Styling

- Use MUI v5 components from `@mui/material`
- For v4 compatibility, use `makeStyles` from `@mui/styles`
- Theme available via `useTheme()` hook

## Troubleshooting

### Common Issues

1. **Black text on dark background** - Fixed in Backstage 1.44.1+
2. **TablePagination errors** - Use valid rowsPerPage values: 5, 10, 20, 50, 100
3. **Dynamic plugins not loading** - Check `dynamic-plugins-root/` folder and backend logs
4. **Build errors** - Run `yarn install` and clear `.turbo` cache

### Useful Debug Commands

```bash
# Check workspace structure
yarn workspaces list

# Verify dependencies
yarn why <package-name>

# Clean build artifacts
rm -rf node_modules/.cache
rm -rf .turbo
```
