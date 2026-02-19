---
name: Bitdefender GravityZone
description: Skill for Bitdefender GravityZone — endpoint protection, EDR, risk analytics, and API integration for enterprise security.
---

# Bitdefender GravityZone — Endpoint + EDR

## Overview
Bitdefender GravityZone is an enterprise endpoint protection platform combining EPP, EDR, and risk analytics with machine learning-based threat detection.

## Key Capabilities
- **HyperDetect**: Tunable machine learning for advanced attacks
- **Sandbox Analyzer**: Automated sandbox detonation
- **EDR**: Incident investigation and response
- **Risk Analytics**: Endpoint risk scoring and hardening
- **Patch Management**: Automated vulnerability patching

## API Integration
```python
import requests

base_url = "https://your-gravityzone.bitdefender.com/api"
headers = {
    "Authorization": "Basic YOUR_API_KEY",
    "Content-Type": "application/json"
}

# Get managed endpoints
endpoints = requests.post(
    f"{base_url}/v1.0/jsonrpc/network",
    headers=headers,
    json={
        "method": "getEndpointsList",
        "params": {"parentId": "root", "page": 1, "perPage": 50}
    }
)

# Get incidents
incidents = requests.post(
    f"{base_url}/v1.0/jsonrpc/incidents",
    headers=headers,
    json={"method": "getIncidentsList", "params": {"page": 1}}
)
```

## Best Practices
- Enable **HyperDetect** at aggressive detection levels
- Configure **Risk Analytics** dashboards for hardening
- Use **Network Attack Defense** for lateral movement prevention
