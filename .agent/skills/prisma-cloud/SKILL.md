---
name: Prisma Cloud
description: Skill for Prisma Cloud (Palo Alto) — CNAPP for cloud security posture, workload protection, code security, and API integration.
---

# Prisma Cloud — Cloud Security (Palo Alto)

## Overview
Prisma Cloud by Palo Alto Networks provides CNAPP capabilities for CSPM, CWPP, CAS, CIEM, and code security across multi-cloud environments.

## API
```python
import requests

# Authenticate
auth = requests.post("https://api.prismacloud.io/login",
    json={"username": "user", "password": "pass"})
token = auth.json()["token"]
headers = {"x-redlock-auth": token}

# Get alerts
alerts = requests.get("https://api.prismacloud.io/v2/alert", headers=headers,
    params={"alert.status": "open", "policy.severity": "high"})

# Get compliance posture
compliance = requests.get("https://api.prismacloud.io/compliance/posture", headers=headers)
```

## Best Practices
- Use **Bridgecrew** (integrated) for IaC scanning in CI/CD
- Enable **auto-remediation** for common misconfigurations
- Configure **microsegmentation** for workload protection
