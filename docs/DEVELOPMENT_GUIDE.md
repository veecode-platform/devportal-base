# Development Guide

## Getting Started

### Prerequisites

- **Node.js**: v18+ (LTS recommended)
- **Yarn**: 4.10.3 (included in repo)
- **Docker**: For local database and services (optional)
- **Git**: For version control

### Initial Setup

1. **Clone and install**:

```bash
git clone <repository-url>
cd devportal-base
yarn install
```

2. **Configure environment**:

```bash
# Copy template and edit with your values
cp app-config.local.template.yaml app-config.local.yaml
```

3. **Start development servers**:

```bash
# Start both frontend and backend
yarn dev

# Or start separately
yarn workspace app start        # Frontend on :3000
yarn workspace backend start    # Backend on :7007
```

### Docker Development

Start all services with Docker:

```bash
# Using docker-compose
docker-compose up

# Using helper script
./docker-dev.sh
```

See `docs/DOCKER_DEVELOPMENT.md` for details.

## Project Structure

### Key Directories

- `/packages/app/` - Frontend React application
- `/packages/backend/` - Backend Node.js server
- `/plugins/` - Custom Backstage plugins
- `/dynamic-plugins/` - Dynamic plugin infrastructure
- `/examples/` - Example catalog entities
- `/docs/` - Project documentation

### Configuration Files

- `app-config.yaml` - Base configuration
- `app-config.local.yaml` - Local overrides (gitignored)
- `app-config.production.yaml` - Production settings
- `package.json` - Root package with workspaces
- `lerna.json` - Lerna configuration
- `turbo.json` - Build pipeline config

## Common Development Tasks

### Creating a New Plugin

1. **Generate plugin scaffold**:

```bash
yarn backstage-cli create-plugin
# Follow prompts to name your plugin
```

2. **Add to workspace**:

Plugin is automatically added to workspace in root `package.json`.

3. **Develop plugin**:

```bash
cd plugins/your-plugin
yarn start  # Standalone dev mode
```

4. **Integrate into app**:

```typescript
// packages/app/src/App.tsx
import { YourPluginPage } from '@internal/plugin-your-plugin';

// packages/app/src/components/AppBase/AppBase.tsx
<Route path="/your-route" element={<YourPluginPage />} />
```

### Creating a Backend Plugin

1. **Generate backend plugin**:

```bash
yarn backstage-cli create-plugin --backend
```

2. **Implement router**:

```typescript
// plugins/your-plugin-backend/src/router.ts
export async function createRouter(options: RouterOptions): Promise<express.Router> {
  const { logger } = options;
  const router = Router();
  
  router.get('/health', (_, res) => {
    res.json({ status: 'ok' });
  });
  
  return router;
}
```

3. **Register in backend**:

```typescript
// packages/backend/src/index.ts
import { createRouter as createYourPluginRouter } from '@internal/plugin-your-plugin-backend';

// Add to backend
const yourPluginEnv = useHotMemoize(module, () => createEnv('your-plugin'));
apiRouter.use('/your-plugin', await createYourPluginRouter({ logger: yourPluginEnv.logger }));
```

### Adding a Catalog Entity

1. **Create YAML file**:

```yaml
# examples/my-service.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-service
  description: My awesome service
spec:
  type: service
  lifecycle: production
  owner: team-name
```

2. **Register in catalog**:

```yaml
# app-config.yaml
catalog:
  locations:
    - type: file
      target: ./examples/my-service.yaml
```

3. **Reload catalog**:

Backend automatically picks up changes. Visit `/catalog` to see your entity.

### Creating a Software Template

1. **Create template directory**:

```bash
mkdir -p examples/templates/my-template/content
```

2. **Define template**:

```yaml
# examples/templates/my-template/template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: my-template
  title: My Template
  description: Creates a new service
spec:
  owner: team-name
  type: service
  parameters:
    - title: Service Information
      required:
        - name
      properties:
        name:
          title: Name
          type: string
  steps:
    - id: fetch
      name: Fetch Template
      action: fetch:template
      input:
        url: ./content
        values:
          name: ${{ parameters.name }}
```

3. **Add template content**:

```text
examples/templates/my-template/content/
├── README.md
├── package.json
└── src/
    └── index.ts
```

### Working with Dynamic Plugins

See `docs/DYNAMIC_PLUGINS_ARCHITECTURE.md` for detailed guide.

**Quick start**:

```bash
# Create wrapper
cd dynamic-plugins
yarn new-wrapper

# Build plugin
cd wrappers/your-plugin
yarn build

# Copy to runtime
cd ../..
yarn copy-plugins
```

## Testing

### Unit Tests

**Run all tests**:

```bash
yarn test
```

**Run tests for specific package**:

```bash
yarn workspace @internal/plugin-about test
```

**Watch mode**:

```bash
yarn test --watch
```

### E2E Tests (Playwright)

**Run E2E tests**:

```bash
yarn e2e
```

**Run in UI mode**:

```bash
yarn playwright test --ui
```

**Generate tests**:

```bash
yarn playwright codegen http://localhost:3000
```

### Test Structure

```typescript
import { renderInTestApp } from '@backstage/test-utils';
import { MyComponent } from './MyComponent';

describe('MyComponent', () => {
  it('renders correctly', async () => {
    const { getByText } = await renderInTestApp(<MyComponent />);
    expect(getByText('Hello')).toBeInTheDocument();
  });
});
```

## Code Quality

### Linting

**Run ESLint**:

```bash
yarn lint
yarn lint:fix  # Auto-fix issues
```

**Lint specific package**:

```bash
yarn workspace @internal/plugin-about lint
```

### Type Checking

**Run TypeScript compiler**:

```bash
yarn tsc
```

**Check specific package**:

```bash
yarn workspace app tsc
```

### Formatting

**Format with Prettier**:

```bash
yarn prettier --write .
```

## Building

### Development Build

```bash
yarn build
```

### Production Build

```bash
yarn build:all
yarn build:backend --config app-config.production.yaml
```

### Build Specific Package

```bash
yarn workspace app build
yarn workspace backend build
```

### Clean Build Artifacts

```bash
# Clean all
yarn clean

# Clean specific package
yarn workspace app clean
```

## Debugging

### Frontend Debugging

**Browser DevTools**:

- React DevTools extension
- Redux DevTools for state inspection
- Network tab for API calls

**VS Code Launch Configuration**:

```json
{
  "type": "chrome",
  "request": "launch",
  "name": "Launch Chrome",
  "url": "http://localhost:3000",
  "webRoot": "${workspaceFolder}/packages/app"
}
```

### Backend Debugging

**VS Code Launch Configuration**:

```json
{
  "type": "node",
  "request": "launch",
  "name": "Backend",
  "program": "${workspaceFolder}/packages/backend/src/index.ts",
  "runtimeArgs": ["-r", "ts-node/register"],
  "env": {
    "NODE_ENV": "development"
  }
}
```

**Debug Logs**:

```typescript
import { Logger } from 'winston';

export async function myFunction(logger: Logger) {
  logger.info('Processing request');
  logger.debug('Debug details', { data });
  logger.error('Error occurred', error);
}
```

## Performance Optimization

### Bundle Analysis

**Analyze bundle size**:

```bash
yarn workspace app analyze
```

### Code Splitting

**Lazy load components**:

```typescript
const MyHeavyComponent = lazy(() => import('./MyHeavyComponent'));

<Suspense fallback={<Progress />}>
  <MyHeavyComponent />
</Suspense>
```

### Memoization

**Use React.memo**:

```typescript
export const MyComponent = React.memo(({ data }) => {
  return <div>{data}</div>;
});
```

**Use useMemo/useCallback**:

```typescript
const expensiveValue = useMemo(() => computeExpensive(data), [data]);
const handleClick = useCallback(() => doSomething(), []);
```

## Troubleshooting

### Common Issues

**Port already in use**:

```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use different port
PORT=3001 yarn start
```

**Module not found**:

```bash
# Clear cache and reinstall
rm -rf node_modules .yarn/cache
yarn install
```

**Build failures**:

```bash
# Clean and rebuild
yarn clean
rm -rf .turbo
yarn install
yarn build
```

**Type errors after upgrade**:

```bash
# Regenerate types
yarn tsc --build --clean
yarn tsc
```

### Getting Help

1. Check documentation in `/docs`
2. Search existing issues
3. Check Backstage documentation: https://backstage.io/docs
4. Ask in team chat/Slack

## Best Practices

### Code Style

- Follow ESLint rules
- Use TypeScript strictly
- Write meaningful comments
- Keep functions small and focused

### Git Workflow

- Create feature branches
- Write descriptive commit messages
- Keep commits atomic
- Rebase before merging

### Testing

- Write tests for new features
- Maintain test coverage
- Test edge cases
- Use meaningful test descriptions

### Documentation

- Update docs when changing behavior
- Document complex logic
- Keep README files current
- Add inline comments for clarity

## Useful Commands Reference

```bash
# Development
yarn dev                    # Start all dev servers
yarn start                  # Start frontend only
yarn workspace backend start # Start backend only

# Building
yarn build                  # Build all packages
yarn build:all             # Build everything including backend
yarn tsc                   # Type check

# Testing
yarn test                  # Run all tests
yarn test --watch          # Watch mode
yarn e2e                   # E2E tests

# Code Quality
yarn lint                  # Lint code
yarn lint:fix             # Fix lint issues
yarn prettier --write .   # Format code

# Cleaning
yarn clean                # Clean build artifacts
rm -rf node_modules       # Remove dependencies

# Package Management
yarn install              # Install dependencies
yarn upgrade-interactive  # Upgrade packages
yarn why <package>        # Check why package is installed
```
