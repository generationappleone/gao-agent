---
name: Cross-Browser Testing
description: Skill for cross-browser and cross-device testing with BrowserStack and Sauce Labs, covering configuration, Selenium/Playwright integration, and CI/CD pipelines.
---

# Cross-Browser Testing Skill (BrowserStack & Sauce Labs)

## Overview
BrowserStack and Sauce Labs provide cloud-based real browsers and devices for cross-browser/cross-device testing, eliminating the need to maintain local browser farms.

## Comparison

| Feature | BrowserStack | Sauce Labs |
|---------|-------------|-----------|
| Real devices | ✅ 3000+ | ✅ 2000+ |
| Free tier | ✅ (limited) | ✅ (limited) |
| Live testing | ✅ | ✅ |
| Automated | ✅ Selenium/Playwright | ✅ Selenium/Playwright |
| CI/CD | ✅ GitHub/Jenkins/etc | ✅ GitHub/Jenkins/etc |
| Local testing | ✅ BrowserStackLocal | ✅ Sauce Connect |
| Accessibility | ✅ Built-in | ✅ Deque axe |

---

## BrowserStack

### Setup
```bash
# Install BrowserStack SDK
npm install -D browserstack-local

# Environment variables
BROWSERSTACK_USERNAME=your_username
BROWSERSTACK_ACCESS_KEY=your_key
```

### Playwright Integration
```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  projects: [
    {
      name: 'browserstack-chrome',
      use: {
        connectOptions: {
          wsEndpoint: `wss://cdp.browserstack.com/playwright?caps=${encodeURIComponent(JSON.stringify({
            browser: 'chrome',
            browser_version: 'latest',
            os: 'Windows',
            os_version: '11',
            'browserstack.username': process.env.BROWSERSTACK_USERNAME,
            'browserstack.accessKey': process.env.BROWSERSTACK_ACCESS_KEY,
          }))}`,
        },
      },
    },
  ],
});
```

### Local Testing
```bash
# Start local tunnel
npx browserstack-local --key YOUR_KEY

# Or programmatic
const browserstack = require('browserstack-local');
const local = new browserstack.Local();
local.start({ key: process.env.BROWSERSTACK_ACCESS_KEY }, () => {
  console.log('BrowserStack Local connected');
});
```

### CLI
```bash
# Run Playwright tests on BrowserStack
npx playwright test --config=playwright.browserstack.config.ts
```

---

## Sauce Labs

### Setup
```bash
# Install Sauce Connect (local tunnel)
# Download from: https://docs.saucelabs.com/secure-connections/sauce-connect/

# Environment variables
SAUCE_USERNAME=your_username
SAUCE_ACCESS_KEY=your_key
```

### Selenium/WebDriver Integration
```javascript
const caps = {
  browserName: 'chrome',
  browserVersion: 'latest',
  platformName: 'Windows 11',
  'sauce:options': {
    username: process.env.SAUCE_USERNAME,
    accessKey: process.env.SAUCE_ACCESS_KEY,
    name: 'Cross-browser test',
    build: `build-${Date.now()}`,
  },
};

const driver = new webdriver.Builder()
  .usingServer('https://ondemand.us-west-1.saucelabs.com:443/wd/hub')
  .withCapabilities(caps)
  .build();
```

### Sauce Connect (Local Testing)
```bash
sc -u $SAUCE_USERNAME -k $SAUCE_ACCESS_KEY --tunnel-name my-tunnel
```

---

## CI/CD Integration

### GitHub Actions (BrowserStack)
```yaml
- name: BrowserStack Tests
  uses: browserstack/github-actions/setup-env@master
  with:
    username: ${{ secrets.BROWSERSTACK_USERNAME }}
    access-key: ${{ secrets.BROWSERSTACK_ACCESS_KEY }}
- name: Start Tunnel
  uses: browserstack/github-actions/setup-local@master
- name: Run Tests
  run: npx playwright test --config=playwright.browserstack.config.ts
```

### GitHub Actions (Sauce Labs)
```yaml
- name: Sauce Labs Tests
  uses: saucelabs/sauce-connect-action@v2
  with:
    username: ${{ secrets.SAUCE_USERNAME }}
    accessKey: ${{ secrets.SAUCE_ACCESS_KEY }}
    tunnelName: github-tunnel
- name: Run Tests
  run: npx playwright test
  env:
    SAUCE_USERNAME: ${{ secrets.SAUCE_USERNAME }}
    SAUCE_ACCESS_KEY: ${{ secrets.SAUCE_ACCESS_KEY }}
```

## Testing Matrix (Recommended)

| Browser | Versions | OS | Priority |
|---------|---------|-----|----------|
| Chrome | latest, latest-1 | Windows, macOS | 🔴 High |
| Firefox | latest, latest-1 | Windows, macOS | 🟠 Medium |
| Safari | latest, latest-1 | macOS, iOS | 🟠 Medium |
| Edge | latest | Windows | 🟡 Low |
| Mobile Chrome | latest | Android 13, 14 | 🔴 High |
| Mobile Safari | latest | iOS 17, 18 | 🔴 High |

## Best Practices
- Test on top 5 browser/OS combinations covering 90%+ of users
- Use analytics data to determine target browsers
- Run cross-browser tests in CI (nightly, not on every commit)
- Use local tunnel for testing localhost/staging environments
- Set `build` and `name` in capabilities for organized results
- Take screenshots on failure for debugging
- Set reasonable timeouts — cloud tests are slower than local
