# devportal-base changelog

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
