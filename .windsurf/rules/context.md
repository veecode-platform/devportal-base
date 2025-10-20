---
trigger: manual
---

# Project Context

## Quick Reference

**Project**: Backstage-based Developer Portal (DevPortal Base)  
**Architecture**: Monorepo with Yarn workspaces  
**Backstage Version**: 1.44.1+  
**Node.js**: 18+  
**Package Manager**: Yarn 4.10.3 Berry

## Technology Stack

### Core

- **Backstage**: v1.44.1+ (developer portal framework)
- **React**: 18.x
- **TypeScript**: 5.x
- **Node.js**: 22+
- **Express**: Backend server

### UI & Styling

- **MUI**: v5.18.0 with v4 compatibility layer (`@mui/styles`)
- **Theme**: Backstage UnifiedThemeProvider
- **Icons**: @mui/icons-material

### Build & Tooling

- **Yarn**: 4.10.3 Berry
- **Lerna**: Multi-package management
- **Turbo**: Build orchestration
- **ESLint**: Code linting
- **Prettier**: Code formatting
- **Playwright**: E2E testing

### Dynamic Plugins

- **Scalprum**: Webpack Module Federation
- **@scalprum/react-core**: React integration
- Supports both hardcoded and runtime-loaded plugins

## Project Structure

```
/packages/          # Core application
  /app/            # Frontend React app
  /backend/        # Backend Node.js server
  /plugin-utils/   # Shared utilities

/plugins/          # Custom plugins
  /about/          # About page plugin
  /dynamic-plugins-info/  # Dynamic plugins UI

/dynamic-plugins/  # Dynamic plugin infrastructure
  /downloads/      # External plugin downloads
  /wrappers/       # Dynamic plugin wrappers

/dynamic-plugins-root/  # Runtime plugin directory
/examples/         # Catalog entity examples
/docs/            # Project documentation
```

## Key Files

- `app-config.yaml` - Base Backstage configuration
- `app-config.production.yaml` - Production overrides (ignore it for now, not maintained)
- `app-config.local.yaml` - Local development overrides (gitignored, may contain secrets)
- `package.json` - Root workspace configuration
- `lerna.json` - Lerna settings
- `turbo.json` - Build pipeline
- `rbac-policy.csv` - Backstage RBAC permissions

## Current State

### MUI Migration

- **Status**: Partial migration to v5
- Using `@mui/styles` for v4 compatibility
- Gradual migration to `styled()` or `sx` prop
- Fixed: TablePagination values, dark mode fonts

### Plugin System

- Static plugins: Compiled into main bundle
- Hardcoded dynamic: Configured in `baseFrontendConfig.ts`
- Runtime dynamic: Loaded from `dynamic-plugins-root/`

### Known Issues

- TablePagination must use: 5, 10, 20, 50, 100
- Dark mode font colors fixed in Backstage 1.44.1+
- Dynamic plugins need valid `plugin-manifest.json`

## Important Patterns

### Plugin Loading

1. **Static**: Import in App.tsx
2. **Hardcoded Dynamic**: Configure in `ScalprumRoot/baseFrontendConfig.ts`
3. **Runtime Dynamic**: Place in `dynamic-plugins-root/`

### Styling Approach

- Use MUI v5 components from `@mui/material`
- Legacy: `makeStyles` from `@mui/styles`
- New code: `sx` prop or `styled()`
- Theme via `useTheme()` hook

### Route Management

- Main routes in `packages/app/src/components/AppBase/AppBase.tsx`
- Dynamic routes via Scalprum
- Type-safe navigation with route refs

## Common Tasks

### Start Development

```bash
yarn install
yarn dev  # Starts frontend + backend
```

### Run Tests

```bash
yarn test           # All tests
yarn test --watch   # Watch mode
yarn e2e           # E2E tests
```

## Documentation

For detailed information, see:

- `/docs/MONOREPO_STRUCTURE.md` - Workspace structure
- `/docs/BACKSTAGE_ARCHITECTURE.md` - Architecture details
- `/docs/PLUGINS.md` - Plugin system
- `/docs/DYNAMIC_PLUGINS_ARCHITECTURE.md` - Plugin system
- `/docs/MUI_MIGRATION_STATUS.md` - MUI migration tracking
- `/docs/DEVELOPMENT_GUIDE.md` - Development workflows
- `/docs/CONFIGURATION_GUIDE.md` - Configuration reference
- `/docs/PROJECT_CONTEXT.md` - Full project context
- `/docs/RBAC.md` - RBAC permissions

## External Resources

- Backstage Docs: https://backstage.io/docs
- MUI Migration: https://mui.com/material-ui/migration/migration-v4/
- Scalprum: https://scalprum.github.io/
