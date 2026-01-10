# ADR-009: Configuration Profiles

## Status

Accepted

## Context

DevPortal deployments typically require different authentication providers and integrations depending on the organization. Common setups include:

- GitHub OAuth + GitHub App integration
- Keycloak/OIDC for enterprise SSO
- Azure AD/Microsoft for Microsoft-centric organizations
- LDAP for legacy enterprise directories

Each setup requires specific configuration blocks for authentication, catalog providers, and integrations. Manually composing these configurations is error-prone and repetitive.

Backstage supports loading multiple `--config` files that merge in order (later files override earlier ones). We can leverage this to create pre-packaged configuration "profiles" that users activate with a single environment variable.

## Decision

Implement a profile system using bundled `app-config.*.yaml` files and a startup script that conditionally includes them.

### Profile Structure

Base configuration files (always loaded in order):

1. `app-config.yaml` - Core settings, guest auth fallback, local SQLite
2. `app-config.production.yaml` - Container paths, production database
3. `app-config.dynamic-plugins.yaml` - Dynamic plugin configurations

Profile-specific files (loaded based on `VEECODE_PROFILE`):

| Profile    | Config File                | Purpose                                       |
| ---------- | -------------------------- | --------------------------------------------- |
| `github`   | `app-config.github.yaml`   | GitHub OAuth, GitHub App, GitHub org provider |
| `keycloak` | `app-config.keycloak.yaml` | OIDC auth, Keycloak org provider              |
| `azure`    | `app-config.azure.yaml`    | Microsoft auth, Azure DevOps, MS Graph org    |
| `ldap`     | `app-config.ldap.yaml`     | LDAP auth, LDAP org provider                  |
| `local`    | `app-config.local.yaml`    | Developer overrides (gitignored)              |

### Startup Script

The `scripts/start-base.sh` script:

1. Builds the base config chain
2. Reads `VEECODE_PROFILE` environment variable
3. Appends the matching profile config file
4. Executes node with the complete config chain

```bash
CONFIGS="--config app-config.yaml --config app-config.production.yaml ..."

case "$VEECODE_PROFILE" in
  github)
    CONFIGS="$CONFIGS --config app-config.github.yaml"
    ;;
  keycloak)
    CONFIGS="$CONFIGS --config app-config.keycloak.yaml"
    ;;
  # ... etc
esac

exec node packages/backend $CONFIGS
```

### Profile Configs Use Environment Variables

Each profile config references environment variables for secrets and org-specific values. For example, `app-config.github.yaml` uses:

- `GITHUB_AUTH_CLIENT_ID`, `GITHUB_AUTH_CLIENT_SECRET` - OAuth credentials
- `GITHUB_APP_ID`, `GITHUB_CLIENT_ID`, `GITHUB_PRIVATE_KEY` - GitHub App
- `GITHUB_ORG` - Organization for catalog discovery

This separation means:

- **Profile files** are checked into the repo (reusable templates)
- **Secrets and org values** come from environment (deployment-specific)

### Profile Contents

Each profile typically configures:

1. **signInPage** - Which sign-in page to show (`github`, `keycloak`, `microsoft`, `ldap`)
2. **auth.providers** - Authentication provider settings with sign-in resolvers
3. **integrations** - SCM/API integrations (GitHub App, Azure token, etc.)
4. **catalog.providers** - Org data import (users, groups, repositories)

## Consequences

### Benefits

- **One-variable setup**: `VEECODE_PROFILE=github` enables a complete GitHub integration
- **Tested configurations**: Profile files are maintained and tested together
- **Clear documentation**: Each profile is self-documenting via its config file
- **Composable**: Profiles can be combined with `app-config.local.yaml` for tweaks
- **No rebuild required**: Change profile by changing an environment variable

### Drawbacks

- **Fixed set of profiles**: Custom auth setups require creating new profile files or using `local`
- **Profile maintenance**: Each profile must be updated when Backstage auth APIs change
- **Single profile limit**: Cannot easily combine multiple profiles (e.g., GitHub + LDAP)

### Related Files

- `scripts/start-base.sh` - Profile selection logic
- `packages/backend/Dockerfile` - Container entrypoint
- `app-config.github.yaml` - GitHub profile
- `app-config.keycloak.yaml` - Keycloak profile
- `app-config.azure.yaml` - Azure profile
- `app-config.ldap.yaml` - LDAP profile
