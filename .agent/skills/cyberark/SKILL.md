---
name: CyberArk
description: Skill for CyberArk — privileged access management (PAM) with credential vaulting, session monitoring, REST API, and just-in-time access.
---

# CyberArk — Privileged Access Management

## Overview
CyberArk provides privileged access management (PAM) including credential vaulting, session isolation/monitoring, just-in-time access, and secrets management for DevOps.

## REST API (PAS Web Services)
```python
import requests

# Authenticate (CyberArk PVWA)
auth = requests.post(
    "https://pvwa.example.com/PasswordVault/api/auth/CyberArk/Logon",
    json={"username": "admin", "password": "pass"}
)
token = auth.text.strip('"')
headers = {"Authorization": token}

# Get accounts
accounts = requests.get(
    "https://pvwa.example.com/PasswordVault/api/Accounts",
    headers=headers,
    params={"search": "Windows", "limit": 25}
)

# Retrieve password
password = requests.post(
    f"https://pvwa.example.com/PasswordVault/api/Accounts/{account_id}/Password/Retrieve",
    headers=headers,
    json={"reason": "Automated deployment"}
)
```

## Conjur (DevOps Secrets)
```bash
# Authenticate to Conjur
conjur authenticate -i admin

# Set a secret
conjur variable set -i prod/db/password -v 'MySecret123'

# Get a secret
conjur variable get -i prod/db/password
```

## Best Practices
- Implement **credential rotation** policies
- Enable **session recording** for privileged sessions
- Use **Conjur** for application/DevOps secrets management
- Configure **just-in-time access** to reduce standing privileges
