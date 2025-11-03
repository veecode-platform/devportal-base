# Keycloak Local Setup

You can run a local Keycloak instance by using the `vkdr` tool:

```bash
vkdr infra up
vkdr nginx install --default-ic
vkdr keycloak install
```

Keycloak will be available at `http://auth.localhost:8080` (use admin/admin to login).

Login and proceed to create a realm and a client for Backstage.
