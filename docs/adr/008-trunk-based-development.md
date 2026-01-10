# ADR-008: Trunk-Based Development with Short-Lived Branches

## Status

Accepted

## Context

The project needs a clear Git workflow that:

- Ensures code quality through CI checks
- Supports both human and AI-assisted development
- Keeps the main branch always releasable
- Minimizes merge conflicts and integration pain

Options considered:

1. **Gitflow** - Long-lived develop/release branches, feature branches
2. **GitHub Flow** - Feature branches merged to main
3. **Trunk-Based Development** - Very short-lived branches, frequent integration

## Decision

Adopt trunk-based development with short-lived feature branches:

### Core Principles

1. **Main is always releasable** - All changes go through PR with CI
2. **Short-lived branches** - Hours to days, not weeks
3. **Small, frequent merges** - Reduces integration risk
4. **Squash merge** - Clean, linear history on main

### Workflow

```
main ─────●─────●─────●─────●─────●─────
          ↑     ↑     ↑     ↑     ↑
         feat  fix  docs  feat  fix
         (1d)  (2h) (1h)  (3d)  (4h)
```

### Branch Protection

- `validate` CI check required before merge
- No direct pushes to main (with exceptions below)
- Branches deleted after merge

### Exceptions to PR Requirement

**Low-risk changes** (direct push allowed):

- Pure documentation (markdown, comments only)
- ADR additions or updates
- CLAUDE.md updates

**Emergencies** (direct push allowed, must document reason):

- Critical security fixes
- CI pipeline repairs

### Branch Naming Convention

| Prefix | Purpose |
|--------|---------|
| `feat/` | New features |
| `fix/` | Bug fixes |
| `docs/` | Documentation |
| `refactor/` | Code restructuring |
| `chore/` | Maintenance |

## Consequences

### Benefits

- Main always deployable
- Fast feedback through CI
- Reduced merge conflicts (small, frequent changes)
- Clear history with squash merges
- Works well with AI-assisted development (predictable workflow)
- Easy to reason about current state

### Drawbacks

- Requires discipline to keep branches short
- Features must be broken into small increments
- May need feature flags for larger changes

### Related Files

- `CLAUDE.md` (Git Workflow section)
- `.github/workflows/pr-check.yml`
