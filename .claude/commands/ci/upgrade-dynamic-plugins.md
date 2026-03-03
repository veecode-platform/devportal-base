# Dynamic Plugin Wrapper Upgrade (Automated)

Check for available upgrades for dynamic plugin wrappers and automatically
apply all patch and minor upgrades. Major upgrades are skipped and reported.

## Steps

1. **List all wrapper folders**:

   ```bash
   ls -d dynamic-plugins/wrappers/*/
   ```

2. **For each wrapper folder**, read the `package.json` and extract:

   - The wrapper `name` field
   - The `dependencies` that match Backstage packages (starting with `@backstage-community/` or `@backstage/`)

3. **For each dependency package**, fetch the latest version from npm registry:

   ```bash
   curl -s "https://registry.npmjs.org/<package-name>" | jq -r '.["dist-tags"].latest'
   ```

   Replace `<package-name>` with the URL-encoded scoped package name (e.g., `@backstage-community/plugin-rbac` becomes `@backstage-community%2Fplugin-rbac`).

4. **Compare versions and classify**:

   For each dependency, compare the installed version with the latest. Classify each as:
   - **patch**: only the patch version changed (e.g., 1.2.3 -> 1.2.4)
   - **minor**: the minor version changed (e.g., 1.2.3 -> 1.3.0)
   - **major**: the major version changed (e.g., 1.2.3 -> 2.0.0)
   - **up to date**: no change

5. **Apply patch and minor upgrades automatically**:

   For each dependency classified as patch or minor, use the `Edit` tool to update the version in the corresponding wrapper `package.json` under `dynamic-plugins/wrappers/<wrapper-name>/package.json`. Preserve the `^` prefix.

   Do NOT apply major upgrades. List them in the output for inclusion in the PR body.

6. **Run yarn install**:

   After all upgrades are applied, run from the `dynamic-plugins` folder:

   ```bash
   cd dynamic-plugins && yarn install
   ```

7. **Report results**:

   Output a summary with:
   - Table of applied upgrades (wrapper, dependency, old version, new version)
   - List of skipped major upgrades (wrapper, dependency, current, available)
   - yarn install status

## Notes

- The npm registry URL for scoped packages requires URL encoding: `@scope/package` becomes `@scope%2Fpackage`
- Only check dependencies that are Backstage-related (starting with `@backstage-community/` or `@backstage/`)
- Strip the `^` or `~` prefix from version strings when comparing
- Always preserve the `^` or `~` prefix when updating versions
- Run `yarn install` only once after all upgrades are applied, from the `dynamic-plugins` folder (not from individual wrapper folders)
