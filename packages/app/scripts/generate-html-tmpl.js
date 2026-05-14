#!/usr/bin/env node
/*
 * Generates packages/app/dist/index.html.tmpl from the build output and the
 * source template (packages/app/public/index.html).
 *
 * Why this exists: @backstage/plugin-app-backend looks for `dist/index.html.tmpl`
 * to perform runtime config injection — it evaluates the lodash `<%= ... %>`
 * placeholders against the live merged config on every request and inlines a
 * `<script type="backstage.io/config">` blob the frontend reads at startup.
 *
 * The build via @janus-idp/cli only emits the fully-evaluated `dist/index.html`,
 * so without this step every `app.title` / `app.branding.*` runtime override is
 * silently ignored in the served HTML. See @backstage/plugin-app-backend
 * lib/config/injectConfigIntoHtml — when the `.tmpl` file is missing the
 * injection path no-ops.
 *
 * Strategy: re-use the original source template (which still has the `<%= %>`
 * placeholders intact) and re-insert the hashed script/stylesheet tags that
 * janus-cli appended to dist/index.html during build.
 */

const fs = require('fs');
const path = require('path');

const appDir = path.resolve(__dirname, '..');
const distHtmlPath = path.join(appDir, 'dist', 'index.html');
const publicHtmlPath = path.join(appDir, 'public', 'index.html');
const outPath = path.join(appDir, 'dist', 'index.html.tmpl');

if (!fs.existsSync(distHtmlPath)) {
  console.error(`[generate-html-tmpl] missing ${distHtmlPath} — run \`yarn build\` first`);
  process.exit(1);
}
if (!fs.existsSync(publicHtmlPath)) {
  console.error(`[generate-html-tmpl] missing ${publicHtmlPath}`);
  process.exit(1);
}

const distHtml = fs.readFileSync(distHtmlPath, 'utf8');
const publicHtml = fs.readFileSync(publicHtmlPath, 'utf8');

// Match build-injected asset tags (script src=/static/... and link href=/static/...).
// These carry content hashes, so they cannot be hard-coded in the source template.
// `<script>` is NOT a void element and requires `</script>` — capture both tags
// (with possibly-empty body) so the splice produces valid HTML. `<link>` is
// void and self-terminates.
const scriptTagRegex = /<script\b[^>]*\/static\/[^>]*?>[\s\S]*?<\/script>/g;
const linkTagRegex = /<link\b[^>]*\/static\/[^>]*?>/g;
const assetTags = [
  ...(distHtml.match(scriptTagRegex) || []),
  ...(distHtml.match(linkTagRegex) || []),
];

if (assetTags.length === 0) {
  console.error('[generate-html-tmpl] no /static/* asset tags found in dist/index.html — build output unexpected');
  process.exit(1);
}

// Insert the asset tags right before </head>, matching where janus-cli put them.
if (!publicHtml.includes('</head>')) {
  console.error('[generate-html-tmpl] public/index.html has no </head> tag — cannot splice asset tags');
  process.exit(1);
}

const tmpl = publicHtml.replace('</head>', `${assetTags.join('')}\n  </head>`);

fs.writeFileSync(outPath, tmpl);
console.log(
  `[generate-html-tmpl] wrote ${path.relative(process.cwd(), outPath)} ` +
    `(${tmpl.length} bytes, ${assetTags.length} asset tag(s) spliced)`,
);
