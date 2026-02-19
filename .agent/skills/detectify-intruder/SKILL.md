---
name: Detectify & Intruder
description: Skill for web vulnerability scanning SaaS — Detectify for external attack surface monitoring and Intruder for continuous vulnerability scanning.
---

# Detectify & Intruder — Web Vulnerability SaaS

## Detectify
```python
import requests
headers = {"X-Detectify-Key": "YOUR_API_KEY"}

# Start scan
requests.post("https://api.detectify.com/rest/v2/scans/{scan_profile}/",
    headers=headers)

# Get findings
findings = requests.get("https://api.detectify.com/rest/v2/findings/",
    headers=headers)
```

## Intruder
```python
headers = {"Authorization": f"Bearer {token}"}

# Get targets
targets = requests.get("https://api.intruder.io/v1/targets", headers=headers)

# Start scan
requests.post(f"https://api.intruder.io/v1/targets/{target_id}/scan", headers=headers)
```

## Best Practices
- Schedule **continuous scanning** for external attack surface
- Integrate findings into **ticketing systems** for remediation tracking
