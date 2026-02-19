---
name: SonarQube & SonarCloud
description: Skill for continuous code quality and security analysis with SonarQube (self-hosted) and SonarCloud (SaaS), covering setup, quality gates, custom rules, and CI integration.
---

# SonarQube & SonarCloud Skill

## Overview
SonarQube/SonarCloud performs continuous inspection of code quality — detecting bugs, vulnerabilities, code smells, and tracking technical debt. SonarCloud is the SaaS version (free for open source).

## Installation

### SonarQube (Self-hosted via Docker)
```bash
docker run -d --name sonarqube \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  -p 9000:9000 \
  sonarqube:community

# Default login: admin / admin
```

### SonarQube Scanner CLI
```bash
npm install -D sonarqube-scanner
# or download: https://docs.sonarqube.org/latest/analyzing-source-code/scanners/sonarscanner/
```

### SonarCloud (SaaS)
1. Sign up at https://sonarcloud.io (free for open source)
2. Connect GitHub/GitLab/Bitbucket
3. Generate token in My Account → Security

## Configuration — `sonar-project.properties`
```properties
sonar.projectKey=my-project
sonar.projectName=My Project
sonar.projectVersion=1.0.0

# Sources
sonar.sources=src
sonar.tests=tests
sonar.test.inclusions=**/*.test.ts,**/*.spec.ts

# Language-specific
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.typescript.lcov.reportPaths=coverage/lcov.info

# Exclusions
sonar.exclusions=**/node_modules/**,**/dist/**,**/vendor/**,**/*.test.*

# Encoding
sonar.sourceEncoding=UTF-8

# SonarCloud specific
sonar.organization=my-org

# SonarQube specific
sonar.host.url=http://localhost:9000
sonar.token=squ_xxxxxxxxxxxxxxxxxxxx
```

## CLI Usage
```bash
# Run scanner
npx sonarqube-scanner

# With token (CI/CD)
npx sonarqube-scanner -Dsonar.token=YOUR_TOKEN

# SonarCloud
npx sonarqube-scanner \
  -Dsonar.host.url=https://sonarcloud.io \
  -Dsonar.organization=my-org \
  -Dsonar.token=YOUR_TOKEN

# Docker-based scanner
docker run --rm \
  -e SONAR_HOST_URL=http://host.docker.internal:9000 \
  -e SONAR_TOKEN=YOUR_TOKEN \
  -v "$(pwd):/usr/src" \
  sonarsource/sonar-scanner-cli
```

## Quality Gates

### Default Quality Gate
| Metric | Threshold | Meaning |
|--------|----------|---------|
| Coverage on new code | ≥ 80% | New code must be well-tested |
| Duplicated lines on new code | ≤ 3% | Avoid copy-paste |
| Maintainability rating | A | Low technical debt ratio |
| Reliability rating | A | No new bugs |
| Security rating | A | No new vulnerabilities |
| Security hotspots reviewed | 100% | All hotspots reviewed |

### Custom Quality Gate (Recommended)
```
New Code:
  - Coverage ≥ 80%
  - Duplicated Lines ≤ 3%
  - Maintainability Rating = A
  - Reliability Rating = A
  - Security Rating = A
  - Security Hotspots Reviewed = 100%

Overall Code:
  - Coverage ≥ 60%
  - Maintainability Rating ≥ B
  - Reliability Rating ≥ B
  - Security Rating ≥ A (strict for security)
```

## Issue Types

| Type | Description | Priority |
|------|-------------|----------|
| 🐛 Bug | Code that is wrong or will crash | Fix immediately |
| 🔓 Vulnerability | Security weakness in code | Fix immediately |
| 🔥 Security Hotspot | Needs manual review for security | Review & decide |
| 🧹 Code Smell | Maintainability issue | Plan fix |
| 📋 Technical Debt | Time to fix all code smells | Monitor trend |

## CI/CD Integration

### GitHub Actions
```yaml
- name: SonarCloud Scan
  uses: SonarSource/sonarcloud-github-action@master
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  with:
    args: >
      -Dsonar.organization=my-org
      -Dsonar.projectKey=my-project
```

### Quality Gate Check
```yaml
- name: SonarQube Quality Gate
  uses: sonarsource/sonarqube-quality-gate-action@master
  timeout-minutes: 5
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

## Best Practices
- Set Quality Gate as "failed" to block merges/deployments
- Focus on "new code" quality — don't try to fix everything at once
- Review Security Hotspots promptly — they need human judgment
- Use SonarLint in IDE for immediate feedback
- Track technical debt trend over time
- Exclude generated code, vendor, and node_modules
- Run scanner after tests so coverage data is available
