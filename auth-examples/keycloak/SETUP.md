# Keycloak Local Setup

You can run a local Keycloak instance by using the `vkdr` tool:

```bash
vkdr infra up
vkdr nginx install --default-ic
vkdr keycloak install
```

Keycloak will be available at `http://auth.localhost:8000` (use admin/admin to login).

Login and proceed to create a realm and a client for Backstage.

## Running DevPortal and Keycloak Locally in a Container

Start Keycloak with `vkdr` as above and DevPortal with the following command:

```bash
docker run --name devportal -d -p 7007:7007 \
  -e VEECODE_PROFILE=keycloak \
  --env KEYCLOAK_BASE_URL \
  --env KEYCLOAK_CLIENT_ID \
  --env KEYCLOAK_CLIENT_SECRET \
  --env KEYCLOAK_REALM \
  --env AUTH_SESSION_SECRET \
  --add-host auth.localhost:192.168.0.100 \
  veecode/devportal-base:latest
```

Replace the IP address with the one of your machine.
