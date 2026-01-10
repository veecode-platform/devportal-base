# ADR-001: Use Scalprum for Dynamic Plugin Loading

## Status

Accepted

## Context

Standard Backstage requires rebuilding the entire application whenever plugins are added, removed, or updated. This creates friction for:

- Experimenting with new plugins
- Deploying plugin updates independently
- Creating flexible distributions with optional plugins
- Enterprise deployments where rebuild cycles are costly

Red Hat Developer Hub (RHDH) solved this problem using Scalprum, a Webpack Module Federation based solution that enables runtime plugin loading.

## Decision

Adopt Scalprum for dynamic plugin loading, following RHDH patterns. This includes:

- **ScalprumRoot** wrapper component that initializes the Scalprum provider (frontend plugins)
- **DynamicRoot** component that processes plugin configurations and builds dynamic routes
- **Plugin manifests** (`plugin-manifest.json`) that describe plugin metadata and exposed modules
- **Runtime directory** (`dynamic-plugins-root/`) where plugins are discovered and loaded from

Plugins can be:

- Loaded from the filesystem (preinstalled)
- Downloaded from registries at startup
- Configured in many convenient ways (see [Plugins](../PLUGINS.md))

## Consequences

### Benefits

- Plugins can be added/removed without rebuilding the application
- Reduced initial bundle size (plugins loaded on-demand)
- Enables flexible distribution model (base + distro images)
- Faster plugin development cycle
- Runtime plugin configuration
- Compatibility with RHDH dynamic plugins

### Drawbacks

- Additional complexity in plugin packaging
- Plugins must be built as dynamic modules (wrappers needed for legacy plugins)
- Debugging can be more complex
- No compile-time type checking across plugin boundaries

### Related Files

- `packages/app/src/components/DynamicRoot/`
- `packages/app/src/components/DynamicRoot/ScalprumRoot.tsx`
- `plugins/scalprum-backend/`
- `dynamic-plugins/`
