# devportal-base changelog


## v1.3.1 (2026-04-13)
* chore: bump Backstage 1.49.3 → 1.49.4 + tech-radar plugins (feaa86c)

## v1.2.8 (2026-03-20)
* chore: automated dependency update 2026-03-20 (#49) (12df40f)
* fix: remove RHDH-specific tests from dynamic-plugins wrapper suite (77479ee)
* docs: Enhance automated update CI prompt with detailed server readiness checks, visual assessment criteria, and validation matrix updates. (c3a4f20)
* chore: automated dependency update 2026-03-12 (#36) (312df14)
* chore: fix security vulnerabilities (#37) (d6266d4)
* fix: add missing -- separator in dev script for Turbo 2.x (424e633)

## v1.2.7 (2026-03-11)
* fix: use RELEASE_TOKEN to bypass branch protection in release workflow (8eab9fd)
* chore: optimize automated-update PR template with prompt engineering (b04dac2)
* chore: automated dependency update 2026-03-11 (#33) (a0890cb)
* chore: improve automated-update PR output with pipeline diagram (1a12658)
* feat: add catalog incremental ingestion backend module (#30) (52c2f4a)
* chore: harden security scan prompt with generic resolution safety gate (3513ed3)
* refactor: simplify release workflow to invoke make release (c1ed9f1)
* chore: harden automated-update prompt against visual regression skip (19f448b)
* feat: add release workflow (3adf18c)
* [URGENT] chore: fix security vulnerabilities (2026-03-09) (#22) (48a6234)

## v1.2.6 (2026-03-06)
* chore: automated update 2026-03-06 (#20) (42d2ebb)
* docs: add plugins.json upgrade step to dynamic plugin prompts (32c74c8)
* docs: Update automated update CI prompt to specify reverting commits by SHA instead of HEAD~N. (df25197)
* chore: automated update 2026-03-05 (#18) (818dead)
* [URGENT] chore: fix security vulnerabilities (2026-03-05) (#17) (cd3964b)
* refactor: enhance automated CI update process with baseline validation, regression resolution, and standardized output management. (7acdee3)
* feat: enhance security fix validation with baseline comparisons and regression detection in the security scan workflow. (b68dfb2)
* docs: Add output management instructions for redirecting verbose CI command output to log files in automated update and upgrade-and-test prompts. (2cbf329)
* feat: Close previous automated PRs and trigger validation checks for automated update and security workflows. (ae50616)
* chore: make commit commands explicit in the automated update CI prompt (1954b87)
* feat: include `backstage.json` in Backstage upgrade detection and version reporting, and add `git add -A` instruction for automated CI commits. (8764107)
* feat: Add `repository_dispatch` trigger to PR checks and enable status reporting for automated update PRs. (6a6f2e5)
* ci: Change automated update workflow schedule from 8 AM to 10 PM. (d304a73)
* docs: update `gh pr list` pre-flight check command in automated update and security scan prompts. (d645306)
* chore: upload visual regression screenshots as workflow artifacts (8d14cd7)
* chore: trigger CI checks (2d99038)
* chore: upgrade dynamic plugin wrappers (33f6f65)
* chore: upgrade backstage core to 1.48.3 (community plugin updates) (bb36b19)
* chore: update UBI10 base image to 10.1-1772512434 (efee0c0)
* fix: add Red Hat registry auth to CI and make RBAC path configurable (202eb56)
* feat: update GitHub workflows to use `claude_code_oauth_token` and refine Claude static plugin upgrade commands by removing specific `@backstage` modules. (3078014)
* chore: add CI agent prompts and workflows for automated maintenance (befe13f)
* devportal base image catalog item (eaebdf8)
* devportal system moved (93f4c37)
* Update Dockerfile (ac82071)

## v1.2.5 (2026-02-26)
* upgrade Backstage to 1.48.3 and add release cycle docs (f8bd980)
* consolidate catalog locations and improve keycloak config (a4da23e)

## v1.2.5 (2026-02-26)
* upgrade Backstage to 1.48.3 and add release cycle docs (f8bd980)
* consolidate catalog locations and improve keycloak config (a4da23e)

## v1.2.5 (2026-02-26)
* upgrade Backstage to 1.48.3 and add release cycle docs (f8bd980)
* consolidate catalog locations and improve keycloak config (a4da23e)
## v1.2.4 (2026-02-19)

- update UBI10 Node.js 22 base image to 10.1-1771303085 (46f02b4)
- update backstage to 1.48.1 (ad71293)

## v1.2.3 (2026-01-30)

- update backstage to 1.47.2 (8628266)

## v1.2.2 (2026-01-20)

- fix: upgraded python to 3.12 (2cf0e59)

## v1.2.1 (2026-01-20)

- version upgrade in package.json (e076c81)
- chore: update version metadata for 1.2.0 release (3671c06)
- chore: upgrade base image from UBI9 to UBI10 (62af717)

## v1.1.80 (2026-01-20)

- docs: clarify agent-browser preference over Puppeteer (ad8446a)
- docs: add agent-browser skill and documentation (e2067af)
- chore: upgrade Backstage from 1.46.3 to 1.47.0 (5a83344)
- add: statis plugins upgrade skill (66382a8)

## v1.1.79 (2026-01-18)

- fix: techradar URL allowed (d92ddbf)
- chore: upgrade dynamic plugin wrapper dependencies (b138a98)
- update: plugin-upgrade skill to apply selected upgrades (3f919bd)
- fix: peerdep from wrapper (8a3b4fd)
- add: plugin-upgrade skill for checking wrapper plugin versions (0e007fc)

## v1.1.78 (2026-01-18)

- fix: @yarnpkg/parsers/js-yaml version (d81ce5b)
- docs: add security scanning documentation and Claude Code skill references (edf659d)
- add: show plugin folder name in plugins security report (d62586a)
- fix: update resolutions for security vulnerabilities (c470ac8)
- update: fix-vulnerabilities skill to use main-report.json (d52302c)
- add: split security scan reports by main vs dynamic-plugins (ca1e59d)

## v1.1.77 (2026-01-18)

- fix: yarn lock (ce568c8)

## v1.1.76 (2026-01-18)

- add: gitkeep (f7df4f3)
- fix: remove @backstage resolutions and prevent future additions (e101e0b)

## v1.1.75 (2026-01-18)

- fix: remediate security vulnerabilities and upgrade Backstage to 1.46.3 (c1ca9d8)
- add: markdown report generator for Trivy security scans (72d797b)
- replace: Docker Scout with Trivy for security scanning (1c7af5f)

## v1.1.74 (2026-01-18)

- fix: dnf upgrade command (99ed3d2)

## v1.1.73 (2026-01-18)

- add: system package upgrade in Docker build (3976a85)
- add: Docker Scout security scan skill (bc68c71)
- add: GitLab configuration profile (8e47669)

## v1.1.72 (2026-01-12)

- add: release skill for Claude Code (0cb5e3d)
- add: local claude settings (team shared) (06765af)
- Update dynamic plugin wrapper versions (02a31be)
- Update UPGRADING.md to reference new build scripts (ad76ed0)
- Add update-base-image script and skill (48b23f5)
- Add local Docker image build script (6b40419)
- Add early exit detection to upgrade-and-test skill (e13462c)
- Add upgrade-and-test skill for Claude Code (1e5dfe3)
- Upgrade Backstage from 1.46.1 to 1.46.2 (f7a8a50)
- Add ADR-009 to ADR index (e71587b)
- Add ADR-009 documenting configuration profiles system (ae35a5d)
- Add sequential-thinking MCP server (cfc4840)
- Add Puppeteer MCP server for browser automation (e8ac1f0)
- Add Memory MCP seed data for project knowledge (6b5358a)
- Add Memory MCP server configuration (cc68653)
- docs: Add LDAP to auth providers list (cee080b)
- Update backlog: mark prettier plugin issue as fixed (4a12381)
- Add missing prettier-plugin-sort-imports dependency (#6) (66fef9c)
- Allow direct push for pure documentation changes (e2a513c)
- Add trunk-based development workflow documentation (#5) (a7a498e)
- Add Architecture Decision Records (ADRs) (ca655db)
- Add CI guardrails and documentation for agent-based development (#4) (494b217)

## v1.1.71 (2025-12-20)

- updated auth apis, improved GitHub OAuth App login (5367034)

## v1.1.70 (2025-12-19)

- moved 'support' plugin to devportal-plugins project, veecode signinpage still hidden (faf9e71)

## v1.1.69 (2025-12-19)

- fix: scalprum-backend missing devdep (721ad66)

## v1.1.68 (2025-12-19)

- moved 'about' plugins to devportal-plugins project (87852e2)

## v1.1.67 (2025-12-19)

- fix: github action caching and yarn version (87139e6)

## v1.1.66 (2025-12-19)

- upd veecode metadata (6346a23)
- fix: tsconfig missing (94417b9)

## v1.1.65 (2025-12-19)

- fix: tsconfig missing (7740fc3)

## v1.1.64 (2025-12-19)

- upgrade to backstage 1.46.1 (0350db2)

## v1.1.63 (2025-12-16)

- update base image and yarn version (32a5bf2)

## v1.1.62 (2025-12-16)

- fix: requirements-build files (9420900)

## v1.1.61 (2025-12-16)

- fix: python vuln. (urllib) (1d93d32)
- feat: support base64 pk encoding (eb88996)

## v1.1.60 (2025-12-14)

- add: ldap profile, optional oauth id/secret for github auth only (db2eb80)

## v1.1.59 (2025-12-12)

- fix: updated ldap auth plugin to veecode fork (3b24a4d)
- updated packages in dynamic-plugins/package.json (cec0fb9)
- updated yarn and backstage to 1.45.x (5a656b0)

## v1.1.58 (2025-12-11)

- updated base ubi image (2c5c3df)

## v1.1.57 (2025-12-11)

- add: ldap login support (limited), ldap org support (fda7cb6)

## v1.1.56 (2025-11-15)

- add: kubectl bin (eea8ed2)

## v1.1.55 (2025-11-14)

- fix: @kubernetes/client-node pinned to 1.4.0, struggling with CA and KUBECONFIG (86d421d)

## v1.1.54 (2025-11-14)

- release 1.1.54 (5a875c1)

## v1.1.53 (2025-11-14)

- fix: @kubernetes/client-node pinned to 1.1.2, newer fails kubeconfig with good CA when self signed (8a22acc)

## v1.1.52 (2025-11-11)

## v1.1.51 (2025-11-11)

## v1.1.49 (2025-11-11)

## v1.1.47 (2025-11-11)

## v1.1.46 (2025-11-11)

- fix: Makefile release (676d051)

## v1.1.45 (2025-11-11)

- fix: Makefile release (22930f5)

## v1.1.43 (2025-11-11)

- add: release Makefile tasks (2c463b1)
- add: bundled Kong deck CLI (a826584)
- add: kubernetes default policies (4e4080e)
