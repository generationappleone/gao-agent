---
name: Python Security Testing
description: Skill for Python security testing with Bandit (SAST) and Safety (dependency vulnerability scanning), covering rule configuration, CI integration, and remediation.
---

# Python Security Testing Skill

## Overview
Bandit is a SAST tool for finding security issues in Python code. Safety checks Python dependencies against known vulnerability databases. Together they provide comprehensive Python security coverage.

---

## Bandit (Static Analysis)

### Installation
```bash
pip install bandit
```

### Usage
```bash
# Scan entire project
bandit -r . -f json -o bandit-report.json

# Scan with specific severity
bandit -r . -ll          # medium and above
bandit -r . -lll         # high only

# Exclude test files
bandit -r . --exclude ./tests,./venv

# Specific tests only
bandit -r . -t B301,B302,B303  # specific checks

# Skip specific tests
bandit -r . -s B101      # skip assert checks

# HTML report
bandit -r . -f html -o bandit-report.html

# With confidence filter
bandit -r . --confidence-level high
```

### Key Checks

| ID | Name | Risk | Detects |
|----|------|------|---------|
| B101 | assert_used | 🟡 Low | `assert` in production code |
| B102 | exec_used | 🔴 High | `exec()` usage |
| B103 | set_bad_file_permissions | 🟠 Medium | Overly permissive file perms |
| B104 | hardcoded_bind_all | 🟠 Medium | Binding to 0.0.0.0 |
| B105 | hardcoded_password_string | 🔴 High | Hardcoded passwords |
| B106 | hardcoded_password_funcarg | 🔴 High | Password in function args |
| B107 | hardcoded_password_default | 🔴 High | Password as default value |
| B110 | try_except_pass | 🟡 Low | Silent exception handling |
| B301 | pickle | 🔴 High | Unsafe deserialization |
| B303 | md5/sha1 | 🟠 Medium | Weak hash algorithms |
| B307 | eval | 🔴 High | `eval()` usage |
| B320 | xml_bad_etree | 🟠 Medium | XML External Entity (XXE) |
| B501 | request_no_cert_validation | 🔴 High | SSL verification disabled |
| B602 | subprocess_popen_shell | 🔴 High | Shell injection via subprocess |
| B608 | sql_injection | 🔴 High | SQL injection patterns |

### Config — `.bandit.yml`
```yaml
skips:
  - B101  # assert in tests is fine

exclude_dirs:
  - tests
  - venv
  - .venv
  - migrations

assert_used:
  skips:
    - "*/test_*.py"
    - "*_test.py"
```

### Inline Suppression
```python
# Only when justified:
password = get_from_vault("db_password")  # nosec B105 - retrieved from vault, not hardcoded
```

---

## Safety (Dependency Scanning)

### Installation
```bash
pip install safety
```

### Usage
```bash
# Check installed packages
safety check

# Check requirements file
safety check -r requirements.txt

# JSON output
safety check --output json > safety-report.json

# Full report
safety check --full-report

# With API key (for commercial DB)
safety check --key YOUR_API_KEY
```

### CI/CD Integration
```yaml
# GitHub Actions
- name: Python Security
  run: |
    pip install bandit safety
    bandit -r src/ -f json -o bandit.json || true
    safety check -r requirements.txt --output json > safety.json || true
```

## Best Practices
- Run both Bandit AND Safety — they complement each other
- Use `bandit -r . -ll` in CI (fail on medium+)
- Never use `# nosec` without a comment explaining why
- Run `safety check` before every deployment
- Use virtual environments to keep dependency checks accurate
- Configure `.bandit.yml` to exclude test directories
- Review Bandit B105/B106/B107 findings carefully — false positives possible
