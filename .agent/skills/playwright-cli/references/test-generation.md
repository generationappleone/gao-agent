# Test Generation — Playwright CLI

## Auto-Generate Test Code

```bash
# Start codegen mode (records actions → generates code)
playwright codegen https://example.com

# Save generated code
playwright codegen https://example.com --output ./tests/generated.spec.ts

# With target language
playwright codegen https://example.com --target javascript
playwright codegen https://example.com --target python
```

## Semantic Locators

Generated code uses semantic locators (preferred):

```typescript
// Generated: uses accessible names and roles
await page.getByRole('button', { name: 'Submit' }).click();
await page.getByLabel('Email').fill('user@example.com');
await page.getByPlaceholder('Search...').fill('query');
await page.getByText('Welcome back').isVisible();
```

Locator priority (most to least stable):
1. `getByRole` — Accessible role + name
2. `getByLabel` — Form label association
3. `getByPlaceholder` — Placeholder text
4. `getByText` — Visible text content
5. `getByTestId` — `data-testid` attribute
6. CSS selector — Last resort

## Building Test Files

From generated code, create structured tests:

```typescript
import { test, expect } from '@playwright/test';

test.describe('Login Flow', () => {
  test('should login with valid credentials', async ({ page }) => {
    // Generated from codegen:
    await page.goto('https://app.example.com/login');
    await page.getByLabel('Email').fill('user@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: 'Sign In' }).click();
    
    // Added assertion:
    await expect(page.getByText('Dashboard')).toBeVisible();
  });
});
```

## Device Emulation in Codegen

```bash
# Record for mobile
playwright codegen --device "iPhone 14" https://example.com

# Record with specific viewport
playwright codegen --viewport-size 375,812 https://example.com
```
