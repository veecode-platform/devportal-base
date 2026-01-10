# ADR-006: Yarn 4 with Workspaces

## Status

Accepted

## Context

The project is a monorepo with multiple packages:

- `packages/app` - Frontend application
- `packages/backend` - Backend server
- `packages/plugin-utils` - Shared utilities
- `plugins/*` - Internal plugins
- `dynamic-plugins/` - Dynamic plugin build workspace

Package management options:

1. **npm workspaces** - Native, but slower and less feature-rich
2. **Yarn 1 (Classic)** - Widely used but outdated
3. **Yarn 4 (Berry)** - Modern, fast, with advanced features
4. **pnpm** - Fast and efficient, but less Backstage ecosystem support

## Decision

Use Yarn 4 with workspaces for package management.

### Configuration

```yaml
# .yarnrc.yml
nodeLinker: node-modules  # Not using PnP for compatibility
```

### Key Commands

```bash
# Workspace-specific commands
yarn workspace app build
yarn workspace backend test
yarn workspace @internal/plugin-dynamic-plugins-info test

# Root commands (via Turbo)
yarn build
yarn test
yarn lint:check
```

## Consequences

### Benefits

- Fast installation with caching
- Consistent lockfile (`yarn.lock`)
- Workspace protocol (`workspace:^`) for local dependencies
- Better monorepo support than npm
- Backstage ecosystem compatibility
- Corepack integration (Node.js 22+)

### Drawbacks

- Learning curve vs npm
- PnP mode disabled for compatibility (using node-modules linker)
- Some tools need configuration for Yarn 4

### Version Pinning

Pin Yarn version via Corepack in Dockerfiles:

```dockerfile
RUN npm install -g corepack && \
    corepack enable && \
    corepack prepare yarn@4.12.0 --activate
```

### Related Files

- `package.json`
- `.yarnrc.yml`
- `yarn.lock`
- `packages/backend/Dockerfile`
