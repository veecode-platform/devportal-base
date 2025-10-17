# Backstage Architecture Guide

## Overview

This document explains the Backstage architecture as implemented in this developer portal, including core concepts, plugin system, and customizations.

## Core Architecture

### Frontend Architecture

#### Main Application (`packages/app/`)

```text
packages/app/
├── src/
│   ├── App.tsx                    # Main app component
│   ├── index.tsx                  # Entry point
│   ├── components/
│   │   ├── AppBase/               # Base app configuration
│   │   │   ├── AppBase.tsx        # Routes and providers
│   │   │   └── AppRouter.tsx      # Route definitions
│   │   ├── Root/                  # Root layout component
│   │   ├── ScalprumRoot/          # Dynamic plugin loader
│   │   │   ├── ScalprumRoot.tsx   # Scalprum provider
│   │   │   ├── DynamicRoot.tsx    # Dynamic route builder
│   │   │   └── baseFrontendConfig.ts # Hardcoded plugins
│   │   └── catalog/               # Catalog customizations
│   └── apis.ts                    # API implementations
```

**Key Components:**

- **App.tsx** - Wraps entire app with providers (theme, alerts, APIs)
- **AppBase.tsx** - Defines core routes and page layouts
- **ScalprumRoot** - Loads dynamic plugins using Scalprum
- **Root** - Sidebar navigation and layout structure

#### Component Hierarchy

```text
index.tsx
  └── App (providers, theme, APIs)
      └── ScalprumRoot (dynamic plugin loader)
          └── AppBase (routes, pages)
              └── AppRouter (route matching)
                  └── Page Components
```

### Backend Architecture

#### Backend Application (`packages/backend/`)

```text
packages/backend/
├── src/
│   ├── index.ts                   # Entry point
│   ├── plugins/                   # Plugin backend integrations
│   │   ├── catalog.ts             # Catalog backend
│   │   ├── search.ts              # Search backend
│   │   └── ...                    # Other plugin backends
│   └── types.ts                   # Type definitions
```

**Backend Structure:**

- Express.js server
- Plugin-based architecture
- Each plugin registers routes and services
- Middleware for auth, logging, CORS

## Plugin System

### Plugin Types

#### 1. Frontend Plugins

Located in `/plugins/<plugin-name>/`:

```text
plugins/about/
├── src/
│   ├── plugin.ts                  # Plugin definition
│   ├── components/                # React components
│   │   └── DefaultAboutPage/
│   ├── routes.ts                  # Route references
│   └── index.ts                   # Public exports
├── dev/
│   └── index.tsx                  # Standalone dev environment
└── package.json
```

**Plugin Definition Pattern:**

```typescript
// plugin.ts
import { createPlugin, createRoutableExtension } from '@backstage/core-plugin-api';

export const aboutPlugin = createPlugin({
  id: 'about',
  routes: {
    root: rootRouteRef,
  },
});

export const AboutPage = aboutPlugin.provide(
  createRoutableExtension({
    name: 'AboutPage',
    component: () => import('./components/DefaultAboutPage').then(m => m.DefaultAboutPage),
    mountPoint: rootRouteRef,
  }),
);
```

#### 2. Backend Plugins

Located in `/plugins/<plugin-name>-backend/`:

```text
plugins/about-backend/
├── src/
│   ├── plugin.ts                  # Plugin registration
│   ├── service/                   # Business logic
│   └── router.ts                  # Express routes
└── package.json
```

**Backend Plugin Pattern:**

```typescript
// plugin.ts
import { createBackendPlugin } from '@backstage/backend-plugin-api';

export const aboutPlugin = createBackendPlugin({
  pluginId: 'about',
  register(env) {
    env.registerInit({
      deps: {
        http: coreServices.httpRouter,
        logger: coreServices.logger,
      },
      async init({ http, logger }) {
        http.use(await createRouter({ logger }));
      },
    });
  },
});
```

#### 3. Dynamic Plugins

Loaded at runtime from `/dynamic-plugins-root/`:

**Structure:**

```text
dynamic-plugins-root/
└── <plugin-name>/
    ├── dist/
    │   └── scalprum/              # Webpack federated modules
    ├── package.json
    └── plugin-manifest.json       # Plugin metadata
```

**Plugin Manifest:**

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "scalprum": {
    "name": "plugin.name",
    "exposedModules": {
      "PluginRoot": "./dist/scalprum/plugin.chunk.js"
    }
  }
}
```

### Plugin Integration

#### Static Integration (Compile-time)

Add to `packages/app/src/App.tsx`:

```typescript
import { AboutPage } from '@internal/plugin-about';

// In AppBase.tsx
<Route path="/about" element={<AboutPage />} />
```

#### Dynamic Integration (Runtime)

Configure in `ScalprumRoot/baseFrontendConfig.ts`:

```typescript
export const baseFrontendConfig = {
  dynamicPlugins: {
    frontend: {
      'internal.plugin-name': {
        dynamicRoutes: [{
          path: '/route',
          importName: 'ComponentName',
          menuItem: { text: 'Menu Label' }
        }],
        mountPoints: [{
          mountPoint: 'entity.page.overview/cards',
          importName: 'EntityCard',
          config: { layout: { gridColumnEnd: { lg: 'span 6' } } }
        }]
      }
    }
  }
};
```

## Routing System

### Route References

Backstage uses route references for type-safe navigation:

```typescript
// routes.ts
import { createRouteRef } from '@backstage/core-plugin-api';

export const rootRouteRef = createRouteRef({
  id: 'about',
});

// Usage in component
import { useRouteRef } from '@backstage/core-plugin-api';
import { rootRouteRef } from '../../routes';

const MyComponent = () => {
  const aboutRoute = useRouteRef(rootRouteRef);
  return <Link to={aboutRoute()}>About</Link>;
};
```

### Dynamic Routes

Loaded via Scalprum from plugin manifests:

- Routes registered in `dynamicRoutes` array
- Automatically added to app router
- Support for nested routes and parameters

## Extension Points & Mount Points

### Common Mount Points

- **`entity.page.overview/cards`** - Entity overview cards
- **`entity.page.*/context`** - Entity page context menu
- **`search.page.filters`** - Search page filters
- **`settings.page.*/cards`** - Settings page sections
- **`internal.plugins/tab`** - Plugin content tabs

### Creating Mount Points

```typescript
// In plugin
export const myMountPoint = createExtensionPoint({
  id: 'my-plugin.mount-point',
});

// In app
<ExtensionSlot id="my-plugin.mount-point" />
```

## API System

### API Definitions (`packages/app/src/apis.ts`)

```typescript
import { createApiFactory, discoveryApiRef } from '@backstage/core-plugin-api';

export const apis: AnyApiFactory[] = [
  createApiFactory({
    api: discoveryApiRef,
    deps: {},
    factory: () => {
      return {
        async getBaseUrl(pluginId: string) {
          return `${window.location.origin}/api/${pluginId}`;
        },
      };
    },
  }),
  // More API factories...
];
```

### Using APIs in Components

```typescript
import { useApi, discoveryApiRef } from '@backstage/core-plugin-api';

const MyComponent = () => {
  const discoveryApi = useApi(discoveryApiRef);
  
  useEffect(() => {
    const fetchData = async () => {
      const baseUrl = await discoveryApi.getBaseUrl('my-plugin');
      const response = await fetch(`${baseUrl}/data`);
      // ...
    };
    fetchData();
  }, [discoveryApi]);
};
```

## Catalog System

### Entity Model
Backstage uses a YAML-based entity model:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-service
  description: My service description
  annotations:
    backstage.io/source-location: url:https://github.com/org/repo
spec:
  type: service
  lifecycle: production
  owner: team-name
  system: my-system
```

### Entity Kinds

- **Component** - Software components (services, libraries, websites)
- **API** - API definitions (OpenAPI, GraphQL, gRPC)
- **Resource** - Infrastructure resources (databases, S3 buckets)
- **System** - Collection of components and resources
- **Domain** - Business domain grouping
- **Group** - Team or organizational unit
- **User** - Individual user
- **Template** - Software templates for scaffolding

### Catalog Providers

Backend plugins that discover and ingest entities:

- **File Provider** - Local YAML files
- **GitHub Provider** - GitHub repositories
- **GitLab Provider** - GitLab projects
- **URL Provider** - Remote YAML files

## Theme System

### Theme Configuration (`packages/app/src/App.tsx`)
```typescript
import { UnifiedThemeProvider } from '@backstage/theme';
import { themes } from '@backstage/theme';

const app = createApp({
  themes: [{
    id: 'light',
    title: 'Light Theme',
    variant: 'light',
    Provider: ({ children }) => (
      <UnifiedThemeProvider theme={themes.light}>
        {children}
      </UnifiedThemeProvider>
    ),
  }],
});
```

### Custom Theme
```typescript
import { createUnifiedTheme } from '@backstage/theme';

const myTheme = createUnifiedTheme({
  palette: {
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
  },
  fontFamily: 'Inter, sans-serif',
});
```

## Authentication & Authorization

### Authentication Flow

1. User clicks login
2. Redirected to auth provider (GitHub, Google, etc.)
3. Provider callback with token
4. Token stored in session
5. Token included in API requests

### RBAC (Role-Based Access Control)
Configured in `rbac-policy.csv`:
```csv
p, role:default/team-a, catalog-entity, read, allow
p, role:default/team-a, catalog-entity, update, allow
g, user:default/john, role:default/team-a
```

**Permission Checks:**
```typescript
import { usePermission } from '@backstage/plugin-permission-react';
import { catalogEntityReadPermission } from '@backstage/plugin-catalog-common';

const { allowed } = usePermission({
  permission: catalogEntityReadPermission,
  resourceRef: entityRef,
});
```

## Configuration System

### Configuration Files

- **`app-config.yaml`** - Base configuration
- **`app-config.production.yaml`** - Production overrides
- **`app-config.local.yaml`** - Local development (gitignored)

### Configuration Structure
```yaml
app:
  title: Developer Portal
  baseUrl: http://localhost:3000

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
  database:
    client: pg
    connection:
      host: localhost
      port: 5432

catalog:
  locations:
    - type: file
      target: ./examples/entities.yaml
```

### Reading Configuration
```typescript
import { useApi, configApiRef } from '@backstage/core-plugin-api';

const config = useApi(configApiRef);
const appTitle = config.getString('app.title');
```

## Search System

### Search Architecture

1. **Collators** - Collect documents from sources (catalog, techdocs)
2. **Decorators** - Enrich documents with metadata
3. **Search Engine** - Index and query (Elasticsearch, Postgres, Lunr)
4. **Frontend** - Search UI components

### Search Integration
```typescript
// Backend
import { CatalogCollatorFactory } from '@backstage/plugin-catalog-backend';

// Frontend
import { SearchPage } from '@backstage/plugin-search';
import { CatalogSearchResultListItem } from '@backstage/plugin-catalog';

<SearchPage>
  <SearchResult>
    <CatalogSearchResultListItem />
  </SearchResult>
</SearchPage>
```

## Build & Bundle System

### Webpack Configuration

Backstage uses custom Webpack configuration:

- **Module Federation** - For dynamic plugins (Scalprum)
- **Code Splitting** - Lazy loading of routes
- **Asset Optimization** - Minification, tree-shaking

### Build Process

1. TypeScript compilation (`tsc`)
2. Webpack bundling
3. Asset copying
4. Plugin manifest generation

### Development Mode

- Hot Module Replacement (HMR)
- Fast refresh for React components
- Source maps for debugging

## Testing Strategy

### Unit Tests
```typescript
import { renderInTestApp } from '@backstage/test-utils';

describe('MyComponent', () => {
  it('renders correctly', async () => {
    const { getByText } = await renderInTestApp(<MyComponent />);
    expect(getByText('Hello')).toBeInTheDocument();
  });
});
```

### E2E Tests (Playwright)
```typescript
import { test, expect } from '@playwright/test';

test('navigate to about page', async ({ page }) => {
  await page.goto('http://localhost:3000');
  await page.click('text=About');
  await expect(page).toHaveURL(/.*about/);
});
```

## Performance Considerations

### Code Splitting

- Route-based splitting
- Component lazy loading
- Dynamic imports for heavy dependencies

### Caching

- Service Worker for offline support
- API response caching
- Static asset caching

### Bundle Size

- Tree-shaking unused code
- Dynamic plugin loading
- Lazy loading of non-critical features

## Troubleshooting

### Common Issues

**Plugin not loading:**

- Check plugin manifest in `dynamic-plugins-root/`
- Verify Scalprum configuration
- Check browser console for errors

**API errors:**

- Verify backend is running
- Check CORS configuration
- Validate API endpoints in discovery API

**Build failures:**

- Clear `.turbo` cache
- Remove `node_modules` and reinstall
- Check TypeScript errors

**Theme issues:**

- Verify MUI version compatibility
- Check CSS injection order (StyledEngineProvider)
- Validate theme configuration

## Best Practices

### Plugin Development

1. Keep plugins focused and single-purpose
2. Use route refs for navigation
3. Implement proper error boundaries
4. Follow Backstage naming conventions
5. Document plugin configuration

### Performance

1. Lazy load heavy components
2. Use React.memo for expensive renders
3. Implement proper loading states
4. Optimize bundle size

### Security

1. Validate all user inputs
2. Use RBAC for authorization
3. Sanitize displayed data
4. Keep dependencies updated
5. Follow OWASP guidelines

### Maintainability

1. Write comprehensive tests
2. Document complex logic
3. Use TypeScript strictly
4. Follow consistent code style
5. Keep plugins decoupled
