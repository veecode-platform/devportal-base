# Azure Local Setup

You can run a local Azure DevOps instance for testing using Azure DevOps Server, or use Azure DevOps Services (cloud) with a free trial organization.

## Option 1: Azure DevOps Services (Recommended)

1. Create a free Azure DevOps organization at [https://azure.microsoft.com/en-us/services/devops/](https://azure.microsoft.com/en-us/services/devops/)
2. Follow the AZURE.md guide to register an Azure AD application
3. Configure your environment variables

## Option 2: Azure DevOps Server (Local)

For local testing, you can install Azure DevOps Server:

```bash
# Download and install Azure DevOps Server
# Follow Microsoft's installation guide
# Configure with your local Active Directory or Azure AD Connect
```

## Running DevPortal and Azure Locally in a Container

Start DevPortal with Azure configuration:

```bash
docker run --name devportal -d -p 7007:7007 \
  -e VEECODE_PROFILE=azure \
  --env AZURE_CLIENT_ID \
  --env AZURE_CLIENT_SECRET \
  --env AZURE_TENANT_ID \
  --env AZURE_ORGANIZATION \
  --env AZURE_PROJECT \
  --env AUTH_SESSION_SECRET \
  veecode/devportal-base:latest
```

## Environment Setup Script

Create a `.env` file with your Azure configuration:

```bash
# Azure AD Configuration
AZURE_CLIENT_ID=your-application-client-id-here
AZURE_CLIENT_SECRET=your-client-secret-here
AZURE_TENANT_ID=your-tenant-id-here

# Azure DevOps Configuration
AZURE_ORGANIZATION=your-azure-devops-organization
AZURE_PROJECT=your-project-name

# Authentication
AUTH_SESSION_SECRET=your-session-secret-here

# Profile
VEECODE_PROFILE=azure
```

Then run with:

```bash
docker run --name devportal -d -p 7007:7007 \
  --env-file .env \
  veecode/devportal-base:latest
```

## Testing the Setup

1. Navigate to `http://localhost:7007`
2. Click "Sign In" - you should be redirected to Azure AD
3. Authenticate with your Azure AD credentials
4. After successful authentication, you should be redirected back to DevPortal
5. Check the catalog to see synchronized Azure DevOps projects and repositories

## Troubleshooting

### Common Issues

1. **Redirect URI Mismatch**: Ensure the redirect URI in Azure AD matches your local URL
2. **Insufficient Permissions**: Make sure the Azure AD app has the required API permissions
3. **Catalog Sync Issues**: Verify Azure DevOps organization access and credentials

### Debug Mode

Enable debug logging to troubleshoot issues:

```bash
docker run --name devportal -d -p 7007:7007 \
  -e VEECODE_PROFILE=azure \
  -e LOG_LEVEL=debug \
  --env-file .env \
  veecode/devportal-base:latest
```

### Local Development

For local development without Docker:

```bash
# Set environment variables
export VEECODE_PROFILE=azure
export AZURE_CLIENT_ID=your-client-id
export AZURE_CLIENT_SECRET=your-client-secret
export AZURE_TENANT_ID=your-tenant-id
export AZURE_ORGANIZATION=your-org
export AZURE_PROJECT=your-project
export AUTH_SESSION_SECRET=your-secret

# Start the application
yarn dev
```
