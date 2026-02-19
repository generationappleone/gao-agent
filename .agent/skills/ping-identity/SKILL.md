---
name: Ping Identity
description: Skill for Ping Identity — enterprise IAM with SSO, MFA, API security, and PingOne/PingFederate platform APIs.
---

# Ping Identity — Enterprise IAM

## Overview
Ping Identity provides enterprise identity management including SSO, MFA, API security, and identity governance through PingOne (cloud) and PingFederate (on-premise).

## PingOne API
```python
import requests
headers = {"Authorization": f"Bearer {access_token}"}

# List users
users = requests.get(
    f"https://api.pingone.com/v1/environments/{env_id}/users",
    headers=headers
)

# Create user
requests.post(
    f"https://api.pingone.com/v1/environments/{env_id}/users",
    headers=headers,
    json={"email": "user@example.com", "name": {"given": "John", "family": "Doe"}}
)
```

## Best Practices
- Use **PingFederate** for complex enterprise federation
- Implement **PingAccess** for API security gateway
- Enable **risk-based authentication** with PingOne Protect
