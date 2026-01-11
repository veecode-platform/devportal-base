Perform a Backstage upgrade cycle with UI verification:

1. Run `yarn update-backstage` to upgrade Backstage core and related packages
2. **Check for actual upgrades**: Run `git status --porcelain '**/package.json'` to see if any package.json files were modified. If no package.json files were modified, exit early with a message like "No Backstage upgrade available. All packages are already at the latest version." and skip all remaining steps.
3. Run `yarn install` to update dependencies
4. Run `yarn tsc` to check for type errors
5. Start the dev server with `yarn dev-local` in background
6. Wait for the server to be ready (check <http://localhost:3000> and <http://localhost:7007>)
7. Use Puppeteer to take screenshots and verify:
   - Home page loads correctly
   - Navigation sidebar is visible
   - Catalog page works
   - No critical console errors
8. Report results with screenshots
9. Stop the background server when done
