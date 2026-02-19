---
name: Semgrep
description: Skill for Semgrep — fast, open-source static analysis for finding bugs, security vulnerabilities, and enforcing code standards with custom rules.
---

# Semgrep — Static Code Analysis & Secrets Scanning

## Overview
Semgrep is an open-source, fast static analysis tool for finding bugs, detecting security vulnerabilities, and enforcing coding standards. It supports 30+ languages and enables custom rule creation.

## CLI Usage
```bash
# Scan with recommended rules
semgrep --config auto .

# Security-focused scan
semgrep --config p/security-audit .

# OWASP Top 10 scan
semgrep --config p/owasp-top-ten .

# Secrets detection
semgrep --config p/secrets .

# Specific language rules
semgrep --config p/python .
semgrep --config p/javascript .
```

## Custom Rules
```yaml
rules:
  - id: sql-injection-risk
    patterns:
      - pattern: |
          $QUERY = f"SELECT ... {$USER_INPUT} ..."
      - pattern-not: |
          $QUERY = f"SELECT ... {sanitize($USER_INPUT)} ..."
    message: "Possible SQL injection via f-string interpolation"
    severity: ERROR
    languages: [python]
    metadata:
      cwe: ["CWE-89"]
      owasp: ["A03:2021"]

  - id: hardcoded-secret
    pattern: |
      $KEY = "AKIA..."
    message: "Hardcoded AWS access key detected"
    severity: ERROR
    languages: [python, javascript, typescript]
```

## CI/CD Integration
```yaml
# GitHub Actions
- uses: returntocorp/semgrep-action@v1
  with:
    config: >-
      p/security-audit
      p/secrets
      p/owasp-top-ten
```

## Best Practices
- Use **p/security-audit** as baseline ruleset
- Write **custom rules** for business logic vulnerabilities
- Enable **secrets scanning** in CI/CD pipelines
- Use **Semgrep Supply Chain** for dependency analysis
