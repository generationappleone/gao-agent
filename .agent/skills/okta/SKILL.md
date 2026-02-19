---
name: Okta
description: Skill for Okta — identity and access management (IAM) with SSO, MFA, user lifecycle management, and API-driven identity automation.
---

# Okta — Identity & Access Management

## Overview
Okta is a cloud-based IAM platform providing Single Sign-On (SSO), Multi-Factor Authentication (MFA), user lifecycle management, and API-driven identity automation.

## API
```python
import requests

headers = {
    "Authorization": "SSWS YOUR_API_TOKEN",
    "Content-Type": "application/json"
}
base = "https://your-org.okta.com/api/v1"

# List users
users = requests.get(f"{base}/users", headers=headers)

# Create user
user = requests.post(f"{base}/users?activate=true", headers=headers, json={
    "profile": {
        "firstName": "John",
        "lastName": "Doe",
        "email": "john@example.com",
        "login": "john@example.com"
    },
    "credentials": {
        "password": {"value": "TempPass123!"}
    }
})

# Assign app to user
requests.put(f"{base}/apps/{app_id}/users/{user_id}", headers=headers)

# List system log events
logs = requests.get(f"{base}/logs", headers=headers,
    params={"filter": 'eventType eq "user.session.start"', "since": "2024-01-01T00:00:00Z"})
```

### Key API Endpoints
| Endpoint | Description |
|----------|-------------|
| `/api/v1/users` | User management |
| `/api/v1/groups` | Group management |
| `/api/v1/apps` | Application management |
| `/api/v1/authn` | Authentication API |
| `/api/v1/logs` | System log events |
| `/api/v1/policies` | Security policies |

## Best Practices
- Implement **Adaptive MFA** based on risk signals
- Use **Lifecycle Management** for automated provisioning/deprovisioning
- Enable **ThreatInsight** for credential stuffing protection
