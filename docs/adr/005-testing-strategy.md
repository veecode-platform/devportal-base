# ADR-005: Testing Strategy - Test as You Go

## Status

Accepted

## Context

The codebase has low test coverage due to rapid development and migration from previous repositories. We face a choice:

1. **Stop and backfill** - Pause features to write tests for existing code
2. **Test as you go** - Add tests alongside new work, gradually improving coverage
3. **Ignore testing** - Continue without tests (not acceptable)

Stopping feature development to backfill tests would:

- Block business value delivery
- Create a large, demotivating task
- Result in tests for code that may change anyway

## Decision

Adopt a "test as you go" strategy with these rules:

| Situation | Action |
|-----------|--------|
| Writing new code | Add unit test |
| Fixing a bug | Add regression test |
| Refactoring old code | Add test first |
| Just reading/using old code | Leave it alone |

### Priority Areas

When time permits, focus testing efforts on:

1. **Backend APIs** - High value, easy to test
2. **Internal plugins** (`plugins/*`) - Isolated, testable units
3. **Shared utilities** (`packages/plugin-utils`)

### Skip for Now

- Complex frontend integration tests (DynamicRoot, Scalprum)
- E2E tests (high maintenance cost)

### CI Enforcement

- PR checks run `yarn test` - prevents new regressions
- Pre-commit hooks catch issues early
- Tests must pass before merge

## Consequences

### Benefits

- No feature delivery blockage
- Testing improves organically
- New code has good coverage
- Regression tests prevent repeat bugs
- Sustainable, non-demotivating approach

### Drawbacks

- Legacy code remains untested
- Coverage metrics stay low initially
- Some refactoring risk without tests

### Related Files

- `CLAUDE.md` (Testing Strategy section)
- `.github/workflows/pr-check.yml`
- `docs/ROADMAP_BACKLOG.md`
