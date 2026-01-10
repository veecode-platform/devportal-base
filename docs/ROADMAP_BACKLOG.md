# Technical Backlog

This document tracks technical debt, broken/skipped tests, and outdated documentation.

## Testing Backlog

### Skipped Tests

These tests are currently skipped and need attention:

| File | Reason | Priority |
|------|--------|----------|
| `packages/app/src/App.test.tsx` | Top-level await incompatible with Jest/CJS transform | Low |
| `packages/app/src/components/DynamicRoot/DynamicRoot.test.tsx` | Complex Scalprum integration | Low |

### Test Coverage Gaps

Areas that need test coverage (prioritized per Testing Strategy in CLAUDE.md):

1. **Backend APIs** - High value, easy to test
2. **Internal plugins** (`plugins/*`) - Isolated, testable units
3. **Shared utilities** (`packages/plugin-utils`)

### Testing Infrastructure Issues

- [x] ~~Pre-commit hooks fail due to missing `@ianvs/prettier-plugin-sort-imports`~~ (Fixed)
- [ ] Some tests have React Router deprecation warnings (v7 migration needed eventually)

## Documentation Backlog

### Outdated Documentation

These docs need review and updates:

| File | Description | Status |
|------|-------------|--------|
| `docs/CONFIGURATION_GUIDE.md` | YAML-based configuration hierarchy and core settings | Outdated |
| `docs/DEVELOPMENT_GUIDE.md` | Getting started, prerequisites, and development workflow | Outdated |
| `docs/DOCKER_DEVELOPMENT.md` | Docker setup for local development and production builds | Outdated |
| `docs/DYNAMIC_PLUGINS_ARCHITECTURE.md` | Scalprum-based dynamic plugin system | Outdated |
| `docs/MONOREPO_STRUCTURE.md` | Yarn workspaces, package management, and repository organization | Outdated |
| `docs/MUI_MIGRATION_STATUS.md` | Material-UI v4 to v5 migration progress and compatibility layer | Outdated |
| `docs/PROJECT_CONTEXT.md` | Technology stack, architecture overview, and AI assistant guidance | Outdated |

### Documentation Up-to-date

| File | Description |
|------|-------------|
| `docs/BACKSTAGE_ARCHITECTURE.md` | Core Backstage architecture |
| `docs/DYNAMIC_PLUGIN_TRANSLATIONS.md` | Internationalization for dynamic plugins |
| `docs/PLUGINS.md` | Static vs dynamic plugins, core plugin list |
| `docs/RBAC.md` | Role-based access control configuration |
| `CLAUDE.md` | Claude Code guidance (maintained) |

## Technical Debt

### Code Quality

- [ ] Remove unused imports/variables flagged by linter
- [ ] Address React strict mode warnings

### Dependencies

- [ ] React Router v6 → v7 migration (future)
- [ ] MSW v1 patterns still in some tests (mostly migrated to v2)

## How to Contribute

1. Pick an item from this backlog
2. Create a branch and fix the issue
3. Update this document to reflect progress
4. Submit a PR

Remember: Follow the Testing Strategy - test as you go, don't block feature work.
