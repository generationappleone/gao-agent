---
name: ESLint Security
description: Skill for static security analysis with ESLint security plugins, covering vulnerability detection, unsafe patterns, and security linting rules.
---

# ESLint Security Skill

## Overview
ESLint security plugins detect potential security vulnerabilities in JavaScript/TypeScript code through static analysis — catching unsafe patterns before they reach production.

## Installation
```bash
# Core security plugin
npm install -D eslint-plugin-security

# Additional security-focused plugins
npm install -D eslint-plugin-no-unsanitized   # DOM XSS prevention
npm install -D eslint-plugin-no-secrets        # secret detection
npm install -D @microsoft/eslint-plugin-sdl    # Microsoft SDL rules
```

## Configuration — `.eslintrc.js` (Legacy)
```javascript
module.exports = {
  plugins: ['security', 'no-unsanitized', 'no-secrets'],
  extends: ['plugin:security/recommended-legacy'],
  rules: {
    // Security plugin
    'security/detect-object-injection': 'warn',
    'security/detect-non-literal-regexp': 'warn',
    'security/detect-unsafe-regex': 'error',
    'security/detect-buffer-noassert': 'error',
    'security/detect-eval-with-expression': 'error',
    'security/detect-no-csrf-before-method-override': 'error',
    'security/detect-possible-timing-attacks': 'warn',
    'security/detect-pseudoRandomBytes': 'warn',
    'security/detect-non-literal-fs-filename': 'warn',
    'security/detect-non-literal-require': 'warn',
    'security/detect-child-process': 'warn',

    // No unsanitized DOM
    'no-unsanitized/method': 'error',
    'no-unsanitized/property': 'error',

    // No hardcoded secrets
    'no-secrets/no-secrets': ['error', { tolerance: 4.5 }],
  },
};
```

## Configuration — `eslint.config.js` (Flat Config / ESLint 9+)
```javascript
import security from 'eslint-plugin-security';

export default [
  security.configs.recommended,
  {
    rules: {
      'security/detect-eval-with-expression': 'error',
      'security/detect-unsafe-regex': 'error',
      'security/detect-buffer-noassert': 'error',
    },
  },
];
```

## Key Rules Explained

| Rule | Detects | Severity |
|------|---------|----------|
| `detect-eval-with-expression` | `eval()` with dynamic input | 🔴 Critical |
| `detect-unsafe-regex` | ReDoS vulnerable regex | 🔴 Critical |
| `detect-non-literal-require` | Dynamic `require()` (path injection) | 🟠 High |
| `detect-child-process` | `child_process.exec()` (command injection) | 🟠 High |
| `detect-object-injection` | Bracket notation with variable keys | 🟡 Medium |
| `detect-possible-timing-attacks` | Non-constant-time comparison | 🟡 Medium |
| `detect-pseudoRandomBytes` | `Math.random()` for security | 🟡 Medium |
| `detect-no-csrf-before-method-override` | CSRF bypass via method override | 🟠 High |
| `detect-non-literal-fs-filename` | Dynamic filesystem paths | 🟡 Medium |

## CLI
```bash
npx eslint . --ext .ts,.js,.tsx,.jsx          # full scan
npx eslint . --format json > security-report.json  # JSON output
npx eslint . --fix                             # auto-fix where possible
npx eslint --print-config file.js             # check applied rules
```

## Best Practices
- Enable security plugins in CI/CD — block merge on `error` level rules
- Use `error` for critical rules (eval, unsafe regex), `warn` for medium
- Combine with TypeScript strict mode for additional type safety
- Review `warn` level findings regularly — they may indicate real issues
- Use `// eslint-disable-next-line security/rule-name` only with justification comment
