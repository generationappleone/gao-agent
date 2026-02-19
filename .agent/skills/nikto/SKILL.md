---
name: Nikto
description: Skill for web server vulnerability scanning with Nikto, covering configuration, scan types, authentication, output formats, and integration with security workflows.
---

# Nikto Skill

## Overview
Nikto is an open-source web server scanner testing for dangerous files, outdated server software, server configuration issues, and other security problems.

## Installation
```bash
# Perl-based (requires Perl)
git clone https://github.com/sullo/nikto.git
cd nikto/program && perl nikto.pl -h http://localhost

# Docker
docker pull secfigo/nikto
docker run --rm secfigo/nikto -h http://host.docker.internal:3000

# Kali Linux (pre-installed)
nikto -h http://localhost:3000
```

## Core Scans

### Basic Scan
```bash
nikto -h http://localhost:3000

# With specific port
nikto -h localhost -p 3000

# HTTPS
nikto -h https://localhost:443

# Multiple ports
nikto -h localhost -p 80,443,8080
```

### Output Formats
```bash
# HTML report
nikto -h http://localhost:3000 -o report.html -Format html

# JSON report
nikto -h http://localhost:3000 -o report.json -Format json

# CSV report
nikto -h http://localhost:3000 -o report.csv -Format csv

# XML (for integration)
nikto -h http://localhost:3000 -o report.xml -Format xml
```

### Authentication
```bash
# Basic auth
nikto -h http://localhost:3000 -id admin:password

# Cookie-based auth
nikto -h http://localhost:3000 -C "session=abc123; token=xyz789"
```

### Tuning (Scan Types)
```bash
# Specific test categories
nikto -h http://localhost:3000 -Tuning 1234

# Tuning options:
# 1 - Interesting File / Seen in logs
# 2 - Misconfiguration / Default File
# 3 - Information Disclosure
# 4 - Injection (XSS/Script/HTML)
# 5 - Remote File Retrieval (inside web root)
# 6 - Denial of Service
# 7 - Remote File Retrieval (server wide)
# 8 - Command Execution / Remote Shell
# 9 - SQL Injection
# 0 - File Upload
# a - Authentication Bypass
# b - Software Identification
# c - Remote source inclusion
```

### Advanced Options
```bash
# Evade IDS/WAF
nikto -h http://localhost:3000 -evasion 1

# Use proxy
nikto -h http://localhost:3000 -useproxy http://proxy:8080

# Timeout
nikto -h http://localhost:3000 -timeout 10

# Max scan time
nikto -h http://localhost:3000 -maxtime 300

# Specific plugins
nikto -h http://localhost:3000 -Plugins "apache;outdated"
```

## Common Findings

| Finding | Risk | Action |
|---------|------|--------|
| Server version disclosed | 🟡 Low | Hide `Server` header |
| Directory listing enabled | 🟠 Medium | Disable `Options -Indexes` |
| Default files present | 🟡 Low | Remove default/sample files |
| Outdated software | 🟠 Medium | Update server software |
| Missing security headers | 🟡 Low | Add CSP, X-Frame-Options |
| Backup files accessible | 🔴 High | Remove `.bak`, `.old` files |
| phpinfo() accessible | 🟠 Medium | Remove info pages |
| Admin panel exposed | 🟠 Medium | Restrict access via IP/auth |

## Best Practices
- Run against development/staging only (not production without permission)
- Use `-Tuning` to focus scans (avoid unnecessary noise)
- Combine with OWASP ZAP for deeper analysis
- Schedule periodic scans (weekly/monthly)
- Save reports in JSON for automated processing
