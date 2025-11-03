# Keycloak Authentication Setup Guide

This guide explains how to set up Keycloak authentication for your DevPortal, similar to the GitHub authentication setup.

## Overview

Keycloak authentication is implemented using the OIDC (OpenID Connect) provider in Backstage. The configuration follows the same pattern as the GitHub authentication setup.

## Prerequisites

1. A running Keycloak instance
2. A Keycloak realm configured for your organization
3. A Keycloak client created for Backstage

## Keycloak Configuration

### 1. Create a Keycloak Client

In your Keycloak realm:

1. Navigate to **Clients** → **Create**
2. Set the following:
   - **Client ID**: `veecode` (or your preferred name)
   - **Client Protocol**: `openid-connect`
   - **Access Type**: `confidential`
   - **Valid Redirect URIs**:
     - `http://localhost:3000/api/auth/oidc/handler/frame`
     - `http://localhost:7007/api/auth/oidc/handler/frame`
     - Add your production URLs as well
   - **Web Origins**: `http://localhost:3000` (and your production URL)

3. After saving, go to the **Credentials** tab to get your **Client Secret**

### 2. Configure Keycloak Client Scopes

Ensure the following scopes are available (usually by default):

- `profile`
- `email`

### 3. Create Keycloak Users

Create users and groups in Keycloak freely.

The sign-in resolvers and catalog providers will try to match and sync users and groups from the realm to Backstage users and groups:

1. Keycloak username to a Backstage user
2. Keycloak groups to Backstage groups
3. Keycloak user profile's fields to Backstage user profile data

Please understand that authentication and user/group sync happen at different moments. You may login with a valid credential that has not been synced to Backstage yet.

## Starting the Application

You should set the following environment variables:

```bash
# Keycloak Configuration
VEECODE_PROFILE=keycloak
# Keycloak base URL (without "/auth")
KEYCLOAK_BASE_URL=https://your-keycloak-instance.com
KEYCLOAK_REALM=your-realm-name
KEYCLOAK_CLIENT_ID=your-client-id-here
KEYCLOAK_CLIENT_SECRET=your-client-secret-here
```

Start the application with the Keycloak configuration:

```bash
# Using the provided script
./scripts/start-base.sh keycloak
```

## Configuration Details

The `app-config.keycloak.yaml` file contains placeholders for both auth provider and catalog provider. The image will honor the VEECODE_PROFILE variable and merge this file with the other app-config files.

Note: you may disable the catalog provider and configure users and groups "manually" in catalog files if you prefer.

## Additional Resources

- [Backstage OIDC Auth Provider Documentation](https://backstage.io/docs/auth/oidc/provider)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [RHDH Keycloak Integration](https://github.com/redhat-developer/rhdh/blob/main/docs/auth.md)
