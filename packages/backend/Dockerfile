# This dockerfile builds an image for the backend package.
# It should be executed by Github Actions after building all the package and plugins.
# This is NOT a multi-staged Dockerfile.
#
# The Dockerfile was based on the generated dockerfile from the Backstage app creation,
# with some added features to make it work with dynamic plugins.
#
# To build it locally, be sure to have run the following commands in the repo root:
#
# yarn install --immutable
# yarn tsc
# yarn build:all
# 
# Also run the commands that prepare the preinstalled dynamic plugins:
#
# mkdir dynamic-plugins-docker
# cd dynamic-plugins
# yarn install
# yarn build
# yarn export-dynamic
# yarn copy-dynamic-plugins $(pwd)/../dynamic-plugins-docker
# cd ..
#
# Once the commands have been run, you can build the image using `yarn build-image`
#

# FROM node:22-bookworm-slim
FROM registry.redhat.io/ubi9/nodejs-22:9.6-1760386551

USER root

# Install isolate-vm dependencies, these are needed by the @backstage/plugin-scaffolder-backend.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    dnf install -y --setopt=install_weak_deps=False \
      python3 make gcc-c++ git pkg-config \
      jq wget tar gzip ca-certificates \
    && dnf clean all \
    && wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -q -O /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq
#    apt-get update && \
#    apt-get install -y --no-install-recommends python3 g++ build-essential && \
#    rm -rf /var/lib/apt/lists/*

# Install sqlite3 dependencies. You can skip this if you don't use sqlite3 in the image,
# in which case you should also move better-sqlite3 to "devDependencies" in package.json.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    dnf install -y --setopt=install_weak_deps=False \
      sqlite-devel \
    && dnf clean all
#    apt-get update && \
#    apt-get install -y --no-install-recommends libsqlite3-dev && \
#    rm -rf /var/lib/apt/lists/*

# From here on we use the least-privileged `node` user to run the backend.
USER default

# allows setting NPM registry from build arg
ARG NPM_REGISTRY=https://registry.npmjs.org/

# Set Python interpreter for `node-gyp` to use
ENV PYTHON=/usr/bin/python3

# Set as environment variable (so npm install uses it)
ENV NPM_REGISTRY=$NPM_REGISTRY NPM_CONFIG_REGISTRY=$NPM_REGISTRY YARN_REGISTRY=$NPM_REGISTRY
RUN echo "Using NPM_CONFIG_REGISTRY=$NPM_CONFIG_REGISTRY" && \
    npm install -g corepack && \
    corepack enable && \
    corepack prepare yarn@4.4.1 --activate

# This should create the app dir as `node`.
# If it is instead created as `root` then the `tar` command below will fail: `can't create directory 'packages/': Permission denied`.
# If this occurs, then ensure BuildKit is enabled (`DOCKER_BUILDKIT=1`) so the app dir is correctly created as `node`.
WORKDIR /app

# Copy files needed by Yarn
COPY --chown=default:default .yarn ./.yarn
# COPY --chown=default:default .yarnrc.yml ./
COPY --chown=default:default backstage.json ./

# This switches many Node.js dependencies to production mode.
ENV NODE_ENV=production

# This disables node snapshot for Node 20 to work with the Scaffolder
ENV NODE_OPTIONS="--no-node-snapshot"

# Copy repo skeleton first, to avoid unnecessary docker cache invalidation.
# The skeleton contains the package.json of each package in the monorepo,
# and along with yarn.lock and the root package.json, that's enough to run yarn install.
COPY --chown=default:default yarn.lock package.json packages/backend/dist/skeleton.tar.gz ./
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz

# Strict, reproducible install (no node_modules from host)
RUN yarn config set npmRegistryServer $NPM_REGISTRY && \
    yarn config set nodeLinker node-modules && \
    if [ "$NPM_REGISTRY" != "https://registry.npmjs.org/" ]; then \
      HOST=$(printf '%s\n' "$NPM_REGISTRY" | awk -F[/:] '{print $4}') && \
      yarn config set unsafeHttpWhitelist --json "[\"localhost\",\"$HOST\"]"; \
    fi && \
    cp .yarnrc.yml $HOME/.yarnrc.yml


RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn workspaces focus --all --production && rm -rf "$(yarn cache clean)"

# This will include the examples, if you don't need these simply remove this line
COPY --chown=default:default examples ./examples

# Then copy the rest of the backend bundle, along with any other files we might want.
COPY --chown=default:default packages/backend/dist/bundle.tar.gz app-config*.yaml ./
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

# dynamic plugin processing
COPY --chown=default:default dynamic-plugins-docker dynamic-plugins-root
COPY --chown=default:default app-config.dynamic-plugins.local.template.yaml app-config.dynamic-plugins.yaml

# runs:
# node packages/backend --config app-config.yaml --config app-config.production.yaml
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml", "--config", "app-config.dynamic-plugins.yaml"]
