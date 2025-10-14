# Guide Local Development

Este documento explica o processo de desenvolvimento local do DevPortal com suporte completo a plugins dinâmicos.

## Arquitetura de Plugins Dinâmicos

### Arquivos de Configuração

1. **`dynamic-plugins.default.yaml`**
   - Contém plugins **embutidos** na aplicação base
   - Inclui plugins de frontend e backend pré-configurados
   - Plugins locais (caminhos `./dynamic-plugins/dist/...`)
   - Configurações padrão para desenvolvimento

2. **`dynamic-plugins.yaml`**
   - Contém plugins **externos** (OCI e NPM)
   - Inclui referência ao `dynamic-plugins.default.yaml` via `includes`
   - Suporta plugins de container OCI (`oci://docker.io/...`)
   - Suporta plugins NPM remotos e locais
   - Configurações específicas de montagem e comportamento

### Sistema de Instalação de Plugins

O script `check_dynamic_plugins.py` implementa um sistema robusto de gerenciamento de plugins:

#### Funcionalidades Principais

1. **Download e Instalação**
   - **Plugins OCI**: Usa `skopeo` para baixar imagens de container
   - **Plugins NPM**: Usa `npm pack` para baixar pacotes
   - **Plugins Locais**: Suporta caminhos relativos (`./`)

2. **Verificação de Integridade**
   - Validação de hash SHA para pacotes remotos
   - Verificação de assinatura de pacotes OCI
   - Proteção contra zip bombs (limite de 20MB por arquivo)

3. **Gerenciamento de Estado**
   - Sistema de lock para evitar instalações concorrentes
   - Cache inteligente baseado em hash de configuração
   - Políticas de pull: `IfNotPresent`, `Always`
   - Detecção automática de mudanças na configuração

4. **Geração de Configuração**
   - Cria `app-config.dynamic-plugins.yaml` automaticamente
   - Merge de configurações de plugins individuais
   - Resolução de conflitos de configuração

#### Estrutura de Diretórios

```
dynamic-plugins-root/
├── app-config.dynamic-plugins.yaml  # Config gerada automaticamente
├── plugin-name-1/                   # Plugin instalado
│   ├── dynamic-plugin-config.hash   # Hash da configuração
│   └── ... (arquivos do plugin)
└── plugin-name-2/
    ├── dynamic-plugin-image.hash    # Hash da imagem OCI
    └── ... (arquivos do plugin)
```

### Scripts de Desenvolvimento

1. **`yarn init-local`**
   - Executa build completo (`make full`)
   - Instala plugins dinâmicos (`yarn check-dynamic-plugins`)
   - Inicia aplicação em modo desenvolvimento (`yarn dev-local`)

2. **`yarn dev-local`**
   - Inicia backend e frontend
   - Carrega configurações: `app-config.local.yaml` + `app-config.dynamic-plugins.yaml`
   - Suporte completo a hot-reload

3. **`yarn check-dynamic-plugins`**
   - Executa `scripts/check_dynamic_plugins.sh`
   - Chama o script Python para instalação de plugins

> **Nota**: Se necessário, dar permissão de execução ao script:
   ```bash
   chmod +x ./scripts/check_dynamic_plugins.sh
   ```

## Configurações Específicas

### Branding e Temas

No `app-config.yaml`:
- **Logo dinâmico**: Suporte a variantes `light` e `dark`
- **Tema personalizado**: Configuração `appBarBackgroundScheme` para controle de tema
- **Largura customizável**: `fullLogoWidth` para ajuste de dimensões

### Autenticação

- Método customizado para autenticação GitHub (desenvolvimento)
- Configuração de chaves de serviço para autenticação backend

### Componentes

- **Root Component**: Lógica para ocultar logo duplicado quando `global-header` está em `above-sidebar`
- **CompanyLogo**: Suporte completo a logos temáticos e configuração dinâmica

## Como Usar

1. **Desenvolvimento Local Completo**:
   ```bash
   yarn init-local
   ```

2. **Apenas Instalar Plugins**:
   ```bash
   yarn check-dynamic-plugins
   ```

3. **Desenvolvimento sem Reinstalar Plugins**:
   ```bash
   yarn dev-local
   ```