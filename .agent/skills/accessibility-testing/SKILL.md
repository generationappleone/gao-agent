---
name: Accessibility Testing
description: Skill for accessibility testing with pa11y, axe-core, and Lighthouse CI, covering WCAG 2.1 AA compliance, automated audits, and CI/CD integration.
---

# Accessibility Testing Skill

## Overview
Accessibility testing ensures web apps are usable by people with disabilities, meeting WCAG 2.1 AA standards. This skill covers 3 complementary tools.

## Tool Comparison

| Tool | Best For | Standard | Format |
|------|---------|---------|--------|
| **pa11y** | Quick CLI audits, CI gates | WCAG2AA | CLI/Node |
| **axe-core** | In-browser testing, Playwright/Cypress | WCAG2AA | Library |
| **Lighthouse CI** | Full web vitals + a11y audit | WCAG2AA | CLI |

---

## pa11y

### Installation
```bash
npm install -D pa11y pa11y-ci
```

### CLI Usage
```bash
# Single page
npx pa11y http://localhost:3000

# With specific standard
npx pa11y --standard WCAG2AA http://localhost:3000

# JSON output
npx pa11y --reporter json http://localhost:3000 > a11y-report.json

# Ignore specific rules
npx pa11y --ignore "WCAG2AA.Principle1.Guideline1_4.1_4_3.G18.Fail" http://localhost:3000
```

### pa11y-ci Config — `.pa11yci.json`
```json
{
  "defaults": {
    "standard": "WCAG2AA",
    "timeout": 30000,
    "wait": 2000,
    "chromeLaunchConfig": { "args": ["--no-sandbox"] }
  },
  "urls": [
    "http://localhost:3000/",
    "http://localhost:3000/login",
    "http://localhost:3000/dashboard",
    {
      "url": "http://localhost:3000/admin",
      "actions": [
        "set field #email to admin@test.com",
        "set field #password to password",
        "click element #login-btn",
        "wait for url to be http://localhost:3000/admin"
      ]
    }
  ]
}
```

```bash
npx pa11y-ci    # runs all URLs from config
```

---

## axe-core

### With Playwright
```bash
npm install -D @axe-core/playwright
```

```typescript
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test.describe('Accessibility', () => {
  test('homepage meets WCAG AA', async ({ page }) => {
    await page.goto('/');
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
      .exclude('.third-party-widget')  // exclude known issues
      .analyze();

    const violations = results.violations.map(v => ({
      id: v.id,
      impact: v.impact,
      description: v.description,
      nodes: v.nodes.length,
    }));
    console.table(violations);
    expect(results.violations).toEqual([]);
  });
});
```

### With Cypress
```bash
npm install -D cypress-axe
```

```typescript
// cypress/support/e2e.ts
import 'cypress-axe';

// Test file
describe('Accessibility', () => {
  it('has no violations', () => {
    cy.visit('/');
    cy.injectAxe();
    cy.checkA11y(null, {
      runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa'] },
    });
  });
});
```

---

## Lighthouse CI

### Installation
```bash
npm install -D @lhci/cli
```

### Config — `lighthouserc.js`
```javascript
module.exports = {
  ci: {
    collect: {
      url: [
        'http://localhost:3000/',
        'http://localhost:3000/login',
        'http://localhost:3000/dashboard',
      ],
      startServerCommand: 'npm run build && npm run start',
      numberOfRuns: 3,
    },
    assert: {
      preset: 'lighthouse:recommended',
      assertions: {
        'categories:accessibility': ['error', { minScore: 0.9 }],
        'categories:performance': ['warn', { minScore: 0.8 }],
        'categories:seo': ['warn', { minScore: 0.9 }],
        'categories:best-practices': ['warn', { minScore: 0.9 }],
      },
    },
    upload: {
      target: 'filesystem',
      outputDir: '.lighthouseci',
    },
  },
};
```

```bash
npx lhci autorun                # full run
npx lhci collect --url=http://localhost:3000   # collect only
npx lhci assert                 # check thresholds
```

---

## WCAG 2.1 AA Checklist

| Principle | Guideline | Check |
|-----------|----------|-------|
| **Perceivable** | Text alternatives | All `<img>` have `alt` |
| | Captions | Video has captions |
| | Color contrast | ≥ 4.5:1 normal text, ≥ 3:1 large text |
| | Resize text | Readable at 200% zoom |
| **Operable** | Keyboard | All interactive elements focusable |
| | Focus visible | Focus indicators visible |
| | Skip links | Skip to content link |
| | No seizures | No flashing > 3/sec |
| **Understandable** | Language | `lang` attribute on `<html>` |
| | Labels | All form inputs have labels |
| | Error messages | Clear error identification |
| **Robust** | Valid HTML | No duplicate IDs |
| | ARIA | Correct ARIA roles and states |
| | Name/Role/Value | Interactive elements properly labeled |

## Best Practices
- Run accessibility tests on EVERY page, not just the homepage
- Test with keyboard-only navigation
- Test with screen reader (NVDA, VoiceOver)
- Use semantic HTML (`<nav>`, `<main>`, `<article>`) before ARIA
- Ensure all interactive elements have visible focus styles
- Test in both light and dark mode
- Include accessibility tests in CI/CD pipeline
