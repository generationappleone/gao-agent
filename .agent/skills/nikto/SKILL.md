---
name: Nikto
description: Skill for web server vulnerability scanning with Nikto, covering configuration, scan types, authentication, output formats, and integration with security workflows.
---

# Nikto Skill

## Overview
Nikto is an open-source web server scanner that tests for dangerous files, outdated server software, version-specific problems, and server configuration issues. It checks over 6,700 potentially dangerous files/programs and 1,250 outdated server versions.

**References**:
- [Nikto GitHub](https://github.com/sullo/nikto)
- [Nikto Documentation](https://cirt.net/Nikto2)

---

## Installation

```bash
# Kali Linux (pre-installed)
nikto -Version

# Ubuntu/Debian
sudo apt install nikto

# From source
git clone https://github.com/sullo/nikto.git
cd nikto/program
perl nikto.pl -Version

# Docker
docker run --rm -it secfigo/nikto -h <target>
```

---

## Basic Scanning

```bash
# ── Basic scan ──
nikto -h https://myapp.com

# ── Scan specific port ──
nikto -h https://myapp.com -p 8443

# ── Scan multiple ports ──
nikto -h myapp.com -p 80,443,8080,8443

# ── Scan with SSL ──
nikto -h myapp.com -ssl

# ── Scan specific path ──
nikto -h https://myapp.com -root /api

# ── Follow redirects ──
nikto -h https://myapp.com -followredirects

# ── Scan from file (multiple targets) ──
nikto -h targets.txt
```

---

## Tuning Options

```bash
# ── Scan tuning (select specific test types) ──
# 0 - File Upload
# 1 - Interesting File / Logs
# 2 - Misconfiguration / Default
# 3 - Information Disclosure
# 4 - Injection (XSS/Script/HTML)
# 5 - Remote File Retrieval - Inside Web Root
# 6 - Denial of Service
# 7 - Remote File Retrieval - Server Wide
# 8 - Command Execution / Remote Shell
# 9 - SQL Injection
# a - Authentication Bypass
# b - Software Identification
# c - Remote Source Inclusion
# x - Reverse Tuning (exclude these tests)

# Only XSS and SQL Injection tests
nikto -h https://myapp.com -Tuning 49

# Exclude DoS tests
nikto -h https://myapp.com -Tuning x6

# File upload and injection tests
nikto -h https://myapp.com -Tuning 04

# Information disclosure and misconfiguration
nikto -h https://myapp.com -Tuning 23
```

---

## Authentication

```bash
# ── Basic authentication ──
nikto -h https://myapp.com -id admin:password123

# ── Cookie-based auth ──
nikto -h https://myapp.com -c "session_id=abc123; token=xyz789"

# ── Custom headers ──
nikto -h https://myapp.com -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..."
nikto -h https://myapp.com -H "X-API-Key: my-api-key-123"
```

---

## Output Formats

```bash
# ── Save results ──
# HTML report
nikto -h https://myapp.com -o report.html -Format htm

# CSV
nikto -h https://myapp.com -o report.csv -Format csv

# JSON
nikto -h https://myapp.com -o report.json -Format json

# XML
nikto -h https://myapp.com -o report.xml -Format xml

# Text
nikto -h https://myapp.com -o report.txt -Format txt

# Multiple formats
nikto -h https://myapp.com -o report.html -Format htm -o report.json -Format json
```

---

## Advanced Options

```bash
# ── Evasion techniques (IDS evasion) ──
# 1 - Random URI encoding
# 2 - Directory self-reference (/./
# 3 - Premature URL ending
# 4 - Prepend long random string
# 5 - Fake parameter
# 6 - TAB as request spacer
# 7 - Change the case of the URL
# 8 - Use Windows directory separator (\)
# A - Use a carriage return (0x0d)
# B - Use binary value 0x0b
nikto -h https://myapp.com -evasion 1

# ── Proxy ──
nikto -h https://myapp.com -useproxy http://proxy:8080

# ── Timeout ──
nikto -h https://myapp.com -timeout 10

# ── Max time (seconds) ──
nikto -h https://myapp.com -maxtime 300

# ── Pause between requests (seconds) ──
nikto -h https://myapp.com -Pause 2

# ── Custom User-Agent ──
nikto -h https://myapp.com -useragent "Mozilla/5.0 (compatible; SecurityScan)"

# ── Update database ──
nikto -update

# ── Display options ──
# 1 - Show redirects
# 2 - Show cookies received
# 3 - Show all 200/OK responses
# 4 - Show URLs requiring authentication
# D - Debug output
# V - Verbose output
nikto -h https://myapp.com -Display 1234V
```

---

## CI/CD Integration

```yaml
# .github/workflows/nikto-scan.yml
name: Nikto Security Scan
on:
  schedule:
    - cron: '0 3 * * 1'  # Weekly Monday 3AM
  workflow_dispatch:

jobs:
  nikto:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Nikto Scan
        run: |
          docker run --rm \
            -v ${{ github.workspace }}/reports:/reports \
            secfigo/nikto \
            -h ${{ vars.STAGING_URL }} \
            -o /reports/nikto-report.html \
            -Format htm \
            -Tuning 1234ab \
            -maxtime 600 \
            -nointeractive

      - name: Upload Report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: nikto-report
          path: reports/nikto-report.html

      - name: Check for Critical Findings
        run: |
          if grep -q "OSVDB-" reports/nikto-report.html; then
            echo "⚠️ Nikto found potential vulnerabilities"
          fi
```

---

## Common Findings & Remediations

| Finding | Risk | Remediation |
|---------|------|-------------|
| **Server version exposed** | Info disclosure | `server_tokens off;` (Nginx) |
| **X-Frame-Options missing** | Clickjacking | Add `X-Frame-Options: DENY` header |
| **HSTS not set** | Downgrade attack | Add `Strict-Transport-Security` header |
| **Directory listing** | Info disclosure | `autoindex off;` (Nginx) |
| **Default files found** | Attack surface | Remove default/sample files |
| **Outdated software** | Known CVEs | Update server software |
| **HTTP TRACE enabled** | XST attack | Disable TRACE method |
| **Cookie without HttpOnly** | XSS risk | Set `HttpOnly` flag on cookies |
| **X-Content-Type missing** | MIME sniffing | Add `X-Content-Type-Options: nosniff` |

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Staging only** | Never scan production without authorization |
| **Tuning** | Select relevant test categories to reduce noise |
| **Rate limiting** | Use `-Pause` to avoid overwhelming target |
| **Authentication** | Test authenticated areas with cookies/tokens |
| **Regular scans** | Weekly/monthly scheduled scans |
| **Combine tools** | Use with Nmap, OWASP ZAP for comprehensive coverage |
| **Update DB** | Run `nikto -update` before scanning |
| **Time limits** | Set `-maxtime` to prevent indefinite scans |
| **Report format** | HTML for humans, JSON/XML for automation |
| **Fix tracking** | Track findings and remediation in issue tracker |

---

## Rules Integration
- **Scanning**: Web server misconfiguration, outdated software, dangerous files
- **Tuning**: Select specific test categories (XSS, SQLi, info disclosure)
- **Authentication**: Basic auth, cookies, custom headers (Bearer, API key)
- **Output**: HTML/JSON/CSV/XML reports for documentation
- **CI/CD**: Docker-based scanning in GitHub Actions
