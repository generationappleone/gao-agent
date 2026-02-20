---
name: Keycloak
description: Skill for implementing Keycloak as an Identity and Access Management (IAM) solution — covering realm setup, client configuration, OIDC/SAML, role management, user federation, and integration with frontend and backend applications.
---

# Keycloak Skill

## Overview
Keycloak is an open-source Identity and Access Management (IAM) solution providing SSO, OIDC, SAML, user federation (LDAP/AD), social login, role-based access control, and admin console. It handles authentication complexity so applications can focus on business logic.

**References**:
- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [Keycloak Admin REST API](https://www.keycloak.org/docs-api/latest/rest-api/)

---

## Setup

```yaml
services:
  keycloak:
    image: quay.io/keycloak/keycloak:24.0
    command: start-dev
    environment:
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: admin
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://postgres:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: ${KC_DB_PASSWORD}
    ports: ["8080:8080"]
    depends_on: [postgres]
```

---

## Backend Integration (Node.js)

```typescript
import Keycloak from 'keycloak-connect';
import session from 'express-session';

const memoryStore = new session.MemoryStore();
const keycloak = new Keycloak({ store: memoryStore }, {
  realm: 'myapp',
  'auth-server-url': process.env.KEYCLOAK_URL,
  'ssl-required': 'external',
  resource: 'myapp-api',
  'bearer-only': true,
  'confidential-port': 0,
});

// Middleware
app.use(keycloak.middleware());

// Protected route
app.get('/api/products', keycloak.protect(), (req, res) => {
  res.json({ data: [] });
});

// Role-based access
app.post('/api/products', keycloak.protect('realm:admin'), (req, res) => {
  res.json({ message: 'Admin only' });
});
```

---

## Token Verification (Manual)

```typescript
import jwt from 'jsonwebtoken';
import jwksClient from 'jwks-rsa';

const client = jwksClient({ jwksUri: `${process.env.KEYCLOAK_URL}/realms/myapp/protocol/openid-connect/certs` });

export async function verifyKeycloakToken(token: string) {
  const decoded = jwt.decode(token, { complete: true });
  const key = await client.getSigningKey(decoded!.header.kid);
  return jwt.verify(token, key.getPublicKey(), { audience: 'myapp-api', issuer: `${process.env.KEYCLOAK_URL}/realms/myapp` });
}
```

---

## React Integration

```typescript
import Keycloak from 'keycloak-js';

const keycloak = new Keycloak({ url: process.env.REACT_APP_KEYCLOAK_URL, realm: 'myapp', clientId: 'myapp-frontend' });

await keycloak.init({ onLoad: 'login-required', checkLoginIframe: false });

// Axios interceptor
axios.interceptors.request.use((config) => {
  if (keycloak.token) config.headers.Authorization = `Bearer ${keycloak.token}`;
  return config;
});

// Token refresh
setInterval(() => { keycloak.updateToken(30).catch(() => keycloak.login()); }, 60000);
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Realms** | Separate realm per environment/tenant |
| **Clients** | Public (SPA), confidential (backend) |
| **Roles** | Realm roles for global, client roles for app-specific |
| **Token** | Verify JWT with JWKS endpoint |
| **Refresh** | Auto-refresh tokens before expiry |
| **OIDC** | Use OpenID Connect for modern apps |
| **Social login** | Configure Google/GitHub/Facebook providers |
| **User federation** | LDAP/Active Directory integration |
| **Themes** | Customize login/registration pages |
| **HA** | Clustered deployment for production |

---

## Rules Integration
- **Auth**: OIDC-based SSO with Keycloak
- **Backend**: Bearer token verification via JWKS
- **Frontend**: keycloak-js with auto-refresh
- **RBAC**: Realm and client roles for access control
