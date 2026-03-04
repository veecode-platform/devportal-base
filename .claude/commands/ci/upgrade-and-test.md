# Backstage Upgrade with Automated Validation

Perform a Backstage upgrade cycle with build validation.
This is the CI version — no interactive dev server, no Puppeteer, no manual
validation. Visual regression is handled separately by the orchestrator prompt.

## Steps

1. **Run the upgrade**:

   ```bash
   yarn update-backstage
   ```

2. **Check for actual upgrades**:

   ```bash
   git status --porcelain backstage.json '**/package.json'
   ```

   If no files were modified, exit early with: "No Backstage upgrade available. All packages are already at the latest version." Skip all remaining steps.

3. **Install dependencies**:

   ```bash
   yarn install
   ```

4. **Type check**:

   ```bash
   yarn tsc
   ```

   If there are warnings of "duplicate installation" of packages:
   - Note the warning in the output
   - Run `yarn dedupe`
   - Run `yarn install` and `yarn tsc` again

5. **Build**:

   ```bash
   yarn build
   ```

   Success criteria: both `yarn tsc` and `yarn build` exit with code 0.

6. **Report results**:

   Output a summary with:
   - Previous and new Backstage version (read from `backstage.json` before and after)
   - yarn tsc: pass / fail
   - yarn build: pass / fail
   - Any duplicate installation warnings encountered

## Error Policy

- Import errors (module moved/renamed): attempt to fix by adjusting imports
- Type errors from deprecated API with documented replacement: apply the migration
- Complex type errors (types removed with no clear replacement, signature changes
  across multiple files): ABORT, revert Backstage changes, document errors in output
- "duplicate installation" warnings: run yarn dedupe, yarn install, and yarn tsc again
