---
name: Semgrep
description: Skill for Semgrep — fast, open-source static analysis for finding bugs, security vulnerabilities, and enforcing code standards with custom rules.
---

# Semgrep Skill

## Overview
Semgrep is a fast, open-source static analysis tool that finds bugs, security vulnerabilities, and enforces code standards. Unlike regex-based tools, Semgrep understands code structure (AST-aware), supporting 30+ languages with pattern matching that respects syntax.

**References**:
- [Semgrep Documentation](https://semgrep.dev/docs/)
- [Semgrep Registry](https://semgrep.dev/explore)
- [Semgrep Playground](https://semgrep.dev/playground)

---

## Setup

```bash
# Install
pip install semgrep
# or
brew install semgrep

# Quick scan with community rules
semgrep --config auto .

# Scan with specific rulesets
semgrep --config p/security-audit .
semgrep --config p/owasp-top-ten .
semgrep --config p/nodejs .
semgrep --config p/typescript .
semgrep --config p/react .
```

---

## Rulesets

```bash
# ── Security ──
semgrep --config p/security-audit .           # Comprehensive security
semgrep --config p/owasp-top-ten .            # OWASP Top 10
semgrep --config p/jwt .                       # JWT vulnerabilities
semgrep --config p/xss .                       # Cross-site scripting
semgrep --config p/sql-injection .             # SQL injection

# ── Language-specific ──
semgrep --config p/javascript .
semgrep --config p/typescript .
semgrep --config p/python .
semgrep --config p/java .
semgrep --config p/golang .
semgrep --config p/php .

# ── Frameworks ──
semgrep --config p/react .
semgrep --config p/nextjs .
semgrep --config p/express .
semgrep --config p/django .
semgrep --config p/flask .
semgrep --config p/laravel .

# ── Best practices ──
semgrep --config p/default .                   # Default recommended
semgrep --config p/secrets .                   # Hardcoded secrets
semgrep --config p/docker .                    # Dockerfile issues

# ── Multiple configs ──
semgrep --config p/security-audit --config p/owasp-top-ten --config .semgrep/ .
```

---

## Custom Rules

```yaml
# .semgrep/security-rules.yml
rules:
  # ── Prevent SQL Injection ──
  - id: no-raw-sql-interpolation
    patterns:
      - pattern: |
          $DB.query(`... ${$VAR} ...`)
      - pattern: |
          $DB.query("..." + $VAR + "...")
      - pattern: |
          $DB.$METHOD(`... ${$VAR} ...`)
    message: >
      SQL injection risk: User input interpolated into SQL query.
      Use parameterized queries instead: $DB.query('SELECT * FROM users WHERE id = $1', [userId])
    severity: ERROR
    languages: [javascript, typescript]
    metadata:
      cwe: ["CWE-89: SQL Injection"]
      owasp: ["A03:2021 - Injection"]
      category: security
      confidence: HIGH

  # ── Prevent eval() usage ──
  - id: no-eval
    pattern: eval(...)
    message: >
      Do not use eval(). It executes arbitrary code and is a critical security risk.
      Use JSON.parse(), Function constructor, or refactor logic.
    severity: ERROR
    languages: [javascript, typescript]
    metadata:
      cwe: ["CWE-95: Eval Injection"]

  # ── Require HttpOnly cookies ──
  - id: cookie-missing-httponly
    patterns:
      - pattern: |
          res.cookie($NAME, $VALUE, { ..., httpOnly: false, ... })
      - pattern: |
          res.cookie($NAME, $VALUE, { ... })
      - pattern-not: |
          res.cookie($NAME, $VALUE, { ..., httpOnly: true, ... })
    message: >
      Cookie '$NAME' is missing httpOnly flag. Set httpOnly: true to prevent XSS access.
    severity: WARNING
    languages: [javascript, typescript]
    metadata:
      cwe: ["CWE-1004: Sensitive Cookie Without 'HttpOnly' Flag"]

  # ── Prevent hardcoded secrets ──
  - id: hardcoded-secret
    patterns:
      - pattern: |
          const $KEY = "..."
      - metavariable-regex:
          metavariable: $KEY
          regex: (password|secret|apiKey|api_key|token|privateKey|private_key)
      - pattern-not: |
          const $KEY = process.env.$ENV
    message: >
      Hardcoded secret detected in '$KEY'. Use environment variables (process.env) instead.
    severity: ERROR
    languages: [javascript, typescript]
    metadata:
      cwe: ["CWE-798: Hardcoded Credentials"]
      category: security

  # ── Prevent dangerouslySetInnerHTML ──
  - id: no-dangerous-innerhtml
    pattern: |
      <$EL dangerouslySetInnerHTML={...} />
    message: >
      dangerouslySetInnerHTML can lead to XSS attacks. Use DOMPurify.sanitize()
      or render text content directly.
    severity: WARNING
    languages: [typescript, javascript]
    metadata:
      cwe: ["CWE-79: Cross-site Scripting"]

  # ── Enforce parameterized queries ──
  - id: prisma-raw-query-unparameterized
    pattern: |
      prisma.$queryRawUnsafe(...)
    message: >
      Use prisma.$queryRaw (template literal) instead of $queryRawUnsafe.
      Template literals are automatically parameterized.
    severity: ERROR
    languages: [typescript, javascript]

  # ── Prevent console.log in production ──
  - id: no-console-log
    pattern: console.log(...)
    message: >
      Remove console.log statements. Use a structured logger (pino, winston) instead.
    severity: WARNING
    languages: [javascript, typescript]
    paths:
      include:
        - src/
      exclude:
        - src/**/*.test.*
        - src/**/*.spec.*

  # ── Require error handling in async routes ──
  - id: express-async-no-try-catch
    patterns:
      - pattern: |
          app.$METHOD($PATH, async (req, res) => {
            ...
            $AWAIT
            ...
          })
      - pattern-not: |
          app.$METHOD($PATH, async (req, res) => {
            try { ... } catch { ... }
          })
      - metavariable-pattern:
          metavariable: $AWAIT
          pattern: await ...
    message: >
      Async Express handler without try/catch. Unhandled rejections will crash the server.
      Wrap in try/catch or use an async error wrapper.
    severity: WARNING
    languages: [javascript, typescript]
```

---

## Configuration

```yaml
# .semgrep.yml (project config)
# Automatically used when running `semgrep` in this directory

rules: []  # Custom rules inline (or use separate files)

# Include external rulesets
configs:
  - p/security-audit
  - p/owasp-top-ten
  - .semgrep/

# Scan paths
paths:
  include:
    - src/
    - lib/
  exclude:
    - node_modules/
    - dist/
    - build/
    - coverage/
    - '*.test.ts'
    - '*.spec.ts'
    - __tests__/
    - __mocks__/
```

---

## CI/CD Integration

```yaml
# .github/workflows/semgrep.yml
name: Semgrep Security Scan
on:
  pull_request: {}
  push:
    branches: [main, staging]

jobs:
  semgrep:
    runs-on: ubuntu-latest
    container:
      image: semgrep/semgrep
    steps:
      - uses: actions/checkout@v4

      - name: Run Semgrep
        run: |
          semgrep ci \
            --config p/security-audit \
            --config p/owasp-top-ten \
            --config .semgrep/ \
            --sarif --output results.sarif \
            --error                          # Exit code 1 on findings
        env:
          SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}

      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: results.sarif

      - name: Check for critical findings
        if: failure()
        run: |
          echo "❌ Semgrep found security issues. Please fix before merging."
          exit 1
```

---

## Command Reference

```bash
# Basic scan
semgrep --config auto .                  # Auto-detect language, use recommended rules
semgrep --config p/security-audit src/   # Scan specific directory

# Output formats
semgrep --config auto --json .           # JSON output
semgrep --config auto --sarif .          # SARIF (GitHub Security)
semgrep --config auto --emacs .          # Emacs-friendly
semgrep --config auto --vim .            # Vim-friendly

# Filtering
semgrep --severity ERROR .              # Only errors
semgrep --severity WARNING --severity ERROR .
semgrep --exclude '*.test.ts' .         # Exclude test files
semgrep --include '*.ts' .              # Only TypeScript files

# CI mode (Semgrep Cloud)
semgrep ci                               # Diff-aware scanning in CI

# Test custom rules
semgrep --test .semgrep/                 # Test rule files with test annotations
semgrep --validate .semgrep/             # Validate rule syntax

# Dry run (show what would be scanned)
semgrep --config auto --dryrun .
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Start with auto** | `semgrep --config auto` for quick baseline |
| **Layer rulesets** | security-audit + owasp-top-ten + framework-specific |
| **Custom rules** | Write project-specific rules for patterns unique to your codebase |
| **CI gating** | `--error` flag to fail CI on findings |
| **SARIF** | Upload to GitHub Security tab for tracking |
| **Exclude tests** | Skip test/spec files to reduce noise |
| **Severity levels** | ERROR for blockers, WARNING for review items |
| **Metadata** | Include CWE, OWASP, confidence in custom rules |
| **Incremental** | `semgrep ci` for diff-aware scanning (only changed files) |
| **Test rules** | Use `--test` with annotated test cases for custom rules |

---

## Rules Integration
- **Scanning**: AST-aware pattern matching across 30+ languages
- **Rulesets**: Registry (security-audit, owasp, framework-specific) + custom
- **Custom rules**: YAML patterns with metavariables, regex, severity
- **CI/CD**: GitHub Actions with SARIF upload, exit on findings
- **Security**: SQL injection, XSS, eval, hardcoded secrets, cookie flags
