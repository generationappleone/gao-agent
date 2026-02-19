---
name: Gravitee
description: Skill for Gravitee — API management and security platform with gateway, developer portal, identity management, and policy enforcement.
---

# Gravitee — API Security & Management

## Overview
Gravitee is an open-source API management platform providing an API gateway, developer portal, access management, and comprehensive API security policies.

## Key Features
- **API Gateway**: Request proxying, rate limiting, transformation
- **API Designer**: Visual API design and documentation
- **Developer Portal**: Self-service API consumption
- **Access Management**: OAuth 2.0, OIDC, SAML identity management

## API Gateway Policies
```json
{
  "flows": [{
    "pre": [
      {"policy": "rate-limit", "configuration": {"rate": {"limit": 100, "periodTime": 60}}},
      {"policy": "jwt", "configuration": {"publicKeyResolver": "JWKS_URL"}},
      {"policy": "ip-filtering", "configuration": {"whitelistIps": ["10.0.0.0/8"]}}
    ],
    "post": [
      {"policy": "transform-headers", "configuration": {"removeHeaders": ["X-Internal-*"]}}
    ]
  }]
}
```

## Best Practices
- Enforce **rate limiting** on all public APIs
- Use **JWT/OAuth policies** for authentication
- Enable **API analytics** for usage monitoring
