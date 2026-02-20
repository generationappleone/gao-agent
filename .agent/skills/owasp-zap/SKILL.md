---
name: OWASP ZAP
description: Skill for dynamic application security testing (DAST) with OWASP ZAP, covering automated scanning, active/passive scanning, API scanning, authentication, and CI integration.
---

# OWASP ZAP Skill

## Overview
OWASP ZAP (Zed Attack Proxy) is the world's most popular free DAST (Dynamic Application Security Testing) tool. It automatically finds security vulnerabilities in web applications and APIs during development and testing by intercepting, modifying, and replaying HTTP traffic.

**Minimum Version**: ZAP 2.14+
**References**:
- [ZAP Documentation](https://www.zaproxy.org/docs/)
- [ZAP API](https://www.zaproxy.org/docs/api/)
- [ZAP Docker](https://www.zaproxy.org/docs/docker/)

---

## Quick Start

```bash
# Docker (recommended for CI)
docker pull ghcr.io/zaproxy/zaproxy:stable

# Baseline scan (passive only, fast)
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py \
  -t https://staging.myapp.com \
  -r report.html

# Full scan (active + passive)
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-full-scan.py \
  -t https://staging.myapp.com \
  -r report.html

# API scan (OpenAPI/Swagger)
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-api-scan.py \
  -t https://staging.myapp.com/api/docs/openapi.json \
  -f openapi \
  -r api-report.html
```

---

## Scan Types

### Passive Scan (No Attack Traffic)
```bash
# Baseline scan — safe for production
# Spiders the site, analyzes responses without attacking
docker run -v $(pwd)/reports:/zap/wrk:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -t https://myapp.com \
  -r baseline-report.html \
  -J baseline-report.json \
  -w baseline-report.md \
  -c baseline-rules.conf \
  -d                            # Show debug messages

# Detects: missing security headers, cookie flags, info disclosure,
#          CSP issues, CORS misconfig, certificate problems
```

### Active Scan (Attack Traffic)
```bash
# Full scan — ONLY on staging/test environments
# Actively attacks the target looking for vulnerabilities
docker run -v $(pwd)/reports:/zap/wrk:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py \
  -t https://staging.myapp.com \
  -r full-report.html \
  -J full-report.json \
  -m 10                         # 10 minute scan timeout
  -a                            # Include alpha rules

# Detects: SQL injection, XSS, CSRF, path traversal, command injection,
#          SSRF, XXE, insecure deserialization, broken auth
```

### API Scan
```bash
# Scan REST API from OpenAPI spec
docker run -v $(pwd)/reports:/zap/wrk:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-api-scan.py \
  -t https://staging.myapp.com/api/docs/openapi.json \
  -f openapi \
  -r api-report.html \
  -J api-report.json \
  -O                            # Upload ZAP report as SARIF

# Scan GraphQL API
docker run -v $(pwd)/reports:/zap/wrk:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-api-scan.py \
  -t https://staging.myapp.com/graphql \
  -f graphql \
  -r graphql-report.html
```

---

## Rule Configuration

```conf
# baseline-rules.conf
# Format: rule_id  WARN|FAIL|IGNORE  rule_name
# See: https://www.zaproxy.org/docs/alerts/

# Security Headers
10010   FAIL    Cookie without Secure flag
10011   FAIL    Cookie without HttpOnly flag  
10012   FAIL    Anti-CSRF Tokens Missing
10015   FAIL    Incomplete or No Cache-control Header
10016   FAIL    Web Browser XSS Protection Not Enabled
10017   FAIL    Cross-Domain JavaScript Source File Inclusion
10020   FAIL    X-Frame-Options Issue
10021   FAIL    X-Content-Type-Options Missing
10035   FAIL    Strict-Transport-Security Missing
10036   WARN    Server Leaks Version Information
10037   WARN    Server Leaks Information via "X-Powered-By"
10038   FAIL    Content Security Policy (CSP) Not Set
10098   WARN    Cross-Domain Misconfiguration
10202   WARN    Absence of Anti-CSRF Tokens

# Information Disclosure
10023   WARN    Information Disclosure - Debug Error Messages
10024   WARN    Information Disclosure - Sensitive Information in URL
10025   WARN    Information Disclosure - Sensitive Information in HTTP Referrer Header
10027   WARN    Information Disclosure - Suspicious Comments
10032   WARN    Viewstate
10040   WARN    Secure Pages Include Mixed Content
10054   FAIL    Cookie without SameSite Attribute
10055   FAIL    CSP: Wildcard Directive
10096   WARN    Timestamp Disclosure
90004   WARN    Insufficient Site Isolation Against Spectre Vulnerability
90022   FAIL    Application Error Disclosure

# Active Scan Rules
40003   FAIL    CRLF Injection
40008   FAIL    Parameter Tampering
40009   FAIL    Server Side Include
40012   FAIL    Cross Site Scripting (Reflected)
40014   FAIL    Cross Site Scripting (Persistent)
40018   FAIL    SQL Injection
40019   FAIL    SQL Injection - MySQL
40020   FAIL    SQL Injection - Hypersonic
40021   FAIL    SQL Injection - Oracle
40022   FAIL    SQL Injection - PostgreSQL
40023   FAIL    Possible Username Enumeration
40024   FAIL    SQL Injection - SQLite
40026   FAIL    Cross Site Scripting (DOM Based)
40029   FAIL    Trace.axd Information Leak
90019   FAIL    Server Side Code Injection
90020   FAIL    Remote OS Command Injection
90021   FAIL    XPath Injection
```

---

## Authentication Context

```yaml
# zap-auth-context.yml (for authenticated scanning)
env:
  contexts:
    - name: "MyApp Authenticated"
      urls:
        - "https://staging.myapp.com.*"
      authentication:
        method: "json"
        parameters:
          loginPageUrl: "https://staging.myapp.com/api/auth/login"
          loginRequestUrl: "https://staging.myapp.com/api/auth/login"
          loginRequestBody: '{"email":"{%username%}","password":"{%password%}"}'
        verification:
          method: "response"
          loggedInRegex: "accessToken"
          loggedOutRegex: "Unauthorized"
      sessionManagement:
        method: "headers"
        parameters:
          Authorization: "Bearer {%token%}"
      users:
        - name: "test-admin"
          credentials:
            username: "admin@test.com"
            password: "TestPass123!"
```

---

## CI/CD Integration

```yaml
# .github/workflows/dast.yml
name: DAST Security Scan
on:
  push:
    branches: [staging]
  schedule:
    - cron: '0 2 * * 1'              # Weekly on Monday 2 AM

jobs:
  zap-baseline:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: ZAP Baseline Scan
        uses: zaproxy/action-baseline@v0.12.0
        with:
          target: ${{ secrets.STAGING_URL }}
          rules_file_name: 'baseline-rules.conf'
          cmd_options: '-J report.json'

      - name: Upload Report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: zap-baseline-report
          path: report_html.html

  zap-api-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: ZAP API Scan
        uses: zaproxy/action-api-scan@v0.7.0
        with:
          target: '${{ secrets.STAGING_URL }}/api/docs/openapi.json'
          format: openapi
          cmd_options: '-J api-report.json'

      - name: Check for High/Critical findings
        run: |
          HIGH_COUNT=$(jq '[.site[].alerts[] | select(.riskcode >= 3)] | length' api-report.json)
          if [ "$HIGH_COUNT" -gt 0 ]; then
            echo "❌ Found $HIGH_COUNT high/critical vulnerabilities!"
            exit 1
          fi

      - name: Upload Report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: zap-api-report
          path: report_html.html
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Baseline first** | Start with passive baseline scan (safe, fast) |
| **Staging only** | Active scans ONLY on staging/test environments, NEVER production |
| **API spec** | Provide OpenAPI/Swagger spec for comprehensive API scanning |
| **Rule config** | Customize rules: FAIL for critical, WARN for informational |
| **Authentication** | Configure auth context for scanning protected endpoints |
| **CI gating** | Fail CI pipeline on high/critical findings |
| **Regular scans** | Schedule weekly full scans, baseline on every deploy |
| **Fix tracking** | Track findings in issue tracker, link to remediation |
| **False positives** | Document and exclude confirmed false positives |
| **SARIF output** | Use SARIF format for GitHub Security tab integration |

---

## Rules Integration
- **Scanning**: Baseline (passive/safe), Full (active/staging), API (OpenAPI/GraphQL)
- **Configuration**: Rule severity levels (FAIL/WARN/IGNORE), auth context
- **CI/CD**: GitHub Actions with `zaproxy/action-*`, fail on high/critical
- **Reporting**: HTML+JSON+SARIF output, artifact upload on failure
- **Security**: OWASP Top 10 coverage, weekly scheduled scans
