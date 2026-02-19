---
name: OWASP ZAP
description: Skill for dynamic application security testing (DAST) with OWASP ZAP, covering automated scanning, active/passive scanning, API scanning, authentication, and CI integration.
---

# OWASP ZAP Skill

## Overview
OWASP ZAP (Zed Attack Proxy) is an open-source DAST tool for finding security vulnerabilities in web applications by actively probing them at runtime.

## Installation
```bash
# Docker (recommended)
docker pull ghcr.io/zaproxy/zaproxy:stable

# Windows/macOS/Linux installer
# Download from: https://www.zaproxy.org/download/

# CLI wrapper
pip install zaproxy   # Python API client
```

## Scanning Modes

### Quick Baseline Scan (Passive)
```bash
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py \
  -t http://host.docker.internal:3000 \
  -J report.json \
  -r report.html
```

### Full Active Scan
```bash
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-full-scan.py \
  -t http://host.docker.internal:3000 \
  -J report.json \
  -r report.html \
  -m 10  # minutes timeout
```

### API Scan (OpenAPI/Swagger)
```bash
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-api-scan.py \
  -t http://host.docker.internal:3000/api-docs/swagger.json \
  -f openapi \
  -J api-report.json \
  -r api-report.html
```

### GraphQL Scan
```bash
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-api-scan.py \
  -t http://host.docker.internal:3000/graphql \
  -f graphql
```

## Authentication Setup

### JSON Authentication
```yaml
# zap-config.yaml
env:
  contexts:
    - name: "MyApp"
      urls: ["http://localhost:3000"]
      authentication:
        method: "json"
        parameters:
          loginPageUrl: "http://localhost:3000/api/auth/login"
          loginRequestUrl: "http://localhost:3000/api/auth/login"
          loginRequestBody: '{"email":"{%username%}","password":"{%password%}"}'
        verification:
          method: "response"
          loggedInRegex: "\\Qtoken\\E"
      users:
        - name: "admin"
          credentials:
            username: "admin@test.com"
            password: "password"
```

```bash
docker run -t -v $(pwd):/zap/config ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py -t http://host.docker.internal:3000 \
  --config-file /zap/config/zap-config.yaml
```

## ZAP CLI (zap-cli)
```bash
pip install zaproxy

# Start ZAP daemon
zap-cli start --start-options '-config api.key=myapikey'

# Open URL
zap-cli open-url http://localhost:3000

# Spider (crawl)
zap-cli spider http://localhost:3000

# Active scan
zap-cli active-scan http://localhost:3000

# Get alerts
zap-cli alerts --alert-level Medium

# Report
zap-cli report -o report.html -f html

# Shutdown
zap-cli shutdown
```

## Common Alerts

| Alert | Risk | OWASP | Description |
|-------|------|-------|-------------|
| SQL Injection | 🔴 High | A03 | SQL injection detected |
| XSS (Reflected) | 🔴 High | A03 | Reflected cross-site scripting |
| XSS (Stored) | 🔴 High | A03 | Stored cross-site scripting |
| CSRF | 🟠 Medium | A01 | Missing CSRF protection |
| Missing Security Headers | 🟡 Low | A05 | CSP, X-Frame-Options missing |
| Cookie Without Flags | 🟡 Low | A05 | Missing Secure/HttpOnly flags |
| Directory Listing | 🟡 Medium | A01 | Server directory listing enabled |
| Information Disclosure | 🟡 Low | A05 | Server version, stack traces |

## CI/CD Integration
```yaml
# GitHub Actions
- name: OWASP ZAP Scan
  uses: zaproxy/action-baseline@v0.12.0
  with:
    target: 'http://localhost:3000'
    rules_file_name: 'zap-rules.tsv'
    fail_action: true
```

## Best Practices
- Start with baseline (passive) scan — it's fast and catches common issues
- Use full scan for pre-release security audits
- Configure authentication to test authenticated pages
- Use API scan for REST/GraphQL endpoints
- Exclude third-party URLs (CDNs, analytics) from scanning
- Review false positives and create exclusion rules
- Run in Docker for consistent environment
