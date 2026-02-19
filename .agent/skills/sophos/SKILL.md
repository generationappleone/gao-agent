---
name: Sophos Intercept X
description: Skill for Sophos Intercept X — endpoint protection and XDR suite with deep learning, anti-ransomware, and Sophos Central API.
---

# Sophos Intercept X — Endpoint/XDR Suite

## Overview
Sophos Intercept X provides endpoint protection with deep learning AI, anti-ransomware (CryptoGuard), exploit prevention, and XDR across endpoints, servers, firewall, and email.

## Sophos Central API
```python
import requests

headers = {
    "Authorization": "Basic YOUR_API_CREDENTIALS",
    "X-Tenant-ID": "YOUR_TENANT_ID"
}

# Get alerts
alerts = requests.get(
    "https://api.central.sophos.com/common/v1/alerts",
    headers=headers
)

# Get endpoints
endpoints = requests.get(
    "https://api.central.sophos.com/endpoint/v1/endpoints",
    headers=headers
)

# Isolate endpoint
requests.post(
    f"https://api.central.sophos.com/endpoint/v1/endpoints/{endpoint_id}/isolation",
    headers=headers,
    json={"enabled": True}
)
```

## Key Features
- **CryptoGuard**: Anti-ransomware with file rollback
- **Deep Learning**: Pre-execution malware prevention
- **Active Adversary Mitigations**: Anti-exploit technology
- **Synchronized Security**: Firewall-endpoint coordination

## Best Practices
- Enable **CryptoGuard** on all endpoints
- Configure **Synchronized Security** with Sophos XG firewall
- Use **Threat Cases** for guided investigation workflows
