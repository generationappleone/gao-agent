---
name: Acunetix
description: Skill for Acunetix — web application vulnerability scanner with DAST, IAST, API scanning, and CI/CD integration.
---

# Acunetix — Web Vulnerability Scanner

## Overview
Acunetix is a web application vulnerability scanner providing DAST, IAST, and API scanning with automated crawling and zero false-positive guarantee for certain checks.

## API
```python
import requests

headers = {"X-Auth": "YOUR_API_KEY"}
base_url = "https://acunetix:3443/api/v1"

# Add target
target = requests.post(
    f"{base_url}/targets",
    headers=headers,
    json={"address": "https://example.com", "description": "Production site"}
)

# Start scan
scan = requests.post(
    f"{base_url}/scans",
    headers=headers,
    json={
        "target_id": target.json()["target_id"],
        "profile_id": "11111111-1111-1111-1111-111111111111"  # Full Scan
    }
)

# Get vulnerabilities
vulns = requests.get(
    f"{base_url}/vulnerabilities",
    headers=headers,
    params={"severity": "3"}  # High severity
)
```

## Best Practices
- Use **AcuSensor** (IAST agent) for deeper detection
- Configure **login sequences** for authenticated scanning
- Integrate with **CI/CD** for pre-deployment security checks
