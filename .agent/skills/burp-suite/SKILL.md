---
name: Burp Suite
description: Skill for web application security testing with Burp Suite, covering proxy setup, scanner configuration, intruder attacks, and integration with other tools.
---

# Burp Suite Skill

## Overview
Burp Suite is the industry-standard web application security testing toolkit. It provides an intercepting proxy, automated scanner, intruder (attack engine), repeater, sequencer, and extensibility via BApps. Available in Community (free) and Professional editions.

**References**:
- [Burp Suite Documentation](https://portswigger.net/burp/documentation)
- [Burp Suite Academy](https://portswigger.net/web-security)
- [BApp Store](https://portswigger.net/bappstore)

---

## Proxy Setup

### Browser Configuration
```
# Manual proxy settings
HTTP Proxy:  127.0.0.1
Port:        8080
HTTPS Proxy: 127.0.0.1
Port:        8080

# Install Burp CA certificate for HTTPS interception:
# 1. With proxy running, browse to http://burp
# 2. Click "CA Certificate" to download
# 3. Import into browser's certificate store (Trusted Root)
```

### Scope Configuration
```
# Target Scope — Include:
# Protocol: Any
# Host/IP: myapp.com
# Port: Any
# File: ^/api/.*

# Target Scope — Exclude:
# Host: *.google.com, *.googleapis.com, *.gstatic.com
# Host: *.facebook.com, *.doubleclick.net
# File: \.(css|js|png|jpg|gif|svg|ico|woff|woff2)$

# Suite-wide settings:
# - Only show items in scope in Proxy history
# - Don't intercept out-of-scope requests
```

---

## Testing Workflow

### 1. Manual Crawl (Discovery)
```
# Steps:
1. Set browser proxy to Burp (127.0.0.1:8080)
2. Browse the entire application manually:
   - Login/register flows
   - All pages and features
   - Form submissions
   - File uploads
   - API endpoints
3. Review Target > Site map for discovered endpoints
4. Check Proxy > HTTP history for all requests
```

### 2. Active Scanning (Automated)
```
# Burp Scanner (Professional):
1. Right-click target in site map → "Actively scan this host"
2. Or select specific requests → "Scan selected items"

# Scanner Configuration:
# - Scan type: Crawl and Audit
# - Crawl: Fast / Normal / Thorough
# - Audit: Light / Normal / Thorough
# - Handle login: Configure session handling rules
# - Avoid: Logout URLs, destructive actions

# Key vulnerabilities detected:
# - SQL injection
# - Cross-site scripting (XSS)
# - OS command injection
# - Path traversal
# - XML/XXE injection
# - Server-side request forgery (SSRF)
# - Authentication issues
# - Information disclosure
```

---

## Intruder (Attack Engine)

### Brute Force Login
```
# Attack type: Cluster bomb
# Target: POST /api/auth/login

# Position markers:
POST /api/auth/login HTTP/2
Host: myapp.com
Content-Type: application/json

{"email":"§admin@myapp.com§","password":"§password123§"}

# Payload Set 1 (emails):
admin@myapp.com
user@myapp.com
test@myapp.com

# Payload Set 2 (passwords):
password123
admin123
letmein
qwerty
123456

# Grep - Match: "token" (success indicator)
# Grep - Extract: response body
# Options: Follow redirects, max 5 concurrent
```

### Parameter Fuzzing
```
# Attack type: Sniper
# Target: GET /api/users/§1§

# Payload: Numbers 1-1000
# Or: Payload list from SecLists

# Use for:
# - IDOR testing (change user/resource IDs)
# - Parameter brute-forcing
# - Directory/file enumeration
```

### IDOR Testing
```
# Steps:
1. Login as User A, capture requests with resource IDs
2. Send to Repeater
3. Change resource IDs to User B's resources
4. Check if unauthorized access is granted

# Example:
# Original: GET /api/orders/order_abc123 (User A's order)
# Modified: GET /api/orders/order_def456 (User B's order)
# If 200 OK → IDOR vulnerability found
```

---

## Repeater (Manual Testing)

```
# Use Repeater to manually modify and replay requests

# ── SQL Injection testing ──
# Original:
GET /api/users?id=1 HTTP/2

# Test payloads:
GET /api/users?id=1' HTTP/2
GET /api/users?id=1 OR 1=1 HTTP/2
GET /api/users?id=1' UNION SELECT null,null,null-- HTTP/2
GET /api/users?id=1; DROP TABLE users-- HTTP/2

# ── XSS testing ──
POST /api/comments HTTP/2
Content-Type: application/json

{"content":"<script>alert('XSS')</script>"}
{"content":"<img src=x onerror=alert('XSS')>"}

# ── Auth bypass testing ──
# Remove Authorization header
# Change JWT payload (role: admin)
# Try expired tokens
# Test with other users' tokens
```

---

## Useful Extensions (BApps)

| Extension | Purpose |
|-----------|---------|
| **Logger++** | Enhanced request/response logging with search |
| **Autorize** | Automatic authorization/IDOR testing |
| **Active Scan++** | Enhanced active scanning checks |
| **Param Miner** | Discover hidden parameters |
| **JWT Editor** | Decode, edit, and test JWT tokens |
| **Turbo Intruder** | High-speed intruder replacement (Python-scriptable) |
| **Collaborator Everywhere** | Inject Collaborator payloads for SSRF/blind testing |
| **Software Vulnerability Scanner** | Detect known CVEs in libraries |
| **Hackvertor** | Tag-based encoding/decoding converter |
| **Upload Scanner** | Test file upload vulnerabilities |

---

## Session Handling

```
# Configure session handling rules for authenticated scanning:

# Project Options > Sessions > Session Handling Rules:

# Rule 1: Login macro
# Scope: Target scope
# Actions:
#   1. Check session is valid (GET /api/me → 200)
#   2. If invalid, run login macro:
#      - POST /api/auth/login with valid credentials
#      - Extract token from response
#      - Update Authorization header for subsequent requests

# Rule 2: Cookie jar
# Automatically update cookies from Set-Cookie headers
```

---

## Reporting

```
# Generate report (Professional):
# 1. Target > Site map > Right-click target
# 2. "Generate report"
# 3. Select issues to include
# 4. Format: HTML or XML

# Report includes:
# - Executive summary
# - Issue detail (description, evidence, remediation)
# - Severity classification (High, Medium, Low, Info)
# - Request/response evidence
# - Remediation advice
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Scope first** | Define target scope before testing |
| **Manual first** | Crawl manually before automated scanning |
| **Session handling** | Configure login macros for authenticated scanning |
| **Avoid destructive** | Exclude logout/delete endpoints from scanning |
| **IDOR testing** | Use Autorize extension for systematic testing |
| **JWT testing** | Use JWT Editor to manipulate tokens |
| **Rate limiting** | Throttle Intruder/Scanner to avoid blocking |
| **Collaborator** | Use Burp Collaborator for blind SSRF/XXE/SQLi |
| **Report findings** | Generate HTML reports with evidence |
| **Legal authorization** | Always have written permission before testing |

---

## Rules Integration
- **Proxy**: Intercept and modify HTTP/HTTPS traffic
- **Scanner**: Automated vulnerability detection (SQLi, XSS, SSRF)
- **Intruder**: Brute force, fuzzing, IDOR testing
- **Repeater**: Manual request modification and replay
- **Extensions**: Autorize, JWT Editor, Param Miner, Logger++
