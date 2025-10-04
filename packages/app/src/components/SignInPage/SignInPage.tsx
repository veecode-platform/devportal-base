/*
 * Portions of this file are based on code from the Red Hat Developer project:
 * https://github.com/redhat-developer/rhdh/blob/main/packages/app
 *
 * Original Copyright (c) 2022 Red Hat Developer (or the exact copyright holder from the original source, please verify in their repository)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {
  SignInPage as CCSignInPage,
  ProxiedSignInPage,
  type SignInProviderConfig,
} from '@backstage/core-components';
import {
  configApiRef,
  githubAuthApiRef,
  gitlabAuthApiRef,
  useApi,
  type SignInPageProps,
} from '@backstage/core-plugin-api';

import { keycloakProvider } from '../../api';
import { useTranslation } from '../../hooks/useTranslation';

// const DEFAULT_PROVIDER = 'keycloak';
const DEFAULT_PROVIDER = 'github';

/**
 * Key:
 * string - Provider name.
 *
 * Value:
 * SignInProviderConfig - Local sign-in provider configuration.
 * string - Proxy sign-in provider configuration.
 */
/*
const PROVIDERS = new Map<string, SignInProviderConfig | string>([
  ['github', githubProvider],
  ['gitlab', gitlabProvider],
  ['keycloak', keycloakProvider],
]);
*/

/**
 * Creates provider configurations with translated strings
 *
 * t - Translation function.
 * Map of provider configurations.
 *
 * Key:
 * string - Provider name.
 *
 * Value:
 * SignInProviderConfig - Local sign-in provider configuration.
 * string - Proxy sign-in provider configuration.
 *  */
const createProviders = (t: (key: string, params?: any) => string) =>
  new Map<string, SignInProviderConfig | string>([
    [
      'github',
      {
        id: 'github-auth-provider',
        title: t('signIn.providers.github.title'),
        message: t('signIn.providers.github.message'),
        apiRef: githubAuthApiRef,
      },
    ],
    [
      'gitlab',
      {
        id: 'gitlab-auth-provider',
        title: t('signIn.providers.gitlab.title'),
        message: t('signIn.providers.gitlab.message'),
        apiRef: gitlabAuthApiRef,
      },
    ],
    ['keycloak', keycloakProvider],
  ]);

export function SignInPage(props: SignInPageProps): React.JSX.Element {
  const configApi = useApi(configApiRef);
  const { t } = useTranslation();
  const isDevEnv = configApi.getString('auth.environment') === 'development';
  const provider =
    configApi.getOptionalString('signInPage') ?? DEFAULT_PROVIDER;
  const providers = createProviders(t);
  const providerConfig =
    providers.get(provider) ?? providers.get(DEFAULT_PROVIDER)!;
  
  if (typeof providerConfig === 'object') {
    const providerList = isDevEnv
      ? (['guest', providerConfig] satisfies ['guest', SignInProviderConfig])
      : [providerConfig];

    return (
      <CCSignInPage
        {...props}
        title={t('signIn.page.title')}
        align="center"
        providers={providerList}
      />
    );
  }

  return <ProxiedSignInPage {...props} provider={providerConfig} />;
}
