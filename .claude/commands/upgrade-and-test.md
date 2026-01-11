Perform a Backstage upgrade cycle with UI verification:

1. Run `yarn update-backstage` to upgrade Backstage core and related packages
2. Run `yarn install` to update dependencies
3. Run `yarn tsc` to check for type errors
4. Start the dev server with `yarn dev-local` in background
5. Wait for the server to be ready (check <http://localhost:3000> and <http://localhost:7007>)
6. Use Puppeteer to take screenshots and verify:
   - Home page loads correctly
   - Navigation sidebar is visible
   - Catalog page works
   - No critical console errors
7. Report results with screenshots
8. Stop the background server when done
