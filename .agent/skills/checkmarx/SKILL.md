---
name: Checkmarx
description: Skill for enterprise SAST with Checkmarx, covering scan configuration, severity levels, query customization, false positive management, and CI pipeline integration.
---

# Checkmarx Skill

## Overview
Checkmarx is an enterprise-grade SAST (Static Application Security Testing) platform that analyzes source code to find security vulnerabilities across 25+ programming languages. It requires a license.

## Installation
```bash
# Checkmarx CLI (CxFlow)
# Download from Checkmarx portal or use Docker
docker pull checkmarx/cx-flow

# CxCLI
# Download from: https://checkmarx.atlassian.net/wiki/spaces/SD/pages/
```

## CLI Usage

### CxFlow (Recommended CLI)
```bash
# Basic scan
java -jar cx-flow.jar \
  --scan \
  --cx-project="MyProject" \
  --app="MyApp" \
  --cx-team="/CxServer/MyTeam" \
  --f="./src" \
  --bug-tracker=Json \
  --output-file=cx-results.json

# With preset
java -jar cx-flow.jar \
  --scan \
  --cx-project="MyProject" \
  --preset="Checkmarx Default" \
  --f="./src"
```

### Docker
```bash
docker run --rm \
  -v "$(pwd):/app" \
  checkmarx/cx-flow \
  --scan \
  --cx-project="MyProject" \
  --f="/app/src" \
  --bug-tracker=Json
```

## Severity Levels

| Severity | SLA | Action |
|----------|-----|--------|
| Critical | 24 hours | Block deployment, fix immediately |
| High | 7 days | Block deployment, prioritize fix |
| Medium | 30 days | Plan remediation |
| Low | 90 days | Backlog / accept risk |
| Info | — | Review for awareness |

## Common Vulnerability Categories

| Category | CWE | Risk | Example |
|----------|-----|------|---------|
| SQL Injection | CWE-89 | 🔴 Critical | String concat in queries |
| XSS Reflected | CWE-79 | 🔴 High | Unescaped user input in HTML |
| XSS Stored | CWE-79 | 🔴 Critical | User input stored and rendered |
| Path Traversal | CWE-22 | 🟠 High | `../../etc/passwd` in file path |
| Command Injection | CWE-78 | 🔴 Critical | User input in exec/system calls |
| Hardcoded Password | CWE-798 | 🟠 High | Credentials in source code |
| Missing Auth | CWE-306 | 🔴 High | Endpoints without authentication |
| Insecure Deserialization | CWE-502 | 🔴 Critical | Untrusted data deserialization |

## CI/CD Integration

### GitHub Actions
```yaml
- name: Checkmarx SAST
  uses: checkmarx-ts/checkmarx-cxflow-github-action@v1.6
  with:
    project: MyProject
    team: /CxServer/MyTeam
    checkmarx_url: ${{ secrets.CX_SERVER }}
    checkmarx_username: ${{ secrets.CX_USER }}
    checkmarx_password: ${{ secrets.CX_PASS }}
    checkmarx_client_secret: ${{ secrets.CX_SECRET }}
    preset: 'Checkmarx Default'
    break_build: true
    scanners: sast
    bug_tracker: sarif
    params: --severity=High --confidence=High
```

## False Positive Management

### In Checkmarx Portal
1. Open finding → Mark as "Not Exploitable" with justification
2. Document the reason (required for audit)
3. False positives persist across scans

### In Code (Suppression)
```java
// @checkmarx-suppress CWE-89 — input is validated by @Valid annotation and parameterized via JPA
String result = userRepository.findByEmail(email);
```

## Best Practices
- Scan on every PR — catch issues before merge
- Use incremental scans for speed (scan only changed files)
- Start with High/Critical only — reduce noise
- Review and triage findings promptly
- Document all false positive suppressions
- Use Checkmarx presets appropriate for your tech stack
- Train developers to understand common vulnerability patterns
- Combine with DAST (OWASP ZAP) for complete coverage
