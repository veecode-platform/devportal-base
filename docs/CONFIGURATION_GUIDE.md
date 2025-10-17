# Configuration Guide

## Overview

Backstage uses a hierarchical YAML-based configuration system. Configuration files are merged in order, with later files overriding earlier ones.

## Configuration Files

### File Hierarchy (Load Order)

1. **`app-config.yaml`** - Base configuration (committed to git)
2. **`app-config.production.yaml`** - Production overrides (committed to git)
3. **`app-config.local.yaml`** - Local development (gitignored)
4. **Environment variables** - Runtime overrides

### Templates

- **`app-config.local.template.yaml`** - Template for local development
- **`app-config.dynamic-plugins.local.template.yaml`** - Template for dynamic plugins

## Core Configuration Sections

### App Configuration

```yaml
app:
  title: Developer Portal
  baseUrl: http://localhost:3000
  
  # Optional: Custom branding
  branding:
    theme:
      light:
        primaryColor: '#1976d2'
      dark:
        primaryColor: '#90caf9'
```

### Backend Configuration

```yaml
backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
    host: 0.0.0.0
  
  # CORS configuration
  cors:
    origin: http://localhost:3000
    methods: [GET, HEAD, PATCH, POST, PUT, DELETE]
    credentials: true
  
  # Database configuration
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      database: ${POSTGRES_DB}
    
    # Alternative: SQLite for development
    # client: better-sqlite3
    # connection: ':memory:'
  
  # Cache configuration
  cache:
    store: memory
    # Or use Redis
    # store: redis
    # connection: redis://localhost:6379
  
  # Reading configuration
  reading:
    allow:
      - host: '*.github.com'
      - host: '*.gitlab.com'
```

### Organization Configuration

```yaml
organization:
  name: My Company
```

### Catalog Configuration

```yaml
catalog:
  # Import locations
  locations:
    - type: file
      target: ./examples/entities.yaml
    
    - type: url
      target: https://github.com/org/repo/blob/main/catalog-info.yaml
    
    - type: url
      target: https://github.com/org/repo/blob/main/*/catalog-info.yaml
      rules:
        - allow: [Component, API, System, Domain, Resource]
  
  # Catalog rules
  rules:
    - allow: [Component, System, API, Resource, Location, User, Group, Template]
  
  # Processors
  processors:
    githubOrg:
      providers:
        - target: https://github.com
          apiBaseUrl: https://api.github.com
          token: ${GITHUB_TOKEN}
```

### Authentication Configuration

#### GitHub OAuth

```yaml
auth:
  environment: development
  providers:
    github:
      development:
        clientId: ${GITHUB_CLIENT_ID}
        clientSecret: ${GITHUB_CLIENT_SECRET}
        
        # Optional: Enterprise
        # enterpriseInstanceUrl: https://github.mycompany.com
```

#### Google OAuth

```yaml
auth:
  providers:
    google:
      development:
        clientId: ${GOOGLE_CLIENT_ID}
        clientSecret: ${GOOGLE_CLIENT_SECRET}
```

#### Guest Authentication (Development)

```yaml
auth:
  providers:
    guest:
      dangerouslyAllowOutsideDevelopment: true
```

### Integrations Configuration

```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
      
      # Optional: Apps authentication
      # apps:
      #   - appId: ${GITHUB_APP_ID}
      #     clientId: ${GITHUB_APP_CLIENT_ID}
      #     clientSecret: ${GITHUB_APP_CLIENT_SECRET}
      #     webhookSecret: ${GITHUB_APP_WEBHOOK_SECRET}
      #     privateKey: ${GITHUB_APP_PRIVATE_KEY}
  
  gitlab:
    - host: gitlab.com
      token: ${GITLAB_TOKEN}
  
  bitbucket:
    - host: bitbucket.org
      username: ${BITBUCKET_USERNAME}
      appPassword: ${BITBUCKET_APP_PASSWORD}
```

### Proxy Configuration

```yaml
proxy:
  '/my-api':
    target: https://api.example.com
    headers:
      Authorization: Bearer ${API_TOKEN}
    
    # Optional: Path rewrite
    # pathRewrite:
    #   '^/api/proxy/my-api': '/'
    
    # Optional: Change origin
    # changeOrigin: true
```

### TechDocs Configuration

```yaml
techdocs:
  builder: 'local'
  generator:
    runIn: 'local'
  publisher:
    type: 'local'
    
  # Or use external storage
  # publisher:
  #   type: 'awsS3'
  #   awsS3:
  #     bucketName: ${TECHDOCS_S3_BUCKET}
  #     region: ${AWS_REGION}
  #     credentials:
  #       accessKeyId: ${AWS_ACCESS_KEY_ID}
  #       secretAccessKey: ${AWS_SECRET_ACCESS_KEY}
```

### Search Configuration

```yaml
search:
  pg:
    highlightOptions:
      useHighlight: true
      maxWord: 35
      minWord: 3
      shortWord: 3
      highlightAll: false
      maxFragments: 0
      fragmentDelimiter: ' ... '
  
  # Or use Elasticsearch
  # elasticsearch:
  #   provider: elastic
  #   node: http://localhost:9200
  #   auth:
  #     username: elastic
  #     password: ${ELASTICSEARCH_PASSWORD}
```

### Kubernetes Configuration

```yaml
kubernetes:
  serviceLocatorMethod:
    type: 'multiTenant'
  clusterLocatorMethods:
    - type: 'config'
      clusters:
        - url: ${K8S_CLUSTER_URL}
          name: production
          authProvider: 'serviceAccount'
          serviceAccountToken: ${K8S_TOKEN}
          skipTLSVerify: false
          caData: ${K8S_CA_DATA}
```

### Scaffolder Configuration

```yaml
scaffolder:
  defaultAuthor:
    name: Scaffolder
    email: scaffolder@example.com
  
  defaultCommitMessage: 'Initial commit'
  
  # Custom actions
  # actions:
  #   - id: custom:action
  #     handler: ./custom-action
```

### Permission Configuration

```yaml
permission:
  enabled: true
  
backend:
  # RBAC policy file
  rbac:
    policyFile: ./rbac-policy.csv
    
    # Or use external policy
    # policyFileReload: true
    # admin:
    #   users:
    #     - name: user:default/admin
```

## Environment Variables

### Using Environment Variables

```yaml
# In configuration file
database:
  connection:
    password: ${POSTGRES_PASSWORD}

# Set in environment
export POSTGRES_PASSWORD=secret

# Or in .env file (development only)
POSTGRES_PASSWORD=secret
```

### Common Environment Variables

```bash
# Database
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secret
POSTGRES_DB=backstage

# Authentication
GITHUB_TOKEN=ghp_xxxxx
GITHUB_CLIENT_ID=xxxxx
GITHUB_CLIENT_SECRET=xxxxx

# Backend
BACKEND_SECRET=xxxxx  # For session encryption

# Node
NODE_ENV=development
LOG_LEVEL=debug
```

### Environment Variable Substitution

**Default values**:

```yaml
database:
  connection:
    host: ${POSTGRES_HOST:-localhost}
    port: ${POSTGRES_PORT:-5432}
```

**Required variables**:

```yaml
github:
  token: ${GITHUB_TOKEN}  # Will error if not set
```

## Dynamic Plugins Configuration

### Frontend Dynamic Plugins

```yaml
dynamicPlugins:
  frontend:
    internal.plugin-example:
      dynamicRoutes:
        - path: /example
          importName: ExamplePage
          menuItem:
            text: Example
            icon: ExtensionIcon
      
      mountPoints:
        - mountPoint: entity.page.overview/cards
          importName: ExampleCard
          config:
            layout:
              gridColumnEnd:
                lg: span 6
```

### Backend Dynamic Plugins

```yaml
dynamicPlugins:
  backend:
    - package: '@backstage/plugin-catalog-backend-dynamic'
      disabled: false
      pluginConfig:
        # Plugin-specific configuration
```

## Local Development Configuration

### app-config.local.yaml Example

```yaml
app:
  baseUrl: http://localhost:3000

backend:
  baseUrl: http://localhost:7007
  database:
    client: better-sqlite3
    connection: ':memory:'

auth:
  providers:
    github:
      development:
        clientId: ${GITHUB_CLIENT_ID}
        clientSecret: ${GITHUB_CLIENT_SECRET}

integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}

catalog:
  locations:
    - type: file
      target: ./examples/entities.yaml
```

## Production Configuration

### app-config.production.yaml Example

```yaml
app:
  baseUrl: https://portal.company.com

backend:
  baseUrl: https://portal.company.com/api
  listen:
    port: 7007
    host: 0.0.0.0
  
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      database: ${POSTGRES_DB}
      ssl:
        rejectUnauthorized: true
        ca: ${POSTGRES_CA_CERT}
  
  cors:
    origin: https://portal.company.com

auth:
  environment: production
  providers:
    github:
      production:
        clientId: ${GITHUB_CLIENT_ID}
        clientSecret: ${GITHUB_CLIENT_SECRET}

techdocs:
  publisher:
    type: 'awsS3'
    awsS3:
      bucketName: ${TECHDOCS_S3_BUCKET}
      region: ${AWS_REGION}
```

## Configuration Validation

### Check Configuration

```bash
# Validate configuration
yarn backstage-cli config:check

# Print merged configuration
yarn backstage-cli config:print

# Print specific key
yarn backstage-cli config:print --key backend.database
```

### Schema Validation

Configuration is validated against JSON schemas defined in plugins.

## Security Best Practices

### Secrets Management

1. **Never commit secrets** to git
2. **Use environment variables** for sensitive data
3. **Use secret managers** in production (AWS Secrets Manager, Vault)
4. **Rotate credentials** regularly
5. **Use least privilege** for service accounts

### Example: Using AWS Secrets Manager

```yaml
backend:
  database:
    connection:
      password: ${AWS_SECRET:database-password}
```

### Example: Using Kubernetes Secrets

```yaml
# In deployment
env:
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: postgres-secret
        key: password
```

## Troubleshooting

### Configuration Not Loading

1. Check file names match exactly
2. Verify YAML syntax (use linter)
3. Check environment variables are set
4. Use `config:print` to debug

### Environment Variables Not Working

1. Verify variable is exported
2. Check for typos in variable name
3. Ensure proper substitution syntax: `${VAR}`
4. Check if default value needed: `${VAR:-default}`

### Database Connection Issues

1. Verify credentials
2. Check network connectivity
3. Ensure database exists
4. Check SSL/TLS settings
5. Review firewall rules

### CORS Errors

1. Verify `backend.cors.origin` matches frontend URL
2. Check `credentials: true` if using auth
3. Ensure methods include required HTTP verbs
4. Check for trailing slashes in URLs

## Advanced Configuration

### Multi-Environment Setup

```yaml
# app-config.yaml (base)
app:
  title: Developer Portal

# app-config.staging.yaml
app:
  baseUrl: https://staging.portal.com

# app-config.production.yaml
app:
  baseUrl: https://portal.com

# Load specific config
yarn start --config app-config.yaml --config app-config.staging.yaml
```

### Configuration Includes

```yaml
# app-config.yaml
$include: ./config/base.yaml

backend:
  $include: ./config/backend.yaml
```

### Conditional Configuration

```yaml
backend:
  database:
    $if: production
    client: pg
    $else:
    client: better-sqlite3
```

## Configuration Reference

### Full Example

See `app-config.yaml` in repository root for complete example with all available options.

### Official Documentation

- Backstage Configuration: https://backstage.io/docs/conf/
- Writing Configuration: https://backstage.io/docs/conf/writing
- Reading Configuration: https://backstage.io/docs/conf/reading
