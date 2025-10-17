# Project Context for AI Assistants

## Project Overview

This is a **Backstage-based developer portal** (DevPortal Base) using a monorepo structure with Yarn workspaces. It implements both static and dynamic plugin loading, follows RHDH (Red Hat Developer Hub) patterns, and is currently migrating from Material-UI v4 to v5.

## Technology Stack

### Core Technologies

- **Backstage**: v1.44.1+ (developer portal framework)
- **React**: 18.x (frontend framework)
- **Node.js**: 18+ (backend runtime)
- **TypeScript**: 5.x (type safety)
- **Express**: Backend server
- **Yarn**: 4.10.3 Berry (package manager)
- **Lerna**: Multi-package management
- **Turbo**: Build orchestration

### UI Framework

- **Material-UI (MUI)**: v5 with v4 compatibility layer
- **@mui/material**: ^5.18.0 (core components)
- **@mui/icons-material**: ^5.18.0 (icons)
- **@mui/styles**: ^5.18.0 (v4 makeStyles compatibility)

### Dynamic Plugin System

- **Scalprum**: Webpack Module Federation for runtime plugin loading
- **@scalprum/react-core**: React integration
- Supports both hardcoded and runtime-loaded plugins

## Project Structure

### Monorepo Layout

```text
/packages/          # Core application packages
  /app/            # Frontend React application
  /backend/        # Backend Node.js server
  /plugin-utils/   # Shared utilities

/plugins/          # Custom Backstage plugins
  /about/          # About page plugin
  /about-backend/  # About backend
  /dynamic-plugins-info/         # Dynamic plugins UI
  /dynamic-plugins-info-backend/ # Dynamic plugins API

/dynamic-plugins/  # Dynamic plugin infrastructure
  /downloads/      # External plugin downloads
  /scripts/        # Plugin tooling
  /wrappers/       # Dynamic plugin wrappers

/dynamic-plugins-root/  # Runtime plugin directory

/examples/         # Catalog entity examples
/docs/            # Project documentation
```

### Key Configuration Files

- `app-config.yaml` - Base Backstage configuration
- `app-config.production.yaml` - Production overrides
- `app-config.local.yaml` - Local development (gitignored)
- `package.json` - Root workspace configuration
- `lerna.json` - Lerna settings
- `turbo.json` - Build pipeline
- `rbac-policy.csv` - RBAC permissions

## Important Architectural Patterns

### Plugin Loading

1. **Static Plugins**: Compiled into main bundle, imported in App.tsx
2. **Hardcoded Dynamic Plugins**: Configured in `ScalprumRoot/baseFrontendConfig.ts`
3. **Runtime Dynamic Plugins**: Loaded from `dynamic-plugins-root/` folder

### Styling Approach

- Using MUI v5 components from `@mui/material`
- Compatibility layer via `@mui/styles` for legacy `makeStyles`
- Gradual migration to `styled()` or `sx` prop
- Theme via Backstage's `UnifiedThemeProvider`

### Route Management

- Main routes in `packages/app/src/components/AppBase/AppBase.tsx`
- Dynamic routes loaded via Scalprum
- Type-safe navigation using route refs

## Known Issues & Fixes

### MUI Migration

- **Status**: Partial migration to v5
- **Compatibility**: Using @mui/styles for makeStyles
- **Fixed**: TablePagination values (must be 5, 10, 20, 50, 100)
- **Fixed**: Dark mode font colors (Backstage 1.44.1+)

### Dynamic Plugins

- Plugins must have valid `plugin-manifest.json`
- Scalprum name must match configuration
- Backend scans `dynamic-plugins-root/` for plugins
- Frontend loads via Webpack Module Federation

## Development Workflow

### Common Commands

```bash
yarn install          # Install dependencies
yarn build           # Build all packages
yarn dev-local             # Start dev servers (frontend + backend)
yarn test            # Run tests
yarn lint            # Lint code
yarn tsc             # Type check
```

### Plugin Development

We should create plugins in dedicated repos.

```bash
yarn backstage-cli create-plugin           # Create new plugin
cd plugins/my-plugin && yarn start         # Develop standalone
```

### Dynamic Plugin Development

```bash
cd dynamic-plugins && yarn new-wrapper     # Create wrapper
yarn build && yarn copy-plugins            # Build and deploy
```

## Code Patterns to Follow

### Import Patterns

```typescript
// MUI v5 imports
import { Button, Typography } from '@mui/material';
import { makeStyles } from '@mui/styles';  // v4 compatibility
import AddIcon from '@mui/icons-material/Add';

// Backstage imports
import { useApi, configApiRef } from '@backstage/core-plugin-api';
import { Content, Header, Page } from '@backstage/core-components';
```

### Plugin Definition Pattern

```typescript
import { createPlugin, createRoutableExtension } from '@backstage/core-plugin-api';

export const myPlugin = createPlugin({
  id: 'my-plugin',
  routes: { root: rootRouteRef },
});

export const MyPage = myPlugin.provide(
  createRoutableExtension({
    name: 'MyPage',
    component: () => import('./components/MyPage').then(m => m.MyPage),
    mountPoint: rootRouteRef,
  }),
);
```

### Styling Pattern (Current)

```typescript
// Using makeStyles (v4 compatibility)
import { makeStyles } from '@mui/styles';

const useStyles = makeStyles((theme) => ({
  root: {
    padding: theme.spacing(2),
    backgroundColor: theme.palette.background.paper,
  },
}));

const MyComponent = () => {
  const classes = useStyles();
  return <div className={classes.root}>Content</div>;
};
```

### Styling Pattern (Target)

```typescript
// Using sx prop (v5 native)
const MyComponent = () => {
  return (
    <Box sx={{ p: 2, bgcolor: 'background.paper' }}>
      Content
    </Box>
  );
};
```

## Testing Patterns

### Component Testing

```typescript
import { renderInTestApp } from '@backstage/test-utils';

describe('MyComponent', () => {
  it('renders correctly', async () => {
    const { getByText } = await renderInTestApp(<MyComponent />);
    expect(getByText('Hello')).toBeInTheDocument();
  });
});
```

### E2E Testing

```typescript
import { test, expect } from '@playwright/test';

test('navigate to page', async ({ page }) => {
  await page.goto('http://localhost:3000');
  await page.click('text=My Page');
  await expect(page).toHaveURL(/.*my-page/);
});
```

## Security & Best Practices

### Configuration

- Never commit secrets to git
- Use environment variables for sensitive data
- Use `app-config.local.yaml` for local secrets (gitignored)
- Validate configuration with `yarn backstage-cli config:check`

### Code Quality

- Follow ESLint rules
- Use TypeScript strictly (no `any` without justification)
- Write tests for new features
- Keep plugins focused and single-purpose

### Performance

- Lazy load heavy components
- Use React.memo for expensive renders
- Implement proper loading states
- Monitor bundle size

## Troubleshooting Guide

### Common Issues

**Black text on dark background**:

- Fixed in Backstage 1.44.1+
- Alternative: Use `StyledEngineProvider` with `injectFirst`

**Plugin not loading**:
- Check `plugin-manifest.json` exists and is valid
- Verify Scalprum configuration matches
- Check browser console for errors
- Ensure plugin is in `dynamic-plugins-root/`

**Build failures**:
- Clear `.turbo` cache: `rm -rf .turbo`
- Remove node_modules: `rm -rf node_modules && yarn install`
- Check TypeScript errors: `yarn tsc`

**Type errors**:
- Regenerate types: `yarn tsc --build --clean && yarn tsc`
- Check for version mismatches in dependencies

## Documentation References

### Internal Documentation

- `docs/MONOREPO_STRUCTURE.md` - Workspace structure
- `docs/BACKSTAGE_ARCHITECTURE.md` - Architecture details
- `docs/DYNAMIC_PLUGINS_ARCHITECTURE.md` - Plugin system
- `docs/MUI_MIGRATION_STATUS.md` - MUI migration tracking
- `docs/DEVELOPMENT_GUIDE.md` - Development workflows
- `docs/CONFIGURATION_GUIDE.md` - Configuration reference
- `docs/PLUGINS.md` - Plugin development
- `docs/RBAC.md` - Access control
- `docs/DOCKER_DEVELOPMENT.md` - Docker setup

### External Resources

- Backstage Docs: https://backstage.io/docs
- MUI Migration: https://mui.com/material-ui/migration/migration-v4/
- Scalprum: https://scalprum.github.io/

## AI Assistant Guidelines

When working with this codebase:

1. **Check documentation first**: Review relevant docs in `/docs` before making changes
2. **Follow patterns**: Use existing patterns for plugins, styling, and testing
3. **Respect migration status**: Use @mui/styles for makeStyles until fully migrated
4. **Validate changes**: Run `yarn tsc` and `yarn lint` before committing
5. **Test thoroughly**: Write tests and verify in both light and dark modes
6. **Update documentation**: Keep docs current when changing behavior
7. **Consider dynamic plugins**: Prefer dynamic plugins for new features when appropriate
8. **Security first**: Never commit secrets, use environment variables
9. **Performance matters**: Consider bundle size and lazy loading
10. **Ask when uncertain**: Request clarification rather than guessing

## Version Information

### Current Versions

- Backstage: 1.44.1+
- React: 18.x
- MUI: 5.18.0
- Node.js: 18+
- Yarn: 4.10.3
- TypeScript: 5.x

### Migration Status

- ✅ Backstage 1.44.1 (dark mode fix)
- ⚠️ MUI v5 (partial - using compatibility layer)
- ✅ Dynamic plugins (Scalprum integrated)
- ✅ Yarn 4 Berry (PnP disabled)

## Contact & Support

For questions or issues:

1. Check `/docs` directory
2. Review existing code patterns
3. Search Backstage documentation
4. Ask team members
