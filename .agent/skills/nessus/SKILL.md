---
name: Nessus Professional
description: Skill for Nessus Professional (Tenable) — vulnerability scanner with plugin-based detection, compliance auditing, and API automation.
---

# Nessus Professional — Vulnerability Scanner

## Overview
Nessus by Tenable is the industry-standard vulnerability scanner with 200,000+ plugins for discovering vulnerabilities, misconfigurations, and compliance violations.

## API (Tenable.io / Nessus)
```python
from tenable.io import TenableIO

tio = TenableIO('ACCESS_KEY', 'SECRET_KEY')

# List scans
scans = tio.scans.list()

# Launch a scan
scan = tio.scans.create(
    name="Weekly Vulnerability Scan",
    targets=["192.168.1.0/24"],
    template="basic"
)
tio.scans.launch(scan['id'])

# Get vulnerabilities
vulns = tio.exports.vulns(severity=['critical', 'high'])
for vuln in vulns:
    print(f"{vuln['asset']['hostname']}: {vuln['plugin']['name']} (CVSS: {vuln['plugin']['cvss_base_score']})")
```

### Key API Endpoints
| Endpoint | Description |
|----------|-------------|
| `/scans` | Manage vulnerability scans |
| `/assets` | Asset inventory |
| `/workbenches/vulnerabilities` | Vulnerability results |
| `/plugins` | Plugin information |
| `/compliance` | Compliance check results |

## Best Practices
- Schedule **credentialed scans** for deeper visibility
- Use **audit files** for CIS benchmark compliance
- Configure **exclusion lists** for fragile systems
- Enable **live results** for continuous monitoring
