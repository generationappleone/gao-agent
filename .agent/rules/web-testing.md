---
description: Enforce Playwright as the mandatory tool for all web-based testing with OS-aware auto-install.
---

# Web Testing Rule — Playwright Mandatory

## Rule

ALL web-based testing (E2E, browser testing, UI testing, smoke testing) **MUST** use **Playwright**.

**Do NOT use** Cypress, Puppeteer, Selenium, or other browser testing frameworks unless the project already has them configured AND the user explicitly requests to keep them.

## When This Rule Applies

This rule applies whenever the agent needs to:
- Run E2E / browser-based tests
- Perform UI smoke tests (verify pages load, forms work)
- Test web application flows (login, navigation, form submission)
- Verify responsive design or accessibility in a browser
- Run visual regression tests

## Auto-Install Protocol

**Before running ANY Playwright command**, the agent MUST check if Playwright is installed and install it if missing.

### Step 1: Check Installation

```bash
npx playwright --version 2>&1
```

If the command fails or returns an error → proceed to Step 2.

### Step 2: Install Playwright (OS-Aware)

#### Windows (PowerShell)
```powershell
npm install -D @playwright/test
npx playwright install --with-deps chromium
```

#### macOS (Bash/Zsh)
```bash
npm install -D @playwright/test
npx playwright install --with-deps chromium
```

#### Linux — Debian/Ubuntu (Bash)
```bash
npm install -D @playwright/test
npx playwright install --with-deps chromium
# --with-deps auto-installs system dependencies (libatk, libcups, libdrm, etc.)
```

#### Linux — Other Distros (Fedora, Arch, Alpine)
```bash
npm install -D @playwright/test
npx playwright install chromium
# If system deps fail, inform the user to install missing packages manually
```

> **Note:** `npx playwright install --with-deps` is the recommended approach.
> It handles OS-specific browser dependencies automatically on supported systems
> (Windows, macOS, Ubuntu/Debian). On unsupported Linux distros, the agent should
> detect the failure and guide the user.

### Step 3: Verify Installation

```bash
npx playwright --version
```

If verification fails, inform the user with the exact error message and suggest manual resolution.

### Step 4: Generate Config (If Missing)

If `playwright.config.ts` or `playwright.config.js` does not exist in the project root:

```bash
# Create a minimal Playwright config
```

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html'], ['list']],
  use: {
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { browserName: 'chromium' } },
  ],
});
```

## OS Detection

The agent MUST detect the user's OS before running install commands:

| OS | Detection | Shell |
|----|-----------|-------|
| Windows | `$env:OS` contains `Windows` or user metadata says Windows | PowerShell |
| macOS | `uname` returns `Darwin` | Bash/Zsh |
| Linux | `uname` returns `Linux` | Bash |

> The user's OS is provided in the system prompt metadata (`The USER's OS version is ...`).
> Always use this as the primary source of truth.

## Skill References

When running Playwright-based tests, the agent MUST read the relevant skill:

- **For writing test files:** `.agent/skills/playwright/SKILL.md`
- **For CLI-based browser automation:** `.agent/skills/playwright-cli/SKILL.md`

## Rules Integration

- This rule is loaded by `context-work.md` Step 1.6 (mandatory rules)
- This rule is loaded by `context-test.md` Step 1.1b (testing skills)
- This rule overrides any Cypress/Puppeteer preference in workflows
