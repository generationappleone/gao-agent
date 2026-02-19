---
name: Burp Suite
description: Skill for web application security testing with Burp Suite, covering proxy setup, scanner configuration, intruder attacks, and integration with other tools.
---

# Burp Suite Skill

## Overview
Burp Suite is a leading web security testing platform (by PortSwigger) that intercepts, inspects, and modifies HTTP traffic between browser and server. Community Edition is free; Pro adds automated scanning.

## Installation
- **Community Edition (Free):** https://portswigger.net/burp/communitydownload
- **Professional (Paid):** https://portswigger.net/burp/pro
- Requires Java Runtime Environment (JRE)

## Setup

### Browser Proxy Configuration
```
Proxy Address: 127.0.0.1
Proxy Port:    8080
```

Configure browser to use Burp as proxy:
- Firefox: Settings → Network Settings → Manual Proxy → 127.0.0.1:8080
- Chrome: Use FoxyProxy or SwitchyOmega extension

### Install CA Certificate
1. Visit `http://burpsuite` in proxied browser
2. Download CA certificate
3. Import into browser trusted certificates
4. Required for HTTPS interception

## Key Tools

### Proxy (Intercept & Modify)
- Intercept requests before they reach the server
- Modify parameters, headers, cookies on the fly
- Forward, drop, or send to other tools
- HTTP history shows all traffic

### Scanner (Pro Only)
- Automated vulnerability scanning
- Passive + Active scanning modes
- Crawl & audit workflow
- Scan configurations for speed vs thoroughness

### Intruder (Automated Attacks)
Attack types:
- **Sniper:** One payload position, iterate one at a time
- **Battering Ram:** Same payload in all positions
- **Pitchfork:** Different payload in each position (parallel)
- **Cluster Bomb:** All combinations (cartesian product)

Common uses:
- Brute force login
- Parameter fuzzing
- IDOR testing (incrementing IDs)
- Token harvesting

### Repeater (Manual Testing)
- Send individual requests manually
- Modify and resend
- Compare responses
- Test edge cases

### Sequencer (Token Analysis)
- Analyze randomness of session tokens
- Check for predictable tokens/cookies
- Statistical analysis of entropy

### Decoder
- Encode/decode: Base64, URL, HTML, hex, etc.
- Hash: MD5, SHA1, SHA256, etc.
- Smart decode (auto-detect encoding)

## Integration with Agent Workflow

Since Burp Suite is GUI-based, the agent CANNOT run it directly. Instead:

### Option 1: Use Burp REST API (Pro)
```bash
# Start API
java -jar burp.jar --project-file=project.burp --unpause-spider-and-scanner

# Scan via API
curl -X POST http://localhost:1337/v0.1/scan \
  -d '{"urls":["http://localhost:3000"]}'
```

### Option 2: Use Headless Burp (Pro)
```bash
java -jar burp.jar --project-file=project.burp \
  --config-file=burp-config.json \
  --unpause-spider-and-scanner
```

### Option 3: Export Results from Manual Session
After manual testing, export:
- Issues → XML/HTML report
- HTTP traffic → HAR file
- Import into agent documentation

## Alternative for CI/CD
For automated pipelines, use OWASP ZAP instead (free, CLI-native).
Burp is best for manual exploratory security testing.

## Common Findings
| Finding | Risk | Tool |
|---------|------|------|
| SQL Injection | 🔴 Critical | Scanner/Intruder |
| XSS | 🔴 High | Scanner/Repeater |
| CSRF | 🟠 Medium | Scanner |
| Broken Auth | 🔴 High | Intruder/Repeater |
| IDOR | 🔴 High | Intruder |
| Info Disclosure | 🟡 Low | Proxy/Scanner |
| Missing Headers | 🟡 Low | Proxy |

## Best Practices
- Always use Burp's browser or properly configure proxy
- Save Burp project file for audit documentation
- Use scope settings to limit testing to target only
- Record all manual findings in Burp's issue tracker
- Export reports for documentation
- Community Edition is useful for manual testing; Pro for automated scanning
