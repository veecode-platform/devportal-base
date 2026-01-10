# ADR-002: Base Image vs Distro Image Separation

## Status

Accepted

## Context

Different deployment scenarios require different plugin sets:

- Some users want a minimal foundation to build upon
- Others want a batteries-included distribution
- Enterprise deployments may need custom plugin combinations
- Testing and CI benefit from smaller, faster images

A single monolithic image cannot serve all these needs efficiently.

## Decision

Separate the container image strategy into two tiers:

### Base Image (this repository)

- **Intentionally lightweight** with minimal plugin set
- Contains only core static plugins required for basic operation
- Provides foundation for derived images
- Focuses on stability and security
- Plugins: auth providers, catalog, permissions, RBAC, TechDocs core

### Distro Image (derived repositories)

- Built FROM the base image
- Packages additional dynamic plugins for production use
- Creates competitive, feature-rich distributions
- Can be customized for specific use cases
- Examples: VeeCode Platform distro, customer-specific distros

## Consequences

### Benefits

- Smaller base image = faster CI, less attack surface
- Clear separation of concerns
- Flexibility for different deployment needs
- Base image changes don't require rebuilding all plugins
- Derived images inherit security updates from base

### Drawbacks

- Two-tier build process
- Need to coordinate versions between base and distro
- More complex release management

### Related Files

- `packages/backend/Dockerfile`
- `docs/PLUGINS.md`
- `dynamic-plugins/`
