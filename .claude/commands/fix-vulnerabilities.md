Remediate known vulnerabilities identified by Trivy security scans:

## Prerequisites

- Run `/security-scan` first to generate the split reports
- This skill uses `.trivyscan/main-report.json` (DevPortal base vulnerabilities only)
- Dynamic plugin vulnerabilities (in `plugins-report.json`) are ignored - they are maintained by upstream projects

## Steps

1. **Parse vulnerability report**:

   Read `.trivyscan/main-report.json` and identify actionable vulnerabilities:

   - npm packages with available fixes (fixable via Yarn resolutions)
   - Python packages with available fixes (fixable via requirements.in)
   - Skip system packages (RHEL/UBI) - not actionable

2. **For npm vulnerabilities**:

   Add resolutions to `package.json` under the `resolutions` block:

   ```json
   "resolutions": {
     "vulnerable-package": "^fixed.version"
   }
   ```

   **Important constraints:**

   - **NEVER add resolutions for `@backstage/*` packages** - these must only be updated via the Backstage upgrade process. Use `/upgrade-and-test` skill instead for Backstage version bumps.
   - Only add resolutions for patch/minor updates
   - Skip major version bumps that may break dependencies (document for later)
   - Only add resolutions for patch/minor updates that pass validation
   - Skip major version bumps that may break dependencies (document for later)

3. **For Python vulnerabilities**:

   Update constraints in `python/requirements.in`:

   ```pre
   package>=fixed.version
   ```

   Then regenerate:

   ```bash
   source venv/bin/activate && pip-compile --output-file=python/requirements.txt python/requirements.in
   ```

4. **Deduplicate and verify**:

   ```bash
   yarn dedupe
   yarn install
   yarn tsc
   yarn lint:check
   yarn build
   yarn test
   ```

   If any command fails, identify which resolution caused it and revert
   that resolution. Move the associated CVE to "skipped" with the reason.

5. **Report results**:

   Provide a summary of:

   - Vulnerabilities fixed (package, old version, new version)
   - Vulnerabilities skipped (and why: major bump, system package, no fix available)
   - Fixes applied and skipped

## Vulnerability Categories

| Type              | Action                 | Notes                           |
| ----------------- | ---------------------- | ------------------------------- |
| npm (patch/minor) | Add to resolutions     | Safe to fix                     |
| npm (major)       | Document only          | Requires upgrade coordination   |
| Python (pip)      | Update requirements.in | Run pip-compile after           |
| System (RHEL)     | Skip                   | Requires upstream Red Hat fixes |
| Dynamic plugins   | Skip                   | Maintained by upstream projects |
| No fix available  | Skip                   | Monitor for future fixes        |

## Example Resolutions

```json
"resolutions": {
  "qs": "^6.14.1",
  "jws": "^3.2.3",
  "undici": "7.16.0"
}
```

## Notes

- Always verify that resolutions pass validation before finalizing
- Track skipped vulnerabilities for future Backstage upgrades
