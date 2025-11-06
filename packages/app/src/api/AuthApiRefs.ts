/*
 * Copyright 2020 The Backstage Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {
  ApiRef,
  BackstageIdentityApi,
  configApiRef,
  createApiRef,
  // githubAuthApiRef,
  // gitlabAuthApiRef,
  // microsoftAuthApiRef,
  OpenIdConnectApi,
  ProfileInfoApi,
  SessionApi,
} from '@backstage/core-plugin-api';

export const oidcAuthApiRef: ApiRef<
  OpenIdConnectApi & ProfileInfoApi & BackstageIdentityApi & SessionApi
> = createApiRef({
  id: 'auth.oidc-provider',
});

export const auth0AuthApiRef: ApiRef<
  OpenIdConnectApi & ProfileInfoApi & BackstageIdentityApi & SessionApi
> = createApiRef({
  id: 'auth.auth0-provider',
});

export const samlAuthApiRef: ApiRef<
  OpenIdConnectApi & ProfileInfoApi & BackstageIdentityApi & SessionApi
> = createApiRef({
  id: 'auth.saml-provider',
});

// export const keycloakProvider = {
//   id: 'keycloak',
//   title: 'Keycloak',
//   message: 'Sign in using Keycloak',
//   apiRef: oidcAuthApiRef,
//   configApiRef: configApiRef,
// };

export const auth0Provider = {
  id: 'auth0',
  title: 'Auth0',
  message: 'Sign in using Auth0',
  apiRef: auth0AuthApiRef,
  configApiRef: configApiRef,
};

export const samlProvider = {
  id: 'saml',
  title: 'SAML',
  message: 'Sign in using SAML',
  apiRef: samlAuthApiRef,
  configApiRef: configApiRef,
};

// export const githubProvider = {
//   id: 'github-auth-provider',
//   title: 'GitHub',
//   message: 'Sign in using GitHub',
//   apiRef: githubAuthApiRef,
//   configApiRef: configApiRef,
// };

// export const gitlabProvider = {
//   id: 'gitlab-auth-provider',
//   title: 'Gitlab',
//   message: 'Sign in using Gitlab',
//   apiRef: gitlabAuthApiRef,
//   configApiRef: configApiRef,
// };

// export const azureProvider = {
//   id: 'microsoft',
//   title: 'Azure',
//   message: 'Sign in using Azure',
//   apiRef: microsoftAuthApiRef,
//   configApiRef: configApiRef,
// };
