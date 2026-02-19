---
name: Playwright
description: Skill for E2E browser testing with Playwright, covering page interactions, API testing, visual regression, accessibility audits, and CI/CD integration.
---

# Playwright Skill

## Overview
Playwright is a modern E2E testing framework by Microsoft supporting Chromium, Firefox, and WebKit with auto-wait, network interception, and parallel execution.

## Installation
```bash
npm init playwright@latest
# or add to existing project
npm install -D @playwright/test
npx playwright install          # install browsers
npx playwright install --with-deps  # + system dependencies
```

## Configuration — `playwright.config.ts`
```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { open: 'never' }],
    ['json', { outputFile: 'test-results/results.json' }],
    ['list'],
  ],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
    { name: 'mobile-safari', use: { ...devices['iPhone 13'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

## Core Patterns

### Basic Test
```typescript
import { test, expect } from '@playwright/test';

test.describe('Login Feature', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
  });

  test('successful login', async ({ page }) => {
    await page.fill('[data-testid="email"]', 'user@example.com');
    await page.fill('[data-testid="password"]', 'SecurePass123!');
    await page.click('[data-testid="login-button"]');
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="welcome"]')).toBeVisible();
  });

  test('failed login shows error', async ({ page }) => {
    await page.fill('[data-testid="email"]', 'wrong@example.com');
    await page.fill('[data-testid="password"]', 'wrong');
    await page.click('[data-testid="login-button"]');
    await expect(page.locator('.error-message')).toHaveText('Invalid credentials');
  });
});
```

### API Testing
```typescript
import { test, expect } from '@playwright/test';

test.describe('API Tests', () => {
  let token: string;

  test.beforeAll(async ({ request }) => {
    const res = await request.post('/api/auth/login', {
      data: { email: 'admin@test.com', password: 'password' },
    });
    token = (await res.json()).token;
  });

  test('GET /api/users returns list', async ({ request }) => {
    const res = await request.get('/api/users', {
      headers: { Authorization: `Bearer ${token}` },
    });
    expect(res.ok()).toBeTruthy();
    const body = await res.json();
    expect(body.data).toBeInstanceOf(Array);
    expect(body.data.length).toBeGreaterThan(0);
  });

  test('POST /api/users validates input', async ({ request }) => {
    const res = await request.post('/api/users', {
      headers: { Authorization: `Bearer ${token}` },
      data: { email: 'invalid' }, // missing required fields
    });
    expect(res.status()).toBe(400);
  });
});
```

### Visual Regression
```typescript
test('homepage visual regression', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('homepage.png', {
    maxDiffPixelRatio: 0.01,
  });
});
```

### Accessibility Testing with axe-core
```typescript
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('page has no accessibility violations', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa'])
    .analyze();
  expect(results.violations).toEqual([]);
});
```

### Network Interception
```typescript
test('handles API failure gracefully', async ({ page }) => {
  await page.route('**/api/data', route =>
    route.fulfill({ status: 500, body: 'Server Error' })
  );
  await page.goto('/dashboard');
  await expect(page.locator('.error-fallback')).toBeVisible();
});
```

### Authentication State Reuse
```typescript
// auth.setup.ts — run once, reuse state
import { test as setup } from '@playwright/test';

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.fill('#email', 'admin@test.com');
  await page.fill('#password', 'password');
  await page.click('#login-btn');
  await page.waitForURL('/dashboard');
  await page.context().storageState({ path: '.auth/admin.json' });
});

// In config: { name: 'authed', use: { storageState: '.auth/admin.json' } }
```

## CLI Commands
```bash
npx playwright test                      # run all tests
npx playwright test --project=chromium   # specific browser
npx playwright test --grep "login"       # filter tests
npx playwright test --ui                 # interactive UI mode
npx playwright show-report               # view HTML report
npx playwright codegen http://localhost:3000  # record tests
npx playwright test --update-snapshots   # update visual baselines
```

## Best Practices
- Use `data-testid` attributes for stable selectors
- Prefer `await expect(locator).toBeVisible()` over `waitForSelector`
- Use Page Object Model (POM) for large test suites
- Isolate test data — each test should be independent
- Use `test.describe.configure({ mode: 'serial' })` only when tests depend on order
- Keep tests fast — mock external services when possible
