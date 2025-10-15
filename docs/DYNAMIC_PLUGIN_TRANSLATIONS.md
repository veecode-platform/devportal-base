# Dynamic Plugin Translations Guide

This guide explains how to use translations for sidebar menu items in dynamic plugins.

## Overview

The DevPortal supports internationalization (i18n) for dynamic plugin menu items. You can provide translation keys that will be automatically translated based on the user's language preference.

## Supported Languages

Currently supported languages:

- English (en)
- German (de)
- Spanish (es)
- French (fr)
- Italian (it)
- Portuguese (pt)

## Configuration

### For Menu Items (menuItems)

When configuring menu items in your dynamic plugin's `app-config.dynamic.yaml`, you can use both `title` and `titleKey`:

```yaml
dynamicPlugins:
  frontend:
    your-plugin-name:
      menuItems:
        admin:
          title: Administration           # Fallback text (required)
          titleKey: menuItem.administration  # Translation key (optional)
          icon: adminIcon
        myCustomItem:
          parent: admin
          title: My Custom Item
          titleKey: menuItem.myCustomItem
          icon: customIcon
```

### For Dynamic Routes (dynamicRoutes)

When configuring dynamic routes with menu items:

```yaml
dynamicPlugins:
  frontend:
    your-plugin-name:
      dynamicRoutes:
        - path: /my-page
          importName: MyPage
          menuItem:
            icon: myIcon
            text: My Page                    # Fallback text (required)
            textKey: menuItem.myPage         # Translation key (optional)
```

## Adding New Translation Keys

### 1. Add the translation key to the messages file

Edit `/packages/app/src/translations/rhdh/ref.ts`:

```typescript
export const rhdhMessages = {
  menuItem: {
    // ... existing translations
    myCustomItem: 'My Custom Item',
    myPage: 'My Page',
  },
  // ... other sections
};
```

### 2. Add translations for other languages

Create or update language-specific translation files in `/packages/app/src/translations/rhdh/`:

**de.ts** (German):
```typescript
export const rhdhMessagesDE = {
  menuItem: {
    myCustomItem: 'Mein benutzerdefiniertes Element',
    myPage: 'Meine Seite',
  },
};
```

**pt.ts** (Portuguese):

```typescript
export const rhdhMessagesPT = {
  menuItem: {
    myCustomItem: 'Meu Item Personalizado',
    myPage: 'Minha Página',
  },
};
```

## How It Works

1. When a menu item is rendered, the system checks if `titleKey` (or `textKey` for routes) is provided
2. If a translation key exists, it uses the `useTranslation` hook to get the translated text
3. If no translation is found or the key is missing, it falls back to the `title` or `text` value
4. The translation is automatically updated when the user changes their language preference

## Best Practices

1. **Always provide a fallback**: Include both `title`/`text` and `titleKey`/`textKey` to ensure the menu item displays correctly even if translations are missing

2. **Use consistent naming**: Follow the pattern `menuItem.<itemName>` for menu item translations

3. **Keep keys in English**: The primary translation file uses English, and other languages translate from these keys

4. **Test all languages**: Verify that your translations work correctly in all supported languages

## Example: Complete Plugin Configuration

```yaml
dynamicPlugins:
  frontend:
    internal.plugin-my-plugin:
      appIcons:
        - name: myPluginIcon
          importName: MyPluginIcon
      dynamicRoutes:
        - path: /my-plugin
          importName: MyPluginPage
          menuItem:
            icon: myPluginIcon
            text: My Plugin
            textKey: menuItem.myPlugin
      menuItems:
        myPluginSettings:
          parent: admin
          title: My Plugin Settings
          titleKey: menuItem.myPluginSettings
          icon: myPluginIcon
          priority: 100
```

## Existing Translation Keys

The following translation keys are already available:

### Main Menu Items

- `menuItem.home` - Home
- `menuItem.catalog` - Catalog
- `menuItem.apis` - APIs
- `menuItem.create` - Create
- `menuItem.administration` - Administration
- `menuItem.extensions` - Extensions
- `menuItem.techRadar` - Tech Radar
- `menuItem.rbac` - RBAC
- `menuItem.notifications` - Notifications

See `/packages/app/src/translations/rhdh/ref.ts` for the complete list.

## Troubleshooting

### Menu item shows translation key instead of text

This happens when:

- The translation key doesn't exist in the messages file
- There's a typo in the `titleKey` or `textKey` value

**Solution**: Verify the key exists in `/packages/app/src/translations/rhdh/ref.ts`

### Translation doesn't change when switching languages

This happens when:

- The translation for that language hasn't been added
- The language file hasn't been imported in the app configuration

**Solution**: Add the translation to the appropriate language file and ensure it's imported in `DynamicRoot.tsx`

### Menu item doesn't appear at all

This happens when:

- The `title` or `text` field is missing (required as fallback)
- The `enabled` field is set to `false`

**Solution**: Ensure both `title`/`text` and `titleKey`/`textKey` are provided
