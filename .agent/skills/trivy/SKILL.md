---
name: Trivy
description: Skill for container and infrastructure vulnerability scanning with Trivy and Docker Scout, covering image scanning, filesystem scanning, IaC scanning, and CI integration.
---

# Trivy & Docker Scout Skill

## Overview
Trivy (by Aqua Security) is a comprehensive scanner for vulnerabilities in containers, filesystems, IaC, and Git repos. Docker Scout provides similar scanning integrated into Docker Desktop.

---

## Trivy

### Installation
```bash
# Docker
docker pull aquasec/trivy

# macOS
brew install trivy

# Windows (scoop)
scoop install trivy

# Linux
sudo apt install trivy
```

### Container Image Scanning
```bash
# Scan Docker image
trivy image myapp:latest

# Scan with severity filter
trivy image --severity HIGH,CRITICAL myapp:latest

# Scan specific image from registry
trivy image node:18-alpine

# JSON output
trivy image --format json -o trivy-report.json myapp:latest

# Table output with fix info
trivy image --format table myapp:latest

# HTML report
trivy image --format template --template "@html.tpl" -o report.html myapp:latest

# Ignore unfixed
trivy image --ignore-unfixed myapp:latest

# Exit code on findings (for CI/CD)
trivy image --exit-code 1 --severity CRITICAL myapp:latest
```

### Filesystem Scanning
```bash
# Scan project directory
trivy fs .

# Specific path
trivy fs --severity HIGH,CRITICAL ./src

# Lock files only
trivy fs --scanners vuln .
```

### IaC Scanning
```bash
# Scan Terraform
trivy config ./terraform

# Scan Kubernetes manifests
trivy config ./k8s

# Scan Dockerfile
trivy config Dockerfile

# Scan docker-compose
trivy config docker-compose.yml
```

### Git Repository Scanning
```bash
# Scan for secrets
trivy repo --scanners secret .

# Full repo scan
trivy repo https://github.com/user/repo
```

### Configuration — `trivy.yaml`
```yaml
severity:
  - HIGH
  - CRITICAL
ignore-unfixed: true
exit-code: 1
format: json
output: trivy-results.json
timeout: 10m
```

### CI/CD Integration
```yaml
# GitHub Actions
- name: Trivy Scan
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'myapp:latest'
    format: 'sarif'
    output: 'trivy-results.sarif'
    severity: 'CRITICAL,HIGH'
    exit-code: '1'
```

---

## Docker Scout

### Usage (Requires Docker Desktop 4.17+)
```bash
# Analyze image
docker scout cves myapp:latest

# Quick overview
docker scout quickview myapp:latest

# Recommendations
docker scout recommendations myapp:latest

# Compare images
docker scout compare --to myapp:v1 myapp:v2

# SBOM (Software Bill of Materials)
docker scout sbom myapp:latest

# JSON output
docker scout cves --format sarif myapp:latest > scout-report.sarif
```

### Policy Compliance
```bash
# Check against policies
docker scout policy myapp:latest

# Specific policy
docker scout policy --org myorg myapp:latest
```

## Severity Levels

| Level | Action | SLA |
|-------|--------|-----|
| CRITICAL | Fix immediately | 24 hours |
| HIGH | Fix before deployment | 7 days |
| MEDIUM | Plan fix | 30 days |
| LOW | Track | Next release |
| UNKNOWN | Investigate | Assess |

## Best Practices
- Scan images in CI/CD before pushing to registry
- Use `--exit-code 1` to fail builds on CRITICAL/HIGH
- Scan base images separately — choose minimal base images
- Enable secret scanning to catch leaked credentials
- Scan IaC configs alongside application code
- Use `.trivyignore` for accepted risks (with documented justification)
- Keep Trivy DB updated: `trivy image --download-db-only`
