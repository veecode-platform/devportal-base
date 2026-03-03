# Static Plugin Upgrade (Automated)

Check for available upgrades for static plugins and automatically apply
all patch and minor upgrades. Major upgrades are skipped and reported.

## Steps

1. **Read package.json files**:

   Read both `packages/app/package.json` and `packages/backend/package.json` to extract dependencies.

2. **Filter eligible packages**:

   From both `dependencies` and `devDependencies`, filter packages whose names start with any of these prefixes:

   - `@backstage-community/plugin-catalog-backend-module`
   - `@backstage-community/plugin-scaffolder-backend-module`
   - `@roadiehq/scaffolder`

3. **For each eligible package**, fetch the latest version from npm registry:

   ```bash
   curl -s "https://registry.npmjs.org/<package-name>" | jq -r '.["dist-tags"].latest'
   ```

   Replace `<package-name>` with the URL-encoded scoped package name (e.g., `@backstage/plugin-auth-backend-module-github-provider` becomes `@backstage%2Fplugin-auth-backend-module-github-provider`).

4. **Compare versions and classify**:

   For each eligible package, compare the installed version with the latest. Classify each as:
   - **patch**: only the patch version changed (e.g., 1.2.3 → 1.2.4)
   - **minor**: the minor version changed (e.g., 1.2.3 → 1.3.0)
   - **major**: the major version changed (e.g., 1.2.3 → 2.0.0)
   - **up to date**: no change

5. **Apply patch and minor upgrades automatically**:

   For each package classified as patch or minor, use the `Edit` tool to update the version in the corresponding `package.json` file. Preserve the `^` or `~` prefix.

   Do NOT apply major upgrades. List them in the output for inclusion in the PR body.

6. **Run yarn install**:

   After all upgrades are applied, run from the repository root:

   ```bash
   yarn install
   ```

7. **Report results**:

   Output a summary with:
   - Table of applied upgrades (package, old version, new version)
   - List of skipped major upgrades (package, current version, available major version)
   - yarn install status

## Notes

- The npm registry URL for scoped packages requires URL encoding: `@scope/package` becomes `@scope%2Fpackage`
- Only check packages that match the allowed prefixes listed above
- Strip the `^` or `~` prefix from version strings when comparing
- Always preserve the `^` or `~` prefix when updating versions
- Run `yarn install` only once after all upgrades are applied, from the repository root
