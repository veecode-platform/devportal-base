# Plugin Upgrade Checker

Check for available upgrades for dynamic plugin wrappers by querying npm registry.

## Steps

1. **List all wrapper folders**:

   Get all directories under `dynamic-plugins/wrappers/`:

   ```bash
   ls -d dynamic-plugins/wrappers/*/
   ```

2. **For each wrapper folder**, read the `package.json` and extract:

   - The wrapper `name` field
   - The wrapper `version` field
   - The `dependencies` that match Backstage community plugins (packages starting with `@backstage-community/` or `@backstage/`)

3. **For each dependency package**, fetch the latest version from npm registry:

   Use the npm registry API to get package metadata:

   ```bash
   curl -s "https://registry.npmjs.org/<package-name>" | jq -r '.["dist-tags"].latest'
   ```

   Replace `<package-name>` with the scoped package name (e.g., `@backstage-community/plugin-rbac` becomes `@backstage-community%2Fplugin-rbac` in the URL).

4. **Compare versions** and build a report:

   For each wrapper, compare the installed dependency version (from `dependencies` field) with the latest available version.

5. **Output results** in a table format:

   | Wrapper                               | Dependency                             | Current | Latest | Status            |
   | ------------------------------------- | -------------------------------------- | ------- | ------ | ----------------- |
   | backstage-community-plugin-rbac       | @backstage-community/plugin-rbac       | 1.47.0  | 1.50.0 | Upgrade available |
   | backstage-community-plugin-tech-radar | @backstage-community/plugin-tech-radar | 1.13.0  | 1.13.0 | Up to date        |

   Use these status values:

   - **Upgrade available** - newer version exists
   - **Up to date** - already on latest version
   - **Error** - could not fetch version info

## Notes

- The npm registry URL for scoped packages requires URL encoding: `@scope/package` becomes `@scope%2Fpackage`
- Only check dependencies that are Backstage-related (starting with `@backstage-community/` or `@backstage/`)
- Strip the `^` or `~` prefix from version strings when comparing
- If a wrapper has multiple Backstage dependencies, show each on a separate row
