# Github Auth

## Create Github App

Follow the instructions in [Configure Git provider integration](https://docs.platform.vee.codes/devportal/installation-guide/simple-setup/configure-git-integrations).

Write down the `AppID`, `Client ID` and `Client Secret`. Also generate a private key and save it in a safe place.

You will write the sections below in a `app-config.local.yaml` file. The script `yarn dev-local` will use it when starting the app and the file is gitignored.

## Configure Github Auth

Configure github auth in the app-config.local.yaml file:

```yaml
auth:
  # repeat environment from main file
  environment: development
  # now the new provider (will add to main file)
  providers:
    # --- GitHub provider (loaded dynamically from the module, if loaded) ---
    github:
      # or remove this level for a single env block
      development:
        clientId: xxxx
        clientSecret: xxxx
        signIn:
          resolvers:
            - resolver: usernameMatchingUserEntityName
            - resolver: emailMatchingUserEntityProfileEmail
            - resolver: emailLocalPartMatchingUserEntityName
```

## Configure Github Org (Sync)

To sync users from your Github organization into the catalog, add the following to the app-config.local.yaml file:

```yaml
catalog:
  providers:
    githubOrg:
      id: providerId
      githubUrl: https://github.com
      orgs:
        - "you-org-name"
      schedule:
        frequency:
          minutes: 10
        timeout:
          minutes: 3
integrations:
  github:
    - host: github.com
      apps:
        - appId: xxxx
          clientId: xxxx
          clientSecret: xxxx
          privateKey: |
            -----BEGIN RSA PRIVATE KEY-----
            blablablablabla
            -----END RSA PRIVATE KEY-----
          # webhookSecret:
```

The Github App needs specific permissions:

- Organization members (read-only)
- Organization events (read-only)
- Organization webhooks (read-only)
- Account email (read-only)
