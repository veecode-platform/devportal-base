# ADR-007: Jest --watchAll=false for Turbo CI

## Status

Accepted

## Context

Tests were hanging indefinitely when run via Turbo in CI and during automated development sessions. Investigation revealed:

1. Jest defaults to **watch mode** in interactive terminals
2. Turbo runs commands in a pseudo-terminal environment
3. Turbo doesn't forward stdin properly to child processes
4. Jest waits for keypress input that never comes → hang

This blocked:

- CI pipelines
- Automated testing
- Agent-based development workflows

## Decision

Add `--watchAll=false` to all test scripts in `package.json` files:

```json
{
  "scripts": {
    "test": "backstage-cli package test --watchAll=false"
  }
}
```

Affected packages:

- `packages/app`
- `packages/backend`
- `packages/plugin-utils`
- `plugins/dynamic-plugins-info`
- `plugins/dynamic-plugins-info-backend`
- `plugins/scalprum-backend`

## Consequences

### Benefits

- Tests complete reliably in CI
- No hanging during automated workflows
- Agent-based development works correctly
- Turbo caching works for test results

### Drawbacks

- Local developers must explicitly use `--watch` if they want watch mode
- Slightly longer command for interactive development

### Alternative Considered

Setting `CI=true` environment variable also disables watch mode, but:

- Less explicit about intent
- May have other side effects
- `--watchAll=false` is more targeted

### Related Files

- `packages/*/package.json`
- `plugins/*/package.json`
- `.github/workflows/pr-check.yml`
