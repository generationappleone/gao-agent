---
name: ESLint Security
description: Skill for static security analysis with ESLint security plugins, covering vulnerability detection, unsafe patterns, and security linting rules.
---

# ESLint Security Skill

## Overview
ESLint security plugins detect common vulnerabilities and unsafe patterns in JavaScript/TypeScript code at development time. This includes detecting eval injection, prototype pollution, regex denial-of-service, hardcoded secrets, and unsafe DOM manipulation.

**References**:
- [eslint-plugin-security](https://github.com/eslint-community/eslint-plugin-security)
- [eslint-plugin-no-secrets](https://github.com/nickdeis/eslint-plugin-no-secrets)
- [ESLint Documentation](https://eslint.org/docs/)

---

## Setup

```bash
npm install -D eslint eslint-plugin-security eslint-plugin-no-secrets
```

### Flat Config (ESLint 9+)
```javascript
// eslint.config.js
import security from 'eslint-plugin-security';
import noSecrets from 'eslint-plugin-no-secrets';

export default [
  {
    plugins: {
      security,
      'no-secrets': noSecrets,
    },
    rules: {
      // ── Security Plugin ──
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
      'security/detect-disable-mustache-escape': 'error',
      'security/detect-new-buffer': 'error',
      'security/detect-bidi-characters': 'error',

      // ── No Secrets ──
      'no-secrets/no-secrets': ['error', { tolerance: 4.5 }],

      // ── Built-in Security Rules ──
      'no-eval': 'error',
      'no-implied-eval': 'error',
      'no-new-func': 'error',
      'no-script-url': 'error',
    },
  },
];
```

---

## Common Security Rules Explained

### Critical — Always Error
```javascript
// ❌ detect-eval-with-expression: Dynamic code execution (RCE risk)
eval(userInput);                   // DANGEROUS
new Function('return ' + userInput)();  // DANGEROUS
setTimeout(userInput, 1000);       // DANGEROUS (if string)

// ✅ Safe alternatives
JSON.parse(userInput);             // For JSON data
const fn = allowedFunctions[key];  // Allowlist lookup

// ❌ detect-unsafe-regex: ReDoS (Regular Expression Denial of Service)
const re = /^(a+)+$/;             // Catastrophic backtracking
const re2 = /(a|a)*$/;            // Exponential complexity

// ✅ Safe regex
const re = /^a+$/;                // Linear time
const re = /^[a-z]{1,50}$/;       // Bounded quantifier

// ❌ detect-new-buffer: Buffer allocation vulnerabilities
new Buffer(userSize);              // Can leak memory contents (uninitialized)

// ✅ Safe buffer
Buffer.alloc(size);                // Zero-filled
Buffer.from(data);                 // From known data

// ❌ detect-bidi-characters: Unicode trojan source attacks
const access = "admin";‮ ⁦// Check if admin⁩ ⁦
// The above line contains hidden bidirectional override characters

// ❌ detect-disable-mustache-escape: XSS in templates
{{{ userInput }}}                  // Unescaped HTML output
<%- userInput %>                   // EJS raw output

// ✅ Always escape
{{ userInput }}                    // Auto-escaped
<%= userInput %>                   // EJS escaped
```

### Warning — Review Required
```javascript
// ⚠️ detect-object-injection: Prototype pollution / injection
obj[userInput] = value;            // Can access __proto__, constructor

// ✅ Safe alternatives
if (Object.hasOwn(obj, userInput)) { obj[userInput] = value; }
const safeMap = new Map();         // Maps don't have prototype chain issues
const value = allowedKeys.includes(key) ? obj[key] : undefined;

// ⚠️ detect-non-literal-fs-filename: Path traversal
fs.readFile(userInput);            // Can read ../../../etc/passwd

// ✅ Safe file access
const safePath = path.resolve(UPLOAD_DIR, path.basename(userInput));
if (!safePath.startsWith(UPLOAD_DIR)) throw new Error('Invalid path');
fs.readFile(safePath);

// ⚠️ detect-child-process: Command injection
exec(`ls ${userInput}`);           // Can inject: ; rm -rf /

// ✅ Safe subprocess
execFile('ls', [sanitizedPath]);   // Array args, no shell interpolation

// ⚠️ detect-possible-timing-attacks: Authentication bypass
if (token === secretToken) { ... } // Timing side-channel

// ✅ Constant-time comparison
import crypto from 'crypto';
if (crypto.timingSafeEqual(Buffer.from(token), Buffer.from(secretToken))) { ... }

// ⚠️ detect-pseudoRandomBytes: Weak randomness
Math.random();                     // Predictable, NOT cryptographic

// ✅ Cryptographic random
crypto.randomUUID();
crypto.randomBytes(32).toString('hex');
```

---

## Additional ESLint Rules for Security

```javascript
// eslint.config.js (additional rules)
{
  rules: {
    // Prevent dangerous DOM manipulation (XSS)
    'no-restricted-properties': ['error',
      { object: 'document', property: 'write', message: 'Use DOM APIs instead' },
      { object: 'window', property: 'eval', message: 'Never use eval' },
    ],

    // Prevent dangerous React patterns
    'react/no-danger': 'error',                 // dangerouslySetInnerHTML
    'react/no-danger-with-children': 'error',

    // Prevent console.log in production
    'no-console': ['warn', { allow: ['warn', 'error'] }],

    // Enforce strict equality
    'eqeqeq': ['error', 'always'],

    // Prevent type coercion surprises
    'no-implicit-coercion': 'error',
  },
}
```

---

## CI Integration

```yaml
# .github/workflows/security-lint.yml
name: Security Lint
on: [push, pull_request]
jobs:
  eslint-security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npx eslint --max-warnings 0 "src/**/*.{ts,tsx}"
        continue-on-error: false
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Error for critical** | `eval`, `unsafe-regex`, `new-buffer`, `bidi-characters` → error |
| **Warn for review** | `object-injection`, `non-literal-fs`, `child-process` → warn |
| **No secrets** | `no-secrets/no-secrets` to detect hardcoded credentials |
| **Constant-time** | `crypto.timingSafeEqual` for authentication comparisons |
| **crypto.randomUUID** | Replace `Math.random()` for security-sensitive contexts |
| **Allowlists** | Use allowlists instead of blocklists for object access |
| **CI enforcement** | `--max-warnings 0` to fail on any security warning |
| **Periodic review** | Review security warnings regularly, suppress only with justification |

---

## Rules Integration
- **Critical**: eval injection, unsafe regex, buffer vulnerabilities, bidi attacks → always error
- **Review**: object injection, file path traversal, child process, timing attacks → warn + review
- **Secrets**: `no-secrets` plugin for detecting hardcoded API keys and passwords
- **CI**: Run in CI with `--max-warnings 0` for strict enforcement
- **React**: `no-danger` to prevent `dangerouslySetInnerHTML` XSS
