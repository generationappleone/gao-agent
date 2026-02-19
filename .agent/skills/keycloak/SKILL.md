---
name: Keycloak
description: Skill for implementing Keycloak as an Identity and Access Management (IAM) solution — covering realm setup, client configuration, OIDC/SAML, role management, user federation, and integration with frontend and backend applications.
---

# Keycloak Skill

## Overview
**Keycloak** is an open-source Identity and Access Management (IAM) solution by Red Hat. It provides SSO, social login, user federation, role-based access control, and standards-based authentication (OAuth 2.0, OpenID Connect, SAML 2.0).

---

## Quick Start (Docker)

```bash
# Development mode
docker run -d --name keycloak \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  quay.io/keycloak/keycloak:latest start-dev

# Production mode (with PostgreSQL)
docker run -d --name keycloak \
  -p 8443:8443 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD='StrongP@ssw0rd' \
  -e KC_DB=postgres \
  -e KC_DB_URL=jdbc:postgresql://db:5432/keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=keycloak_pass \
  -e KC_HOSTNAME=auth.yourdomain.com \
  quay.io/keycloak/keycloak:latest start --optimized
```

### Docker Compose
```yaml
version: '3.8'
services:
  keycloak:
    image: quay.io/keycloak/keycloak:latest
    command: start-dev
    ports:
      - "8080:8080"
    environment:
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: admin
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://postgres:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: keycloak
    depends_on:
      - postgres

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: keycloak
    volumes:
      - keycloak_data:/var/lib/postgresql/data

volumes:
  keycloak_data:
```

---

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Realm** | A security domain. Each app/project gets its own realm. |
| **Client** | An application that uses Keycloak (frontend, backend, mobile). |
| **User** | An end user with credentials. |
| **Role** | Permission grant (realm-level or client-level). |
| **Group** | Collection of users (roles can be assigned to groups). |
| **Identity Provider** | External login (Google, GitHub, SAML IdP). |
| **User Federation** | Sync users from LDAP/Active Directory. |

---

## Realm Configuration Checklist

```
□ Create realm (not use 'master' for applications)
□ Configure realm settings:
  - Login: Enable registration, forgot password, remember me
  - Email: Configure SMTP for verification emails
  - Themes: Customize login page branding
  - Sessions: Set SSO session max (8 hours), idle (30 min)
  - Tokens: Access token lifespan (5-15 min), refresh token (30 days)
□ Create client(s) for each application
□ Define roles (realm + client level)
□ Configure identity providers (Google, etc.)
□ Set password policy (12+ chars, complexity, history)
□ Enable brute force detection (5 failures, 15 min lockout)
```

---

## React Integration (OIDC)

### Installation
```bash
npm install keycloak-js @react-keycloak/web
# or modern alternative
npm install oidc-client-ts react-oidc-context
```

### Using react-oidc-context (Recommended)
```tsx
// providers/AuthProvider.tsx
import { AuthProvider } from 'react-oidc-context';

const oidcConfig = {
  authority: import.meta.env.VITE_KEYCLOAK_URL + '/realms/' + import.meta.env.VITE_KEYCLOAK_REALM,
  client_id: import.meta.env.VITE_KEYCLOAK_CLIENT_ID,
  redirect_uri: window.location.origin + '/callback',
  post_logout_redirect_uri: window.location.origin,
  scope: 'openid profile email',
  automaticSilentRenew: true,
};

export function AppAuthProvider({ children }: { children: React.ReactNode }) {
  return <AuthProvider {...oidcConfig}>{children}</AuthProvider>;
}
```

```tsx
// hooks/useAuth.ts
import { useAuth as useOidcAuth } from 'react-oidc-context';

export function useAuth() {
  const auth = useOidcAuth();

  return {
    isAuthenticated: auth.isAuthenticated,
    isLoading: auth.isLoading,
    user: auth.user?.profile,
    accessToken: auth.user?.access_token,
    login: () => auth.signinRedirect(),
    logout: () => auth.signoutRedirect(),
    roles: (auth.user?.profile as any)?.realm_access?.roles || [],
    hasRole: (role: string) =>
      ((auth.user?.profile as any)?.realm_access?.roles || []).includes(role),
  };
}
```

```tsx
// components/ProtectedRoute.tsx
import { useAuth } from '@/hooks/useAuth';
import { Navigate } from 'react-router-dom';

export function ProtectedRoute({ children, requiredRole }: { children: React.ReactNode; requiredRole?: string }) {
  const { isAuthenticated, isLoading, hasRole } = useAuth();

  if (isLoading) return <LoadingSkeleton />;
  if (!isAuthenticated) return <Navigate to="/login" />;
  if (requiredRole && !hasRole(requiredRole)) return <Navigate to="/unauthorized" />;

  return <>{children}</>;
}
```

### Backend Token Verification (Node.js)
```typescript
// middleware/auth.ts
import jwt from 'jsonwebtoken';
import jwksClient from 'jwks-rsa';

const client = jwksClient({
  jwksUri: `${process.env.KEYCLOAK_URL}/realms/${process.env.KEYCLOAK_REALM}/protocol/openid-connect/certs`,
  cache: true,
  rateLimit: true,
});

function getKey(header: jwt.JwtHeader, callback: jwt.SigningKeyCallback) {
  client.getSigningKey(header.kid, (err, key) => {
    callback(err, key?.getPublicKey());
  });
}

export function verifyToken(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'No token provided' });

  jwt.verify(token, getKey, {
    algorithms: ['RS256'],
    issuer: `${process.env.KEYCLOAK_URL}/realms/${process.env.KEYCLOAK_REALM}`,
  }, (err, decoded) => {
    if (err) return res.status(401).json({ error: 'Invalid token' });
    req.user = decoded as JwtPayload;
    next();
  });
}

export function requireRole(role: string) {
  return (req: Request, res: Response, next: NextFunction) => {
    const roles = req.user?.realm_access?.roles || [];
    if (!roles.includes(role)) return res.status(403).json({ error: 'Insufficient role' });
    next();
  };
}
```

---

## Environment Variables
```bash
# Frontend
VITE_KEYCLOAK_URL=https://auth.yourdomain.com
VITE_KEYCLOAK_REALM=my-app
VITE_KEYCLOAK_CLIENT_ID=frontend-app

# Backend
KEYCLOAK_URL=https://auth.yourdomain.com
KEYCLOAK_REALM=my-app
KEYCLOAK_CLIENT_ID=backend-api
KEYCLOAK_CLIENT_SECRET=your-client-secret
```

## Best Practices
1. **Never use master realm** for applications — create a dedicated realm
2. **Short-lived access tokens** (5-15 min) with refresh tokens (30 days)
3. **Use PKCE** for public clients (SPAs, mobile apps)
4. **Validate tokens** on EVERY backend request — never trust frontend
5. **Enable brute force protection** in realm settings
6. **Customize login theme** to match your brand
7. **Use groups** for bulk role assignment
8. **Configure SMTP** for email verification and password reset

## Rules Integration
- **Developer Security**: Authentication controls in `rules/developer-security.md`
- **ISO 27001**: A.8.2 privileged access, A.8.5 secure auth in `skills/iso-27001/`
- **CIS Controls**: Control 5 & 6 (account & access mgmt) in `skills/cis-controls/`
