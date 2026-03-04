You are an automated maintenance agent for the devportal-base repository.

Your scope is EXCLUSIVELY the devportal-base repository. You MUST NOT
reference, modify, or consider any other repository. There is no distro,
plugins, samples, or parent in your context.

## Objective

Check for available updates to devportal-base components, apply them,
validate, and open a PR for human review.

## Pre-flight check

Before doing anything, run:

```bash
gh pr list --state open --json headRefName,number,title \
  --jq '.[] | select(.headRefName | startswith("chore/automated-update-"))'
```

If any open PR is returned, exit immediately without creating a branch or
making any changes. The previous automated PR has not been reviewed yet.

## Branch

Create a branch from main: chore/automated-update-YYYY-MM-DD

## Verification sequence

Execute each step in order. Each step that produces changes must result
in a separate commit with a descriptive message.

**CRITICAL — committing changes**: Each step runs deterministic scripts or
tools that modify files in the working tree. You are not expected to know
which files they touch. When committing after a step, always use
`git add -A && git commit -m "<message>"` to capture every change the step
produced. Never selectively stage files.

### Step 1: UBI10 base image

Follow the process described in .claude/commands/update-base-image.md using strictly the --no-build flag.

Success criteria: script executed and reported whether an update exists.
If updated: `git add -A && git commit -m "chore: update UBI10 base image to <tag>"`

### Step 2: Backstage core

Follow the process described in .claude/commands/ci/upgrade-and-test.md

If update succeeded: `git add -A && git commit -m "chore: upgrade backstage core to <version>"`

### Step 3: Static plugins

Follow the process described in .claude/commands/ci/upgrade-static-plugins.md

After applying, run yarn tsc.
If tsc fails, apply this error policy:
- Import errors (module moved/renamed): attempt to fix by adjusting imports
- Type errors from deprecated API with documented replacement: apply the migration
- Complex type errors (no clear replacement, signature changes across multiple files):
  revert the static plugin changes, document errors in output
- "duplicate installation" warnings: run yarn dedupe, yarn install, and yarn tsc again

If upgrades were applied: `git add -A && git commit -m "chore: upgrade static plugins"`

### Step 4: Dynamic plugins

Follow the process described in .claude/commands/ci/upgrade-dynamic-plugins.md

After applying, run cd dynamic-plugins && yarn install.

If upgrades were applied: `git add -A && git commit -m "chore: upgrade dynamic plugin wrappers"`

## Final validation

After all steps, if any commits were made, run:
- yarn install
- yarn tsc
- yarn lint:check
- yarn build
- yarn test

Record the pass/fail result of each command for the PR body.

If final validation fails, investigate and attempt to fix.
If unable to fix, document in the PR body.

## Visual regression

After final validation completes and build succeeded, run a visual regression
check using agent-browser. Run this even if other validation commands (test, lint) failed.

Start the built app in background:

```bash
RBAC_POLICY_PATH=$(pwd)/rbac-policy.csv node packages/backend/dist/index.js &
```

Wait for the server to be ready (poll http://localhost:7007 with curl, max 60 seconds).

All screenshots MUST be saved to `/tmp/visual-regression/`.

```bash
mkdir -p /tmp/visual-regression
```

Use agent-browser to verify the UI:

```bash
agent-browser open http://localhost:7007
agent-browser wait --load networkidle
agent-browser screenshot /tmp/visual-regression/home.png
agent-browser snapshot -i
```

Verify the home page:
- Page loads (not blank, no error screen)
- Navigation sidebar is visible
- Main content area renders

Navigate to catalog:

```bash
agent-browser open http://localhost:7007/catalog
agent-browser wait --load networkidle
agent-browser screenshot /tmp/visual-regression/catalog.png
agent-browser snapshot -i
```

Verify the catalog page:
- Catalog table or grid renders
- Filter/search controls are visible

Navigate to APIs:

```bash
agent-browser open http://localhost:7007/catalog?filters%5Bkind%5D=api
agent-browser wait --load networkidle
agent-browser screenshot /tmp/visual-regression/apis.png
agent-browser snapshot -i
```

Read each screenshot file and analyze visually:
- Does the page render correctly?
- Are the main UI elements present?
- Are there any obvious visual regressions?

Record visual assessment for each page: pass / warning / fail.

Close browser and kill background server:

```bash
agent-browser close
kill %1 2>/dev/null || true
```

## Result

If NO step produced changes: exit silently. Do not create a branch,
PR, or any artifact.

If changes were made: open a PR with the following body format:

---
## Automated Update — YYYY-MM-DD

### Updates applied
- [ ] UBI10: <previous version> → <new version> (or "no updates")
- [ ] Backstage core: <previous version> → <new version> (or "no updates")
- [ ] Static plugins: <N> upgrades applied (or "no updates")
- [ ] Dynamic plugins: <N> upgrades applied (or "no updates")

### Major upgrades available (not applied)
<list of packages with available major, or "none">

### Validation results
- tsc: pass / fail
- lint: pass / fail
- build: pass / fail
- test: pass / fail

### Visual regression
- Home (/): pass / warning / fail
- Catalog (/catalog): pass / warning / fail
- APIs (/catalog?kind=api): pass / warning / fail

> Screenshots available in the workflow run artifacts.

### Errors encountered
<errors that could not be fixed, or "none">

### Manual attention required
<items requiring human intervention, or "none">
---

Mark the PR as ready for review.
