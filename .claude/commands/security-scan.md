Scan a Docker image for security vulnerabilities using Docker Scout:

## Arguments

- `$ARGUMENTS` - Docker image to scan (e.g., `veecode/devportal-base:1.1.72`). If not provided, defaults to `veecode/devportal-base:latest`.

## Steps

1. **Determine the image to scan**:

   - Use `$ARGUMENTS` if provided
   - Otherwise default to `veecode/devportal-base:latest`

2. **Run quickview** - Get a quick summary of vulnerabilities and base image info:

   ```bash
   docker scout quickview <image>
   ```

3. **Run detailed CVE scan** - Get vulnerability breakdown by package:

   ```bash
   docker scout cves <image> --only-severity high,critical
   ```

   - Show the package summary (packages with high/critical CVEs)
   - Limit output to avoid overwhelming results

4. **Get recommendations** - Check for base image updates:

   ```bash
   docker scout recommendations <image>
   ```

5. **Report results** with a summary table:

   | Severity | Count |
   | -------- | ----- |
   | Critical | X     |
   | High     | X     |
   | Medium   | X     |
   | Low      | X     |

   - List packages with high-severity vulnerabilities
   - Note any base image update recommendations
   - Highlight key observations (e.g., kernel vs application vulnerabilities)

## Notes

- Docker Scout must be installed and authenticated (`docker scout` CLI)
- The scan analyzes both OS packages (RPM) and application dependencies (npm, Python, Go)
- Kernel vulnerabilities from the base image typically require upstream fixes from Red Hat
- Most kernel CVEs require local access (AV:L) and are lower risk for containerized workloads
