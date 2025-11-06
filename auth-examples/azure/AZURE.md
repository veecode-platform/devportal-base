# Azure Authentication Setup Guide

This guide explains how to set up Microsoft Entra ID authentication for your DevPortal, similar to the GitHub and Keycloak authentication setups.

## Overview

Azure authentication is implemented using the Microsoft OAuth provider in Backstage. The configuration follows the same pattern as the other authentication providers and includes Azure DevOps catalog integration.

## Prerequisites

1. A Microsoft Entra ID tenant (formerly Azure AD)
2. Azure DevOps organization
3. Appropriate permissions to register applications in Microsoft Entra ID

## Microsoft Entra ID Configuration

### 1. Register Microsoft Entra ID Application

1. Navigate to **Azure Portal** → **Microsoft Entra ID** → **App registrations** → **New registration**
2. Set the following:
   - **Name**: `DevPortal` (or your preferred name)
   - **Supported account types**: Choose appropriate option for your organization
   - **Redirect URI**:
     - Select **Web**
     - Add: `http://localhost:3000/api/auth/microsoft/handler/frame`
     - Add: `http://localhost:7007/api/auth/microsoft/handler/frame`
     - Add your production URLs as well

3. After registration, note the **Application (client) ID** and **Directory (tenant) ID**

### 2. Configure Client Secret

1. Go to **Certificates & secrets** → **New client secret**
2. Add a description and choose expiry period
3. Copy the secret value immediately (it won't be visible later)

### 3. Configure API Permissions

1. Go to **API permissions** → **Add a permission**

2. **For User Authentication (Delegated permissions)**:
   - Select **Microsoft Graph** → **Delegated permissions**
   - Add the following permissions:
     - `User.Read` - Read user profile
     - `email` - View user's email address
     - `openid` - Sign user in
     - `profile` - Access user's profile

3. **For Catalog Synchronization (Application permissions)**:
   - Select **Microsoft Graph** → **Application permissions**
   - Add the following permissions:
     - `User.Read.All` - Read all users' profiles
     - `Group.Read.All` - Read all groups
     - `Directory.Read.All` - Read directory data (alternative to above)

4. **Grant Admin Consent**:
   - Click **"Grant admin consent for [Your Tenant]"**
   - Confirm the consent dialog
   - Wait for all permissions to show **"Granted"** status with green checkmarks

**Important**: Both Delegated and Application permissions require admin consent to activate.

### 4. Configure Azure DevOps Access

1. Navigate to your Azure DevOps organization
2. Go to **Organization Settings** → **Users** and ensure the Microsoft Entra ID users have access
3. For catalog synchronization, the application needs appropriate permissions:
   - Project and Team read access
   - Code read access
   - Work Item read access

## Starting the Application

Set the following environment variables:

```bash
# Azure Configuration
VEECODE_PROFILE=azure
# Microsoft Entra ID Configuration
AZURE_CLIENT_ID=your-application-client-id-here
AZURE_CLIENT_SECRET=your-client-secret-here
AZURE_TENANT_ID=your-tenant-id-here
# Azure DevOps Configuration
AZURE_ORGANIZATION=your-azure-devops-organization
AZURE_PROJECT=your-project-name  # Optional, can sync entire organization
# Authentication
AUTH_SESSION_SECRET=your-session-secret-here
```

Start the application with the Azure configuration:

```bash
# Using the provided script
./scripts/start-base.sh azure
```

## Configuration Details

The `app-config.azure.yaml` file contains placeholders for both auth provider and catalog provider. The application will honor the VEECODE_PROFILE variable and merge this file with the other app-config files.

### Authentication Flow

1. Users are redirected to Microsoft Entra ID for authentication
2. Upon successful authentication, Microsoft Entra ID returns an ID token
3. Backstage validates the token and creates a user session
4. User identity is resolved using email-based resolvers

### Catalog Synchronization

The Azure DevOps catalog provider will synchronize:

- Projects and teams
- Repositories
- Users and their memberships
- Work item configurations

Note: You may disable the catalog provider and configure users and groups "manually" in catalog files if you prefer.

## More on Catalog Sync

There are probably a few more things to configure, but this is a good starting point.

- Some settings may be incomplete, specially regarding the Entra Application registration
 and permissions.
- You can always fall back to a PAT token in the integration settings if you prefer.
- Repository sync also depends on "Code Search" extension to be configured in the organization.

## Additional Resources

- [Backstage Microsoft Auth Provider Documentation](https://backstage.io/docs/auth/microsoft/provider)
- [Microsoft Entra ID App Registration Documentation](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-registrations)
- [Azure DevOps REST API Documentation](https://docs.microsoft.com/en-us/rest/api/azure/devops/)
- [RHDH Azure Integration](https://github.com/redhat-developer/rhdh/blob/main/docs/auth.md)

## Plugins involved

All these plugins are currently statically loaded, this list is just informative:

- [Microsoft Entra ID Auth Provider](https://backstage.io/docs/auth/microsoft/provider)
  - Plugin @backstage/plugin-auth-backend-module-microsoft-provider
- [Azure DevOps Catalog Provider](https://backstage.io/docs/integrations/azure/discovery/)
  - Plugin @backstage/plugin-catalog-backend-module-azure
- [Microsoft Graph Org Catalog Provider](https://backstage.io/docs/integrations/azure/org)
  - Plugin @backstage/plugin-catalog-backend-module-msgraph
- [Azure DevOps Scaffolder Actions](https://www.npmjs.com/package/@backstage-community/plugin-scaffolder-backend-module-azure-devops)
  - Plugin @backstage-community/plugin-scaffolder-backend-module-azure-devops
