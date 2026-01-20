# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for VeeCode DevPortal Base.

## What are ADRs?

ADRs document important architectural decisions along with their context and consequences. They help future contributors (human and AI) understand **why** decisions were made, not just what exists.

## ADR Index

| ID                                      | Title                                             | Status   |
| --------------------------------------- | ------------------------------------------------- | -------- |
| [001](001-scalprum-dynamic-plugins.md)  | Use Scalprum for Dynamic Plugin Loading           | Accepted |
| [002](002-base-vs-distro-image.md)      | Base Image vs Distro Image Separation             | Accepted |
| [003](003-ubi10-nodejs-base-image.md)   | UBI10 Node.js as Container Base                   | Accepted |
| [004](004-static-vs-dynamic-plugins.md) | Static vs Dynamic Plugin Classification           | Accepted |
| [005](005-testing-strategy.md)          | Testing Strategy - Test as You Go                 | Accepted |
| [006](006-yarn4-workspaces.md)          | Yarn 4 with Workspaces                            | Accepted |
| [007](007-jest-watch-false.md)          | Jest --watchAll=false for Turbo CI                | Accepted |
| [008](008-trunk-based-development.md)   | Trunk-Based Development with Short-Lived Branches | Accepted |
| [009](009-configuration-profiles.md)    | Configuration Profiles                            | Accepted |

## ADR Template

When creating new ADRs, use this template:

```markdown
# ADR-NNN: Title

## Status

Accepted | Superseded | Deprecated

## Context

What is the issue that we're seeing that is motivating this decision?

## Decision

What is the change that we're proposing and/or doing?

## Consequences

What becomes easier or harder because of this change?
```

## Contributing

When making significant architectural decisions:

1. Create a new ADR file: `NNN-short-title.md`
2. Fill in the template
3. Add to the index above
4. Submit with your PR
