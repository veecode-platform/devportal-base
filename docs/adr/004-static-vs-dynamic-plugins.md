# ADR-004: Static vs Dynamic Plugin Classification

## Status

Accepted

## Context

With Scalprum enabling dynamic plugin loading, we need a clear policy for which plugins should be:

- **Static** - Compiled into the application bundle
- **Dynamic** - Loaded at runtime from filesystem or registry

This affects build complexity, startup time, and flexibility.

## Decision

Classify plugins based on their role in the platform:

### Static Plugins (Always Loaded)

Core functionality that other plugins depend on or that's required for basic operation:

| Plugin | Reason |
|--------|--------|
| Auth providers (GitHub, GitLab, Google, Microsoft, OIDC, OAuth2) | Core security, loaded before any dynamic plugins |
| Catalog | Fundamental data model, required by most plugins |
| Permissions | Access control infrastructure |
| RBAC | Role-based access control |
| TechDocs (core) | Documentation infrastructure |
| Notifications | Platform messaging |
| Signals | Event infrastructure |

### Dynamic Plugins (Optionally Loaded)

Everything else - features that can be enabled/disabled per deployment:

- UI customizations (themes, homepage)
- Additional catalog providers
- Tech Radar, API docs
- Third-party integrations
- Custom plugins

### Decision Criteria

A plugin should be **static** if:

1. It provides infrastructure other plugins depend on
2. It must be available before dynamic loading starts
3. It's security-critical (auth, permissions)
4. It's required for the app to function at all

Otherwise, make it **dynamic**.

## Consequences

### Benefits

- Core functionality always available and tested
- Dynamic plugins can be enabled/disabled without rebuild
- Clear mental model for plugin authors
- Smaller dynamic plugin builds (shared deps with static core)

### Drawbacks

- Static plugins increase base image size
- Cannot disable core plugins even if not needed
- Version coupling between static plugins

### Related Files

- `packages/backend/src/index.ts` (static plugin registration)
- `packages/app/src/App.tsx` (static frontend plugins)
- `docs/PLUGINS.md`
