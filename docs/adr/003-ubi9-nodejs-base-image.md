# ADR-003: UBI9 Node.js as Container Base

## Status

Accepted

## Context

Container base image selection affects:

- Security posture and CVE exposure
- Enterprise compliance requirements
- Image size and build times
- Available system packages
- Long-term support and updates

Options considered:

1. **node:22-bookworm-slim** - Official Node.js image, Debian-based
2. **node:22-alpine** - Minimal Alpine-based image
3. **registry.redhat.io/ubi9/nodejs-22** - Red Hat Universal Base Image

## Decision

Use Red Hat UBI9 Node.js images (`registry.redhat.io/ubi9/nodejs-22`) as the container base.

### Rationale

- **Enterprise support** - Red Hat backing with known support lifecycle
- **Security focus** - Regular security updates, CVE scanning
- **RHEL compatibility** - Consistent with enterprise Linux environments
- **Compliance** - Meets enterprise security requirements
- **RHDH alignment** - Consistent with Red Hat Developer Hub patterns

### Image Tag Selection

Use specific tags (e.g., `9.7-1765878606`) rather than `latest` for reproducibility. Find latest stable tag:

```bash
skopeo list-tags docker://registry.redhat.io/ubi9/nodejs-22 \
  | jq -r '.Tags[]
           | select(startswith("9.7-"))
           | select(endswith("-source") | not)' \
  | sort -V \
  | tail -n 1
```

## Consequences

### Benefits

- Enterprise-grade security and compliance
- Predictable update cycle
- Access to Red Hat package repositories (dnf)
- Compatible with OpenShift deployments

### Drawbacks

- Larger image size than Alpine (~200MB vs ~50MB base)
- Requires Red Hat registry access (free registration)
- Some packages differ from Debian (dnf vs apt)

### Related Files

- `packages/backend/Dockerfile`
- `docker/Dockerfile-dev`
- `docs/UPGRADING.md`
