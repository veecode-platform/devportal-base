#!/bin/sh
set -e

# Base configs that are always loaded
CONFIGS="--config app-config.yaml --config app-config.production.yaml --config app-config.dynamic-plugins.yaml"

# Conditionally add profile-specific config
case "$VEECODE_PROFILE" in
  github)
    echo "Loading GitHub configuration..."
    # if GITHUB_AUTH_CLIENT_ID is not set, set it to GITHUB_CLIENT_ID
    # if GITHUB_AUTH_CLIENT_SECRET is not set, set it to GITHUB_CLIENT_SECRET
    if [ -z "$GITHUB_AUTH_CLIENT_ID" ]; then
      export GITHUB_AUTH_CLIENT_ID=$GITHUB_CLIENT_ID
    fi
    if [ -z "$GITHUB_AUTH_CLIENT_SECRET" ]; then
      export GITHUB_AUTH_CLIENT_SECRET=$GITHUB_CLIENT_SECRET
    fi
    # if GITHUB_PRIVATE_KEY_BASE64 is set, decode it and set GITHUB_PRIVATE_KEY
    if [ -n "$GITHUB_PRIVATE_KEY_BASE64" ]; then
      export GITHUB_PRIVATE_KEY=$(echo "$GITHUB_PRIVATE_KEY_BASE64" | base64 --decode)
    fi
    CONFIGS="$CONFIGS --config app-config.github.yaml"
    ;;
  keycloak)
    echo "Loading Keycloak configuration..."
    if [ -z "$KEYCLOAK_METADATA_URL" ]; then
      export KEYCLOAK_METADATA_URL="$KEYCLOAK_BASE_URL/realms/$KEYCLOAK_REALM"
    fi
    CONFIGS="$CONFIGS --config app-config.keycloak.yaml"
    ;;
  azure)
    echo "Loading Azure configuration..."
    CONFIGS="$CONFIGS --config app-config.azure.yaml"
    ;;
  ldap)
    echo "Loading LDAP configuration..."
    CONFIGS="$CONFIGS --config app-config.ldap.yaml"
    ;;
  gitlab)
    echo "Loading GitLab configuration..."
    CONFIGS="$CONFIGS --config app-config.gitlab.yaml"
    ;;
  local)
    echo "Loading Local configuration..."
    CONFIGS="$CONFIGS --config app-config.local.yaml"
    ;;
esac

# You can add more conditional configs here
# Example: if [ -n "$ENABLE_CUSTOM_CONFIG" ]; then
#   CONFIGS="$CONFIGS --config app-config.custom.yaml"
# fi

echo "Starting backend with configs: $CONFIGS"
exec node packages/backend $CONFIGS