Scan a Docker image for security vulnerabilities using Trivy:

## Arguments

- `$ARGUMENTS` - Docker image to scan (e.g., `veecode/devportal-base:1.1.72`). If not provided, defaults to `veecode/devportal-base:latest`.

## Steps

1. **Determine the image to scan**:

   - Use `$ARGUMENTS` if provided
   - Otherwise default to `veecode/devportal-base:latest`

2. **Create output directory and run scans**:

   ```bash
   mkdir -p .trivyscan
   ```

   Run the JSON scan and save to `.trivyscan/report.json`:

   ```bash
   trivy image --ignore-policy .trivy/ignore-kernel.rego --quiet --format json <image> > .trivyscan/report.json
   ```

   Generate the markdown report from JSON:

   ```bash
   .trivy/generate-report.sh .trivyscan/report.json > .trivyscan/report.md
   ```

3. **Report results** with a summary table:

   | Severity | Count |
   | -------- | ----- |
   | Critical | X     |
   | High     | X     |
   | Medium   | X     |
   | Low      | X     |

   - List packages with high-severity vulnerabilities
   - Note which vulnerabilities have fixes available
   - Highlight key observations (e.g., OS packages vs application dependencies)

## Output Files

- `.trivyscan/report.json` - Full JSON report for programmatic analysis
- `.trivyscan/report.md` - Human-readable markdown report with HIGH/CRITICAL vulnerabilities

## Notes

- Trivy must be installed (`brew install trivy` or see <https://trivy.dev>)
- The scan analyzes OS packages (RPM, APT) and application dependencies (npm, Python, Go, etc.)
- Kernel packages are ignored via `.trivy/ignore-kernel.rego` Rego policy - they require host-level fixes and are not actionable within containers
- Use `--ignore-unfixed` flag to show only vulnerabilities with available fixes
- The `.trivyscan/` folder should be added to `.gitignore`
