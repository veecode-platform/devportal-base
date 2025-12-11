#!/bin/sh
set -e

# Base configs that are always loaded
CONFIGS="--config app-config.yaml --config app-config.production.yaml --config app-config.dynamic-plugins.yaml"

# Conditionally add profile-specific config
case "$VEECODE_PROFILE" in
  github)
    echo "Loading GitHub configuration..."
    CONFIGS="$CONFIGS --config app-config.github.yaml"
    ;;
  keycloak)
    echo "Loading Keycloak configuration..."
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