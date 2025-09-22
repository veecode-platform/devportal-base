const ModuleFederationPlugin = require('webpack/lib/container/ModuleFederationPlugin');

module.exports = (config) => {
  // Add Module Federation plugin
  config.plugins.push(
    new ModuleFederationPlugin({
      name: 'host',
      shared: {
        react: {
          singleton: true,
          requiredVersion: '^18.0.0',
        },
        'react-dom': {
          singleton: true,
          requiredVersion: '^18.0.0',
        },
        'react-router': {
          singleton: true,
          requiredVersion: '^6.3.0',
        },
        'react-router-dom': {
          singleton: true,
          requiredVersion: '^6.3.0',
        },
        '@backstage/core-plugin-api': {
          singleton: true,
        },
        '@backstage/core-components': {
          singleton: true,
        },
        '@backstage/theme': {
          singleton: true,
        },
      },
    })
  );

  return config;
};
