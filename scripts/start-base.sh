#!/bin/sh
set -e

# Base configs that are always loaded
CONFIGS="--config app-config.yaml --config app-config.production.yaml --config app-config.dynamic-plugins.yaml"

# Conditionally add app-config.github.yaml if ENABLE_GITHUB_CONFIG is set
if [ "$VEECODE_PROFILE" = "github" ]; then
  echo "Loading GitHub configuration..."
  CONFIGS="$CONFIGS --config app-config.github.yaml"
fi

# You can add more conditional configs here
# Example: if [ -n "$ENABLE_CUSTOM_CONFIG" ]; then
#   CONFIGS="$CONFIGS --config app-config.custom.yaml"
# fi

echo "Starting backend with configs: $CONFIGS"
exec node packages/backend $CONFIGS