---
name: Auth0
description: Skill for Auth0 (by Okta) — identity platform with authentication, authorization, Management API, and extensibility through Actions/Rules.
---

# Auth0 — Identity & Auth Platform

## Overview
Auth0 (by Okta) is a developer-focused identity platform providing authentication, authorization, security, and user management with extensive SDKs and APIs.

## Management API
```python
from auth0.management import Auth0

domain = "your-tenant.auth0.com"
mgmt_api_token = "YOUR_MANAGEMENT_API_TOKEN"

auth0 = Auth0(domain, mgmt_api_token)

# List users
users = auth0.users.list()

# Create user
user = auth0.users.create({
    "email": "user@example.com",
    "password": "SecurePass123!",
    "connection": "Username-Password-Authentication"
})

# Assign roles
auth0.users.add_roles(user["user_id"], {"roles": ["role_id"]})

# Get user login logs
logs = auth0.logs.search(q='type:s AND user_id:"auth0|user_id"')
```

### Key API Endpoints
| Endpoint | Description |
|----------|-------------|
| `/api/v2/users` | User CRUD operations |
| `/api/v2/roles` | Role management |
| `/api/v2/connections` | Identity provider connections |
| `/api/v2/organizations` | Multi-tenant organizations |
| `/api/v2/actions` | Custom Actions management |
| `/oauth/token` | Token endpoint |

## Best Practices
- Use **Auth0 Actions** (not deprecated Rules) for extensibility
- Implement **Organizations** for B2B multi-tenancy
- Enable **Attack Protection** (brute force, breached password detection)
