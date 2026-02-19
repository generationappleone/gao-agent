---
name: Duo Security
description: Skill for Duo Security (Cisco) — multi-factor authentication (MFA), device trust, adaptive access policies, and Admin/Auth API integration.
---

# Duo Security — MFA & Zero Trust

## Overview
Duo Security (by Cisco) provides cloud-based MFA, device trust, adaptive access policies, and single sign-on for secure workforce access.

## Auth API
```python
import duo_client

auth_api = duo_client.Auth(
    ikey='YOUR_INTEGRATION_KEY',
    skey='YOUR_SECRET_KEY',
    host='api-XXXXXXXX.duosecurity.com'
)

# Verify user credentials with 2FA
result = auth_api.auth('push', username='john', device='auto')
print(result)  # {'result': 'allow', 'status': 'allow', ...}

# Check user enrollment status
preauth = auth_api.preauth(username='john')
```

## Admin API
```python
admin_api = duo_client.Admin(ikey='ADMIN_IKEY', skey='ADMIN_SKEY', host='api-HOST.duosecurity.com')

# List users
users = admin_api.get_users()

# Create user
admin_api.add_user(username='newuser', email='new@example.com')
```

## Best Practices
- Implement **push notifications** as primary MFA method
- Enable **Duo Trust Monitor** for anomaly detection
- Configure **device health policies** for endpoint compliance
