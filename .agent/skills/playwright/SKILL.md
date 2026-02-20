---
name: Playwright
description: Skill for E2E browser testing with Playwright, covering page interactions, API testing, visual regression, accessibility audits, and CI/CD integration.
---

# Playwright Skill

## Overview
Playwright is a modern E2E testing framework by Microsoft supporting Chromium, Firefox, and WebKit. It provides auto-waiting, network interception, API testing, visual regression, and multi-browser parallel execution.

**References**:
- [Playwright Documentation](https://playwright.dev/)
- [Playwright API](https://playwright.dev/docs/api/class-page)

---

## Setup

```bash
npm init playwright@latest
```

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html'], ['list']],
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { browserName: 'chromium' } },
    { name: 'firefox', use: { browserName: 'firefox' } },
    { name: 'webkit', use: { browserName: 'webkit' } },
  ],
  webServer: { command: 'npm run dev', url: 'http://localhost:3000', reuseExistingServer: !process.env.CI },
});
```

---

## Page Tests

```typescript
import { test, expect } from '@playwright/test';

test.describe('Products', () => {
  test('should display product list', async ({ page }) => {
    await page.goto('/products');
    await expect(page.getByRole('heading', { name: 'Products' })).toBeVisible();
    const products = page.locator('[data-testid="product-card"]');
    await expect(products).toHaveCount(20);
  });

  test('should search products', async ({ page }) => {
    await page.goto('/products');
    await page.getByPlaceholder('Search products').fill('laptop');
    await page.getByRole('button', { name: 'Search' }).click();
    await expect(page.locator('[data-testid="product-card"]')).toHaveCount(5);
  });

  test('should add product to cart', async ({ page }) => {
    await page.goto('/products');
    await page.locator('[data-testid="product-card"]').first().getByRole('button', { name: 'Add to Cart' }).click();
    await expect(page.getByTestId('cart-count')).toHaveText('1');
  });
});

test.describe('Authentication', () => {
  test('should login successfully', async ({ page }) => {
    await page.goto('/login');
    await page.getByLabel('Email').fill('user@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: 'Sign In' }).click();
    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByText('Welcome')).toBeVisible();
  });
});
```

---

## API Testing

```typescript
test('should create a product via API', async ({ request }) => {
  const response = await request.post('/api/products', {
    headers: { Authorization: `Bearer ${token}` },
    data: { name: 'Test Product', price: 9999, categoryId: 'cat-1' },
  });
  expect(response.status()).toBe(201);
  const body = await response.json();
  expect(body.name).toBe('Test Product');
});
```

---

## Commands

```bash
npx playwright test              # Run all tests
npx playwright test --ui         # Interactive UI mode
npx playwright test --headed     # Show browser
npx playwright show-report       # View HTML report
npx playwright codegen           # Record tests
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Auto-wait** | Playwright auto-waits for elements |
| **Locators** | Use getByRole, getByLabel, getByTestId |
| **Page objects** | Abstract pages into reusable classes |
| **Assertions** | Use web-first assertions (toBeVisible, toHaveText) |
| **Parallel** | Run tests in parallel for speed |
| **Traces** | Enable traces for debugging failures |
| **API testing** | Test APIs alongside UI tests |
| **CI** | Run in CI with retries and reporters |
| **Screenshots** | Capture on failure for debugging |
| **Codegen** | Use codegen to bootstrap tests |

---

## Rules Integration
- **E2E**: Page interaction tests with auto-wait
- **API**: Request API for backend testing
- **Config**: Multi-browser, parallel, CI-optimized
- **Locators**: Accessible selectors (role, label, testid)
