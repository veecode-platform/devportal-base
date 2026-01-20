# ADR-003: UBI10 Node.js as Container Base

## Status

Accepted (Updated from UBI9)

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
3. **registry.redhat.io/ubi10/nodejs-22** - Red Hat Universal Base Image 10

## Decision

Use Red Hat UBI10 Node.js images (`registry.redhat.io/ubi10/nodejs-22`) as the container base.

### Rationale

- **Enterprise support** - Red Hat backing with known support lifecycle
- **Security focus** - Regular security updates, CVE scanning
- **RHEL compatibility** - Consistent with enterprise Linux environments
- **Compliance** - Meets enterprise security requirements
- **RHDH alignment** - Consistent with Red Hat Developer Hub patterns
- **Modern base** - UBI10 provides latest RHEL 10 packages and security fixes

### Image Tag Selection

Use specific tags (e.g., `10.1-1768278739`) rather than `latest` for reproducibility. Find latest stable tag:

```bash
skopeo list-tags docker://registry.redhat.io/ubi10/nodejs-22 \
  | jq -r '.Tags[]
           | select(startswith("10.1-"))
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
- Latest security patches from RHEL 10

### Drawbacks

- Larger image size than Alpine (~200MB vs ~50MB base)
- Requires Red Hat registry access (free registration)
- Some packages differ from Debian (dnf vs apt)

### Migration Notes

Migrated from UBI9 (`registry.redhat.io/ubi9/nodejs-22`) to UBI10 in January 2026. Key changes:

- Tag prefix changed from `9.7-` to `10.1-`
- dnf commands remain compatible (no breaking changes)
- Module streams removed in UBI10 but not used in our Dockerfile

### Related Files

- `packages/backend/Dockerfile`
- `docker/Dockerfile-dev`
- `docs/UPGRADING.md`
- `scripts/update-base-image.sh`
