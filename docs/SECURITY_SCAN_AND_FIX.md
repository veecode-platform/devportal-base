# Security Scanning and Vulnerability Remediation

This document describes the security scanning workflow for DevPortal Base Docker images, including the Claude Code skills that automate the process.

## Overview

The security scanning workflow uses [Trivy](https://trivy.dev) to scan Docker images for vulnerabilities. The results are split into two reports:

- **Main Report** - Vulnerabilities in DevPortal base code (actionable in this repository)
- **Plugins Report** - Vulnerabilities in dynamic plugins (maintained by upstream projects)

This separation ensures remediation efforts focus on vulnerabilities that can actually be fixed in this repository.

## Quick Start with Claude Code

If you're using [Claude Code](https://claude.ai/code), two skills automate the entire workflow:

```text
# Scan the latest image
/security-scan

# Scan a specific image
/security-scan veecode/devportal-base:1.1.77

# Fix actionable vulnerabilities
/fix-vulnerabilities
```

For manual procedures, continue reading below.

## Manual Security Scanning

### Prerequisites

Install Trivy:

```bash
# macOS
brew install trivy

# Or see https://trivy.dev for other platforms
```

### Run the Scan

```bash
# Create output directory
mkdir -p .trivyscan

# Run Trivy scan (kernel packages are ignored via Rego policy)
trivy image --ignore-policy .trivy/ignore-kernel.rego --quiet --format json \
  veecode/devportal-base:latest > .trivyscan/report.json
```

### Split the Report

The split script separates vulnerabilities by source:

```bash
.trivy/split-report.sh .trivyscan/report.json
```

Output:

- `.trivyscan/main-report.json` - DevPortal base vulnerabilities
- `.trivyscan/plugins-report.json` - Dynamic plugin vulnerabilities

### Generate Markdown Reports

```bash
.trivy/generate-report.sh .trivyscan/main-report.json "DevPortal Base" > .trivyscan/main-report.md
.trivy/generate-report.sh .trivyscan/plugins-report.json "Dynamic Plugins" > .trivyscan/plugins-report.md
```

The plugins report includes a **Plugin** column showing which plugin folder contains each vulnerability.

## Understanding the Reports

### Report Structure

Each markdown report contains:

1. **Summary** - Vulnerability counts by severity (CRITICAL, HIGH, MEDIUM, LOW)
2. **High & Critical Vulnerabilities** - Detailed table of serious issues
3. **Actionable Vulnerabilities** - Issues with available fixes

### Example Main Report

```markdown
## Summary

| Severity | Count |
| -------- | ----: |
| CRITICAL |     0 |
| HIGH     |     7 |
| MEDIUM   |   151 |
| LOW      |   412 |

## High & Critical Vulnerabilities

### node-pkg

| Package | CVE            | Severity | Installed | Fixed | Description |
| ------- | -------------- | -------- | --------- | ----- | ----------- |
| tar     | CVE-2026-23745 | HIGH     | 6.2.1     | 7.5.3 | node-tar... |
```

### Example Plugins Report

The plugins report includes the plugin folder name:

```markdown
### node-pkg

| Plugin                                                | Package | CVE            | Severity |
| ----------------------------------------------------- | ------- | -------------- | -------- |
| backstage-community-plugin-tech-radar-backend-dynamic | qs      | CVE-2025-15284 | HIGH     |
```

## Vulnerability Remediation

### Vulnerability Categories

| Type              | Action                 | Notes                           |
| ----------------- | ---------------------- | ------------------------------- |
| npm (patch/minor) | Add to resolutions     | Safe to fix                     |
| npm (major)       | Document only          | Requires upgrade coordination   |
| Python (pip)      | Update requirements.in | Run pip-compile after           |
| System (RHEL)     | Skip                   | Requires upstream Red Hat fixes |
| Dynamic plugins   | Skip                   | Maintained by upstream projects |
| No fix available  | Skip                   | Monitor for future fixes        |

### Fixing npm Vulnerabilities

Add resolutions to `package.json`:

```json
{
  "resolutions": {
    "vulnerable-package": "^fixed.version"
  }
}
```

**Important constraints:**

- **Never add resolutions for `@backstage/*` packages** - use `/upgrade-and-test` instead
- Only add resolutions for patch/minor updates
- Skip major version bumps (document for later)

### Fixing Python Vulnerabilities

Update `python/requirements.in`:

```text
package>=fixed.version
```

Then regenerate the lockfile:

```bash
source venv/bin/activate
pip-compile --output-file=python/requirements.txt python/requirements.in
```

### Verify Fixes

After applying fixes:

```bash
yarn install
yarn dedupe
yarn build
yarn test
```

## Implementation Details

### Directory Structure

```text
.trivy/
├── ignore-kernel.rego      # Rego policy to skip kernel packages
├── split-report.sh         # Splits report into main vs plugins
└── generate-report.sh      # Generates markdown from JSON

.trivyscan/                  # Output directory (gitignored)
├── report.json             # Full Trivy scan output
├── main-report.json        # DevPortal base vulnerabilities
├── main-report.md          # Human-readable main report
├── plugins-report.json     # Dynamic plugin vulnerabilities
└── plugins-report.md       # Human-readable plugins report
```

### How Reports Are Split

The `split-report.sh` script examines the `PkgPath` field in each vulnerability:

- **Main report**: Vulnerabilities where `PkgPath` does NOT contain `dynamic-plugins-root`
- **Plugins report**: Vulnerabilities where `PkgPath` contains `dynamic-plugins-root`

This includes:

- **Main**: OS packages (RHEL), Python packages (TechDocs), Go binaries, app dependencies
- **Plugins**: Any package under `app/dynamic-plugins-root/*/node_modules/`

### Kernel Package Filtering

The `.trivy/ignore-kernel.rego` policy filters out kernel-related packages because:

1. They require host-level fixes, not container fixes
2. Container images inherit the host kernel
3. They create noise in the scan results

### Plugin Column Extraction

For the plugins report, the plugin folder name is extracted from paths like:

```text
app/dynamic-plugins-root/backstage-community-plugin-tech-radar-backend-dynamic/node_modules/qs/package.json
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                         This part becomes the Plugin column value
```

## Claude Code Skills Reference

### /security-scan

Scans a Docker image and generates split reports.

**Usage:**

```text
/security-scan [image]
```

**Default:** `veecode/devportal-base:latest`

**Output files:**

- `.trivyscan/report.json`
- `.trivyscan/main-report.json` and `.trivyscan/main-report.md`
- `.trivyscan/plugins-report.json` and `.trivyscan/plugins-report.md`

### /fix-vulnerabilities

Remediates actionable vulnerabilities from the main report.

**Prerequisites:** Run `/security-scan` first

**Actions:**

1. Parses `.trivyscan/main-report.json`
2. Adds npm resolutions for patch/minor fixes
3. Updates Python requirements for pip fixes
4. Runs build and tests to verify
5. Reports fixed vs skipped vulnerabilities

**Skips:**

- Major version bumps
- `@backstage/*` packages (use `/upgrade-and-test` instead)
- System packages (no fix available)
- Dynamic plugin vulnerabilities (upstream responsibility)

## Best Practices

1. **Scan regularly** - Run security scans after each release and periodically
2. **Fix incrementally** - Address HIGH/CRITICAL first, then work down
3. **Test thoroughly** - Always verify builds pass after applying fixes
4. **Document skipped issues** - Track major bumps for future upgrade cycles
5. **Monitor upstream** - Watch for fixes to system packages and dynamic plugins
