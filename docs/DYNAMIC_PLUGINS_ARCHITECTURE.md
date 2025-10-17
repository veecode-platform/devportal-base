# Dynamic Plugins Architecture

## Overview
This portal implements a dynamic plugin system using **Scalprum** (Webpack Module Federation) that allows plugins to be loaded at runtime without rebuilding the application. This follows Red Hat Developer Hub (RHDH) patterns.

## Architecture Components

### 1. Scalprum Integration (`packages/app/src/components/ScalprumRoot/`)

#### ScalprumRoot.tsx

Main wrapper that initializes the Scalprum provider:

```typescript
import { ScalprumProvider } from '@scalprum/react-core';

export const ScalprumRoot = ({ children }) => {
  return (
    <ScalprumProvider config={scalprumConfig}>
      <DynamicRoot>{children}</DynamicRoot>
    </ScalprumProvider>
  );
};
```

#### DynamicRoot.tsx

Processes static plugins and builds dynamic configuration:

- Loads hardcoded plugins from `baseFrontendConfig`
- Scans `dynamic-plugins-root/` for runtime plugins
- Builds unified plugin registry
- Creates dynamic routes

#### baseFrontendConfig.ts

Hardcoded plugin configurations:

```typescript
export const baseFrontendConfig = {
  dynamicPlugins: {
    frontend: {
      'internal.plugin-dynamic-plugins-info': {
        dynamicRoutes: [{
          path: '/extensions',
          importName: 'DynamicPluginsInfoPage',
          menuItem: { text: 'Extensions' }
        }],
        mountPoints: [{
          mountPoint: 'internal.plugins/tab',
          importName: 'DynamicPluginsInfoContent'
        }]
      }
    }
  }
};
```

### 2. Plugin Loading Mechanisms

#### Static Loading (Hardcoded)

Plugins defined in `baseFrontendConfig.ts`:

- Loaded at application startup
- Part of main bundle
- Useful for core/essential plugins
- Example: dynamic-plugins-info plugin

#### Dynamic Loading (Runtime)

Plugins in `dynamic-plugins-root/`:

- Discovered at runtime
- Loaded via Webpack Module Federation
- Can be added/removed without rebuild
- Scanned by backend plugin

### 3. Plugin Structure

#### Plugin Manifest (`plugin-manifest.json`)

```json
{
  "name": "@internal/plugin-example",
  "version": "1.0.0",
  "backstage": {
    "role": "frontend-plugin"
  },
  "scalprum": {
    "name": "internal.plugin.example",
    "exposedModules": {
      "PluginRoot": "./dist/scalprum/plugin.chunk.js"
    }
  }
}
```

#### Package Structure

```
dynamic-plugins-root/
└── plugin-name/
    ├── package.json
    ├── plugin-manifest.json
    ├── dist/
    │   └── scalprum/
    │       ├── plugin.chunk.js
    │       └── [other chunks]
    └── dist-dynamic/
        └── [backend files if applicable]
```

## Plugin Configuration

### Dynamic Routes

Routes that are added to the app router:

```typescript
{
  dynamicRoutes: [{
    path: '/my-route',              // URL path
    importName: 'MyPageComponent',   // Component to load
    menuItem: {                      // Optional sidebar menu
      text: 'My Page',
      icon: 'ExtensionIcon'
    }
  }]
}
```

### Mount Points

Extension points where plugins can inject content:

```typescript
{
  mountPoints: [{
    mountPoint: 'entity.page.overview/cards',  // Where to mount
    importName: 'MyEntityCard',                // Component to mount
    config: {                                  // Optional config
      layout: {
        gridColumnEnd: { lg: 'span 6' }
      }
    }
  }]
}
```

### Common Mount Points
- `entity.page.overview/cards` - Entity overview cards
- `entity.page.*/context` - Entity context menu items
- `search.page.filters` - Search filters
- `settings.page.*/cards` - Settings sections
- `internal.plugins/tab` - Plugin content tabs

## Backend Integration

### Dynamic Plugins Info Backend

Located in `plugins/dynamic-plugins-info-backend/`:

- Scans `dynamic-plugins-root/` directory
- Reads plugin manifests
- Provides API endpoint: `/api/dynamic-plugins-info/loaded-plugins`
- Returns list of loaded plugins with metadata

### API Response Format

```json
{
  "plugins": [
    {
      "name": "@internal/plugin-example",
      "version": "1.0.0",
      "role": "frontend-plugin",
      "platform": "web",
      "manifest": { /* full manifest */ }
    }
  ]
}
```

## Development Workflow

### Creating a Dynamic Plugin Wrapper

1. **Use the wrapper generator**:

```bash
cd dynamic-plugins
yarn new-wrapper
```

2. **Configure the plugin**:

Edit `dynamic-plugins/wrappers/plugin-name/package.json`:

```json
{
  "name": "@internal/plugin-example-dynamic",
  "version": "1.0.0",
  "backstage": {
    "role": "frontend-plugin"
  },
  "scalprum": {
    "name": "internal.plugin.example",
    "exposedModules": {
      "PluginRoot": "./src/index.ts"
    }
  }
}
```

3. **Export components**:

```typescript
// src/index.ts
export { MyPage } from './MyPage';
export { MyCard } from './MyCard';
```

4. **Build the plugin**:

```bash
yarn build
```

5. **Copy to runtime directory**:

```bash
yarn copy-plugins
```

### Downloading External Plugins

Configure in `dynamic-plugins/downloads/plugins.json`:

```json
{
  "plugins": [
    {
      "package": "@backstage/plugin-catalog",
      "version": "^1.0.0",
      "integrity": "sha512-..."
    }
  ]
}
```

Run download script:

```bash
cd dynamic-plugins/downloads
./download-packages.sh
```

## Debugging

### Check Loaded Plugins

Visit `/extensions` page to see all loaded dynamic plugins.

### Browser Console

Scalprum logs plugin loading:

```pre
[Scalprum] Loading plugin: internal.plugin.example
[Scalprum] Plugin loaded successfully
```

### Backend Logs

Check backend logs for plugin discovery:

```pre
[dynamic-plugins-info] Scanning dynamic-plugins-root/
[dynamic-plugins-info] Found 5 plugins
```

### Common Issues

**Plugin not loading:**

- Verify `plugin-manifest.json` exists
- Check Scalprum name matches configuration
- Ensure exposed modules are built correctly
- Check browser console for errors

**Route not appearing:**

- Verify `dynamicRoutes` configuration
- Check path doesn't conflict with existing routes
- Ensure component is exported from plugin

**Mount point not working:**

- Verify mount point ID is correct
- Check component is exported
- Ensure parent component has ExtensionSlot

## Best Practices

1. **Plugin Naming**: Use consistent naming pattern: `internal.plugin.name`
2. **Versioning**: Use semantic versioning for plugins
3. **Dependencies**: Minimize external dependencies in plugins
4. **Error Handling**: Implement error boundaries in plugin components
5. **Loading States**: Show loading indicators while plugins load
6. **Testing**: Test plugins in isolation before integration
7. **Documentation**: Document plugin configuration and usage

## Security Considerations

1. **Plugin Validation**: Validate plugin manifests before loading
2. **Sandboxing**: Plugins run in same context as main app (no sandboxing)
3. **Code Review**: Review plugin code before deployment
4. **Integrity Checks**: Use integrity hashes for downloaded plugins
5. **Access Control**: Implement RBAC for plugin features

## Performance

### Bundle Size

- Dynamic plugins reduce initial bundle size
- Plugins loaded on-demand when routes accessed
- Shared dependencies deduplicated

### Caching

- Plugin chunks cached by browser
- Version changes invalidate cache
- Use cache-busting for updates

### Loading Strategy

- Critical plugins can be preloaded
- Non-critical plugins lazy loaded
- Route-based code splitting

## Migration from Static to Dynamic

1. **Create wrapper**: Generate dynamic plugin wrapper
2. **Move code**: Copy plugin code to wrapper
3. **Update exports**: Ensure components are exported
4. **Configure**: Add to baseFrontendConfig or dynamic-plugins-root
5. **Test**: Verify plugin loads and functions correctly
6. **Remove static**: Remove from app package.json and imports
