---
name: Nmap
description: Skill for network scanning and security auditing with Nmap, covering port scanning, service detection, vulnerability scripts, SSL auditing, and output formats.
---

# Nmap Skill

## Overview
Nmap (Network Mapper) is the industry-standard tool for network discovery, port scanning, service/version detection, and security auditing via NSE scripts.

## Installation
```bash
# Windows: Download from https://nmap.org/download
# macOS
brew install nmap
# Linux
sudo apt install nmap
```

## Core Scan Types

### Port Scanning
```bash
# Quick scan (top 100 ports)
nmap -F localhost

# Full port scan
nmap -p- localhost

# Specific ports
nmap -p 80,443,3000,5432,6379 localhost

# Port range
nmap -p 1-1024 localhost

# Service version detection
nmap -sV localhost

# OS detection
nmap -O localhost

# Comprehensive scan
nmap -A localhost   # OS + version + scripts + traceroute
```

### Scan Techniques
```bash
nmap -sT localhost   # TCP connect scan (default)
nmap -sS localhost   # SYN stealth scan (requires root)
nmap -sU localhost   # UDP scan
nmap -sn 192.168.1.0/24   # Ping sweep (host discovery)
```

## NSE Scripts (Vulnerability Detection)

### SSL/TLS Audit
```bash
# Check SSL ciphers
nmap --script ssl-enum-ciphers -p 443 localhost

# Check for Heartbleed
nmap --script ssl-heartbleed -p 443 localhost

# Full SSL audit
nmap --script "ssl-*" -p 443 localhost

# Check certificate
nmap --script ssl-cert -p 443 localhost
```

### Web Application Scripts
```bash
# HTTP headers
nmap --script http-headers -p 80,443 localhost

# HTTP methods
nmap --script http-methods -p 80 localhost

# Detect WAF
nmap --script http-waf-detect -p 80 localhost

# Find directories
nmap --script http-enum -p 80 localhost

# SQL injection detection
nmap --script http-sql-injection -p 80 localhost

# XSS detection
nmap --script http-stored-xss -p 80 localhost
```

### Database Scripts
```bash
# MySQL
nmap --script mysql-info,mysql-enum -p 3306 localhost

# PostgreSQL
nmap --script pgsql-brute -p 5432 localhost

# MongoDB
nmap --script mongodb-info -p 27017 localhost

# Redis
nmap --script redis-info -p 6379 localhost
```

### Vulnerability Scanning
```bash
# Run all vuln scripts
nmap --script vuln localhost

# Specific vulnerability category
nmap --script "vuln and safe" localhost
```

## Output Formats
```bash
nmap -oN scan.txt localhost      # Normal text
nmap -oX scan.xml localhost      # XML (for tools)
nmap -oG scan.gnmap localhost    # Grepable
nmap -oJ scan.json localhost     # JSON (newer versions)
nmap -oA scan-all localhost      # All formats at once
```

## Common Security Checks

| Check | Command | Purpose |
|-------|---------|---------|
| Open ports | `nmap -F host` | Find exposed services |
| SSL strength | `nmap --script ssl-enum-ciphers -p 443 host` | Verify strong ciphers |
| Default creds | `nmap --script *-brute -p PORT host` | Check default passwords |
| Info disclosure | `nmap --script http-headers -p 80 host` | Check leaked info |
| Exposed databases | `nmap -p 3306,5432,27017,6379 host` | DB ports open? |

## Best Practices
- Always have written authorization before scanning
- Use `-T3` (normal timing) — `-T5` may crash services
- Start with `-F` (fast) then `-p-` (full) if needed
- Save results with `-oA` for all formats
- Use `--script safe` to avoid disruptive scripts
- Never scan production without permission
