Scan a Docker image for security vulnerabilities using Trivy:

## Arguments

- `$ARGUMENTS` - Docker image to scan (e.g., `veecode/devportal-base:1.1.72`). If not provided, defaults to `veecode/devportal-base:latest`.

## Steps

1. **Determine the image to scan**:

   - Use `$ARGUMENTS` if provided
   - Otherwise default to `veecode/devportal-base:latest`

2. **Run Trivy scan** - Get vulnerability breakdown by severity:

   ```bash
   trivy image --ignore-policy .trivy/ignore-kernel.rego --severity HIGH,CRITICAL <image>
   ```

   - The Rego policy (`.trivy/ignore-kernel.rego`) excludes kernel packages (not actionable in containers)
   - Show the package summary with high/critical CVEs

3. **Run full scan for summary** - Get total vulnerability counts across all severities:

   ```bash
   trivy image --ignore-policy .trivy/ignore-kernel.rego --format json <image> 2>/dev/null | jq '[.Results[].Vulnerabilities // [] | .[]] | group_by(.Severity) | map({severity: .[0].Severity, count: length}) | sort_by(.severity)'
   ```

   - This provides counts for the summary table

4. **Report results** with a summary table:

   | Severity | Count |
   | -------- | ----- |
   | Critical | X     |
   | High     | X     |
   | Medium   | X     |
   | Low      | X     |

   - List packages with high-severity vulnerabilities
   - Note which vulnerabilities have fixes available
   - Highlight key observations (e.g., OS packages vs application dependencies)

## Notes

- Trivy must be installed (`brew install trivy` or see <https://trivy.dev>)
- The scan analyzes OS packages (RPM, APT) and application dependencies (npm, Python, Go, etc.)
- Kernel packages are ignored via `.trivy/ignore-kernel.rego` Rego policy - they require host-level fixes and are not actionable within containers
- Use `--ignore-unfixed` flag to show only vulnerabilities with available fixes
