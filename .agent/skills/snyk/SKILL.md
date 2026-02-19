---
name: Snyk
description: Skill for vulnerability scanning with Snyk CLI and Snyk Cloud, covering dependency scanning, container scanning, IaC scanning, and license compliance.
---

# Snyk Skill

## Overview
Snyk is a developer-first security platform that finds and fixes vulnerabilities in dependencies, containers, IaC, and code. Free tier available for open source.

## Installation
```bash
# CLI
npm install -D snyk
# or globally
npm install -g snyk

# Authenticate (free account at snyk.io)
npx snyk auth
# or with token
SNYK_TOKEN=your-token npx snyk test
```

## Dependency Scanning

### Test for Vulnerabilities
```bash
# Node.js
npx snyk test

# Python
npx snyk test --file=requirements.txt

# PHP
npx snyk test --file=composer.lock

# Go
npx snyk test --file=go.mod

# With severity filter
npx snyk test --severity-threshold=high

# JSON output
npx snyk test --json > snyk-report.json

# SARIF output (for GitHub Security)
npx snyk test --sarif > snyk.sarif
```

### Monitor (Continuous Scanning)
```bash
npx snyk monitor                  # register project for monitoring
npx snyk monitor --org=your-org   # with organization
```

### Fix Vulnerabilities
```bash
npx snyk fix                      # auto-fix (upgrade packages)
npx snyk wizard                   # interactive fix wizard
```

## Container Scanning
```bash
# Scan Docker image
npx snyk container test node:18-alpine
npx snyk container test myapp:latest --file=Dockerfile

# Monitor container
npx snyk container monitor myapp:latest
```

## Infrastructure as Code (IaC) Scanning
```bash
# Scan Terraform
npx snyk iac test terraform/

# Scan Kubernetes manifests
npx snyk iac test k8s/

# Scan Docker Compose
npx snyk iac test docker-compose.yml
```

## Code Scanning (SAST)
```bash
npx snyk code test              # scan source code
npx snyk code test --json       # JSON output
npx snyk code test --severity-threshold=high
```

## CI/CD Integration
```yaml
# GitHub Actions
- name: Snyk Security Scan
  uses: snyk/actions/node@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    args: --severity-threshold=high --fail-on=all
```

## Policy File — `.snyk`
```yaml
version: v1.25.0
ignore:
  SNYK-JS-LODASH-590103:
    - '*':
        reason: 'Low risk, no user input reaches this code path'
        expires: 2026-06-01T00:00:00.000Z
patch: {}
```

## CLI Commands Reference
```bash
npx snyk test              # test dependencies
npx snyk monitor           # monitor for new vulns
npx snyk fix               # auto-fix
npx snyk code test         # SAST scan
npx snyk container test    # container scan
npx snyk iac test          # IaC scan
npx snyk log4shell         # check Log4Shell
npx snyk ignore --id=VULN-ID --reason="explanation"  # ignore specific vuln
```

## Best Practices
- Run `snyk test` in CI/CD — fail pipeline on high/critical vulnerabilities
- Use `snyk monitor` to get alerts for new vulnerabilities
- Review and update `.snyk` ignore policies quarterly
- Use `--severity-threshold=high` to avoid noise from low-severity issues
- Combine with `npm audit` for comprehensive coverage
- Set SNYK_TOKEN as environment variable, never hardcode
