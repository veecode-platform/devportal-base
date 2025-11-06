#!/bin/sh
set -e

# Base configs that are always loaded
CONFIGS="--config app-config.yaml --config app-config.production.yaml --config app-config.dynamic-plugins.yaml"

# Conditionally add app-config.github.yaml
if [ "$VEECODE_PROFILE" = "github" ]; then
  echo "Loading GitHub configuration..."
  CONFIGS="$CONFIGS --config app-config.github.yaml"
fi

if [ "$VEECODE_PROFILE" = "keycloak" ]; then
  echo "Loading Keycloak configuration..."
  CONFIGS="$CONFIGS --config app-config.keycloak.yaml"
fi

if [ "$VEECODE_PROFILE" = "azure" ]; then
  echo "Loading Azure configuration..."
  CONFIGS="$CONFIGS --config app-config.azure.yaml"
fi

# Conditionally add app-config.local.yaml
if [ "$VEECODE_PROFILE" = "local" ]; then
  echo "Loading Local configuration..."
  CONFIGS="$CONFIGS --config app-config.local.yaml"
fi

# You can add more conditional configs here
# Example: if [ -n "$ENABLE_CUSTOM_CONFIG" ]; then
#   CONFIGS="$CONFIGS --config app-config.custom.yaml"
# fi

echo "Starting backend with configs: $CONFIGS"
exec node packages/backend $CONFIGS