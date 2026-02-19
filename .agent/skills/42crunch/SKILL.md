---
name: 42Crunch
description: Skill for 42Crunch — API lifecycle security with OpenAPI audit, conformance scanning, runtime protection, and CI/CD integration.
---

# 42Crunch — API Lifecycle Security

## Overview
42Crunch provides end-to-end API security including design-time audit (OpenAPI spec analysis), conformance scanning (API vs spec), and runtime protection (API firewall).

## Key Capabilities
- **API Audit**: Score OpenAPI specs for security issues (0-100 scale)
- **API Scan**: DAST testing comparing API behavior vs spec
- **API Protect**: Runtime API firewall enforcement
- **CI/CD Integration**: GitHub Actions, Jenkins, Azure DevOps

## Usage
```yaml
# GitHub Actions integration
- name: 42Crunch API Security Audit
  uses: 42Crunch/api-security-audit-action@v3
  with:
    api-token: ${{ secrets.CRUNCH_TOKEN }}
    min-score: 70
```

## Best Practices
- Audit OpenAPI specs **before development** starts
- Run **conformance scans** in staging environments
- Deploy **API Protect** in production as API firewall
