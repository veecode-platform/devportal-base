# Role-Based Access Control (RBAC) Configuration

This document explains the RBAC setup for VeeCode DevPortal.

## Overview

RBAC is enabled and configured to control access to various features and resources in the platform. The permission system uses roles to group permissions and assigns these roles to users and groups.

## Configuration Files

### 1. `app-config.yaml`

Main RBAC configuration:

```yaml
permission:
  enabled: true
  rbac:
    policies-csv-file: ./rbac-policy.csv
    pluginsWithPermission:
      - catalog
      - scaffolder
      - permission
    admin:
      users:
        - name: group:default/admins
      superUsers:
        - name: group:default/admins
```

### 2. `rbac-policy.csv`

Defines roles, permissions, and role assignments using Casbin policy format.

## Roles

### Admin Role (`role:default/admin`)

Full access to all features:

- **Catalog**: Full CRUD operations on entities and locations
- **Scaffolder**: Create, read, and execute templates
- **RBAC**: Manage policies and permissions

**Assigned to:**

- `group:default/admins`
- `user:default/admin`

### Developer Role (`role:default/developer`)

Standard development access:

- **Catalog**: Read, create, and update entities (no delete)
- **Scaffolder**: Create and execute templates

**Assigned to:**

- `group:default/developers`

### Viewer Role (`role:default/viewer`)

Read-only access:

- **Catalog**: Read entities only
- **Scaffolder**: View templates only

## Permission Types

### Catalog Permissions

- `catalog-entity` - Legacy permission format
- `catalog.entity.read` - Read entities
- `catalog.entity.create` - Create new entities
- `catalog.entity.delete` - Delete entities
- `catalog.entity.refresh` - Refresh/update entities
- `catalog.location.read` - Read catalog locations
- `catalog.location.create` - Register new locations
- `catalog.location.delete` - Unregister locations

### Scaffolder Permissions

- `scaffolder-template` - Legacy permission format
- `scaffolder-action` - Legacy permission format
- `scaffolder.action.execute` - Execute scaffolder actions
- `scaffolder.template.parameter.read` - Read template parameters
- `scaffolder.task.create` - Create scaffolder tasks
- `scaffolder.task.read` - Read task status
- `scaffolder.task.cancel` - Cancel running tasks

### RBAC Permissions

- `policy-entity` - Legacy permission format
- `policy.entity.read` - Read policies
- `policy.entity.create` - Create policies

## Groups and Users

### Groups (defined in `examples/org.yaml`)

- **`group:default/admins`** - Platform administrators
- **`group:default/developers`** - Development team members
- **`group:default/guests`** - Guest users (limited access)

### Users

- **`user:default/admin`** - Default admin user
- **`user:default/guest`** - Guest user

## Policy File Format (CSV)

The `rbac-policy.csv` file uses Casbin format with two types of entries:

### Permission Policies (p)

Format: `p, role, resource, action, effect`

Example:

```csv
p, role:default/admin, catalog-entity, read, allow
```

### Role Assignments (g)

Format: `g, user_or_group, role`

Example:

```csv
g, group:default/admins, role:default/admin
g, user:default/admin, role:default/admin
```

## Managing Permissions

### Via Configuration File

1. Edit `rbac-policy.csv`
2. Restart the backend
3. Changes take effect immediately

### Via RBAC UI

1. Navigate to `/rbac` (requires admin access)
2. Create/edit roles and permissions
3. Assign roles to users/groups
4. Changes are persisted to the database

### Via REST API

Use the permission API endpoints:

```bash
# Get current policies
curl -H "Authorization: Bearer $USER_TOKEN" \
  http://localhost:7007/api/permission/policies

# Create a new policy (requires admin)
curl -X POST -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entityReference": "role:default/developer", "permission": "catalog.entity.read", "policy": "read", "effect": "allow"}' \
  http://localhost:7007/api/permission/policies
```

## Adding New Permissions

### 1. For New Plugins

Add the plugin ID to `pluginsWithPermission` in `app-config.yaml`:

```yaml
rbac:
  pluginsWithPermission:
    - catalog
    - scaffolder
    - permission
    - kubernetes  # new plugin
```

### 2. Create Role Permissions

Add permission entries to `rbac-policy.csv`:
```csv
p, role:default/admin, kubernetes.cluster.read, read, allow
p, role:default/developer, kubernetes.cluster.read, read, allow
```

### 3. Restart Backend

Restart the backend service to load the new configuration.

## Troubleshooting

### Check Current Permissions

```bash
USER_TOKEN="$(curl -s -X POST http://localhost:7007/api/auth/guest/refresh \
  -H 'Content-Type: application/json' -d '{}' | jq -r '.backstageIdentity.token')"

curl -H "Authorization: Bearer $USER_TOKEN" \
  http://localhost:7007/api/permission/policies
```

### Common Issues

1. **"Access Denied" errors**
   - Check if user is assigned to a role
   - Verify role has required permissions
   - Check policy file syntax

2. **Permissions not appearing in UI**
   - Ensure plugin is listed in `pluginsWithPermission`
   - Verify plugin is loaded (check `/extensions`)
   - Restart backend

3. **Changes not taking effect**
   - Restart backend after CSV changes
   - Clear browser cache
   - Check for CSV syntax errors in logs

## Best Practices

1. **Use Groups**: Assign roles to groups rather than individual users
2. **Principle of Least Privilege**: Start with minimal permissions and add as needed
3. **Test Changes**: Use a test user to verify permissions before deploying
4. **Document Custom Roles**: Add comments to CSV file for custom roles
5. **Regular Audits**: Review permissions periodically to remove unused access

## References

- [Backstage Permissions Documentation](https://backstage.io/docs/permissions/getting-started)
- [RBAC Plugin Documentation](https://www.npmjs.com/package/@backstage-community/plugin-rbac)
- [Red Hat Developer Hub RBAC Guide](https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.4/html/authorization/enabling-and-giving-access-to-rbac)
- [Casbin Policy Format](https://casbin.org/docs/syntax-for-models)
