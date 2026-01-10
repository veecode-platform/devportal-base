# MUI v4 to v5 Migration Status

## Overview

This document tracks the Material-UI (MUI) migration from v4 to v5 across the codebase. The migration uses the **v4 compatibility layer** (@mui/styles) to enable gradual migration while maintaining functionality.

## Migration Strategy

### Approach

- **Phase 1**: Upgrade packages to MUI v5 with @mui/styles compatibility layer
- **Phase 2**: Run MUI codemods for automated transformations
- **Phase 3**: Gradual migration away from @mui/styles to @mui/material styling solutions
- **Phase 4**: Remove @mui/styles dependency

### Why @mui/styles?

- Provides v4 `makeStyles`, `withStyles` compatibility
- Allows gradual migration without breaking existing code
- Follows official Backstage migration guidelines
- Enables running v4 and v5 code side-by-side

## Package Migration Status

### ✅ Fully Migrated (MUI v5)

#### `plugins/dynamic-plugins-info/`

- **Status**: Complete MUI v5 migration
- **Packages**: @mui/material@^5.18.0, @mui/icons-material@^5.18.0
- **Notes**: No @mui/styles dependency, uses native MUI v5 styling

### ⚠️ Using v4 Compatibility Layer

#### `packages/app/`

- **Status**: MUI v5 with @mui/styles compatibility
- **Packages**: @mui/material@^5.18.0, @mui/icons-material@^5.18.0, @mui/styles@^5.18.0
- **Migration Path**: Gradually convert makeStyles to styled() or sx prop

#### `plugins/about/`

- **Status**: MUI v5 with @mui/styles compatibility
- **Files migrated**: DefaultAboutPage.tsx, DevportalIcon.tsx, BackstageLogoIcon.tsx
- **Migration Path**: Convert makeStyles to styled() or sx prop

#### `plugins/support/`

- **Status**: MUI v5 with @mui/styles compatibility
- **Files migrated**: DefaultSupportPage.tsx
- **Migration Path**: Convert makeStyles to styled() or sx prop

## Import Path Changes

### Before (MUI v4)

```typescript
import { Button } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import AddIcon from '@material-ui/icons/Add';
```

### After (MUI v5 with compatibility)

```typescript
import { Button } from '@mui/material';
import { makeStyles } from '@mui/styles';
import AddIcon from '@mui/icons-material/Add';
```

## Breaking Changes Fixed

### TablePagination rowsPerPage

MUI v5 TablePagination only accepts: 5, 10, 20, 50, 100

- Fixed in `packages/app/src/components/AppBase/AppBase.tsx`
- Changed from 15 to 20

### Dark Mode Font Colors

- Fixed in Backstage 1.44.1+
- Alternative: Use StyledEngineProvider if issues persist

## Styling Migration Patterns

### makeStyles → styled()

```typescript
// Before
import { makeStyles } from '@mui/styles';
const useStyles = makeStyles(theme => ({
  root: { padding: theme.spacing(2) },
}));

// After
import { styled } from '@mui/material/styles';
const Root = styled('div')(({ theme }) => ({
  padding: theme.spacing(2),
}));
```

### makeStyles → sx prop

```typescript
// Before
const useStyles = makeStyles(theme => ({
  button: { margin: theme.spacing(1) },
}));

// After
<Button sx={{ m: 1 }}>Click</Button>;
```

## Next Steps

1. Identify components still using makeStyles
2. Convert to styled() or sx prop
3. Remove @mui/styles dependency
4. Test thoroughly in both light and dark modes
