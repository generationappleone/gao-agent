---
name: FusionAuth
description: Skill for FusionAuth — open-source identity platform covering authentication, OAuth 2.0/OIDC, user management, MFA, SSO, social login, webhooks, theming, multi-tenancy, and integration with Node.js, React, Next.js, Angular, Vue, Flutter, Go, Java, Python, PHP, and .NET.
---

# FusionAuth Skill

## Overview
FusionAuth is a developer-focused, open-source Identity and Access Management (IAM) platform. It provides complete authentication infrastructure including OAuth 2.0/OIDC, SAML v2, passwordless login, MFA (TOTP, SMS, Email), social login (Google, Apple, Facebook, GitHub), user registration, role-based access control, multi-tenancy, webhooks, and customizable login themes — all via REST API and client SDKs.

**Key Differentiators vs Auth0/Keycloak**:
- Runs on-premise or cloud (full data ownership)
- Single-tenant architecture (no shared infrastructure)
- Unlimited users, no per-user pricing
- Sub-millisecond login performance
- Full-featured Community Edition (free)

**References**:
- [FusionAuth Documentation](https://fusionauth.io/docs/)
- [FusionAuth API Reference](https://fusionauth.io/docs/apis/)
- [FusionAuth SDKs](https://fusionauth.io/docs/sdks/)
- [FusionAuth GitHub](https://github.com/FusionAuth)

---

## 1. Installation & Setup

### Docker Compose (Recommended)

```yaml
# docker-compose.yml
version: '3'
services:
  fusionauth-db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: fusionauth
      POSTGRES_USER: fusionauth
      POSTGRES_PASSWORD: ${FUSIONAUTH_DB_PASSWORD:-super_secret}
    volumes:
      - fusionauth_db:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U fusionauth"]
      interval: 5s
      timeout: 5s
      retries: 5

  fusionauth-search:
    image: opensearchproject/opensearch:2.11.0
    environment:
      - cluster.name=fusionauth
      - discovery.type=single-node
      - plugins.security.disabled=true
      - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - fusionauth_search:/usr/share/opensearch/data

  fusionauth:
    image: fusionauth/fusionauth-app:latest
    depends_on:
      fusionauth-db:
        condition: service_healthy
      fusionauth-search:
        condition: service_started
    environment:
      DATABASE_URL: jdbc:postgresql://fusionauth-db:5432/fusionauth
      DATABASE_ROOT_USERNAME: fusionauth
      DATABASE_ROOT_PASSWORD: ${FUSIONAUTH_DB_PASSWORD:-super_secret}
      DATABASE_USERNAME: fusionauth
      DATABASE_PASSWORD: ${FUSIONAUTH_DB_PASSWORD:-super_secret}
      FUSIONAUTH_APP_MEMORY: 512M
      FUSIONAUTH_APP_RUNTIME_MODE: ${FUSIONAUTH_RUNTIME_MODE:-development}
      FUSIONAUTH_APP_URL: http://fusionauth:9011
      SEARCH_SERVERS: http://fusionauth-search:9200
      SEARCH_TYPE: elasticsearch
      FUSIONAUTH_APP_KICKSTART_FILE: /usr/local/fusionauth/kickstart/kickstart.json
    ports:
      - "9011:9011"
    volumes:
      - fusionauth_config:/usr/local/fusionauth/config
      - ./kickstart:/usr/local/fusionauth/kickstart

volumes:
  fusionauth_db:
  fusionauth_search:
  fusionauth_config:
```

### Kickstart (Automated Setup)

```json
// kickstart/kickstart.json
{
  "variables": {
    "apiKey": "#{ENV.FUSIONAUTH_API_KEY}",
    "applicationId": "#{ENV.FUSIONAUTH_APP_ID}",
    "tenantId": "#{ENV.FUSIONAUTH_TENANT_ID}"
  },
  "apiKeys": [
    {
      "key": "#{apiKey}",
      "description": "MyApp API Key"
    }
  ],
  "requests": [
    {
      "method": "PATCH",
      "url": "/api/tenant/#{tenantId}",
      "body": {
        "tenant": {
          "name": "MyApp",
          "issuer": "myapp.com",
          "emailConfiguration": {
            "host": "#{ENV.SMTP_HOST}",
            "port": 587,
            "username": "#{ENV.SMTP_USER}",
            "password": "#{ENV.SMTP_PASS}",
            "defaultFromEmail": "noreply@myapp.com",
            "defaultFromName": "MyApp"
          },
          "jwtConfiguration": {
            "accessTokenKeyId": "#{asymmetricKeyId}",
            "timeToLiveInSeconds": 3600,
            "refreshTokenTimeToLiveInMinutes": 43200
          }
        }
      }
    },
    {
      "method": "POST",
      "url": "/api/application/#{applicationId}",
      "body": {
        "application": {
          "name": "MyApp",
          "oauthConfiguration": {
            "authorizedRedirectURLs": [
              "http://localhost:3000/oauth-callback",
              "https://myapp.com/oauth-callback"
            ],
            "clientSecret": "#{ENV.FUSIONAUTH_CLIENT_SECRET}",
            "enabledGrants": [
              "authorization_code",
              "refresh_token"
            ],
            "generateRefreshTokens": true,
            "logoutURL": "http://localhost:3000/logout",
            "requireClientAuthentication": true
          },
          "registrationConfiguration": {
            "enabled": true,
            "type": "basic"
          },
          "roles": [
            { "name": "admin", "description": "Full access" },
            { "name": "editor", "description": "Content management" },
            { "name": "user", "description": "Standard user" }
          ]
        }
      }
    }
  ]
}
```

---

## 2. Node.js Backend Integration

### FusionAuth TypeScript Client

```typescript
// src/lib/fusionauth.ts
import { FusionAuthClient } from '@fusionauth/typescript-client';

export const fusionAuthClient = new FusionAuthClient(
  process.env.FUSIONAUTH_API_KEY!,
  process.env.FUSIONAUTH_URL || 'http://localhost:9011',
  process.env.FUSIONAUTH_TENANT_ID
);

// Environment variables
// FUSIONAUTH_URL=http://localhost:9011
// FUSIONAUTH_API_KEY=your-api-key
// FUSIONAUTH_APP_ID=your-app-id
// FUSIONAUTH_CLIENT_SECRET=your-client-secret
// FUSIONAUTH_TENANT_ID=your-tenant-id
```

### OAuth 2.0 Authorization Code Flow

```typescript
// src/routes/auth.routes.ts
import { Router } from 'express';
import { fusionAuthClient } from '../lib/fusionauth';
import pkceChallenge from 'pkce-challenge';

const router = Router();
const APP_ID = process.env.FUSIONAUTH_APP_ID!;
const FA_URL = process.env.FUSIONAUTH_URL!;
const REDIRECT_URI = `${process.env.APP_URL}/oauth-callback`;

// GET /api/auth/login — Redirect to FusionAuth login page
router.get('/login', (req, res) => {
  const { code_verifier, code_challenge } = pkceChallenge();
  const state = crypto.randomUUID();

  // Store PKCE verifier and state in session
  req.session.pkceVerifier = code_verifier;
  req.session.oauthState = state;

  const params = new URLSearchParams({
    client_id: APP_ID,
    response_type: 'code',
    redirect_uri: REDIRECT_URI,
    scope: 'openid email profile offline_access',
    state,
    code_challenge,
    code_challenge_method: 'S256',
  });

  res.redirect(`${FA_URL}/oauth2/authorize?${params}`);
});

// GET /oauth-callback — Exchange code for tokens
router.get('/oauth-callback', async (req, res) => {
  const { code, state } = req.query;

  // Verify state
  if (state !== req.session.oauthState) {
    return res.status(400).json({ error: 'Invalid state parameter' });
  }

  try {
    const response = await fusionAuthClient.exchangeOAuthCodeForAccessTokenUsingPKCE(
      code as string,
      APP_ID,
      process.env.FUSIONAUTH_CLIENT_SECRET!,
      REDIRECT_URI,
      req.session.pkceVerifier!
    );

    const { access_token, refresh_token, userId } = response.response;

    // Get full user profile
    const userResponse = await fusionAuthClient.retrieveUser(userId!);
    const user = userResponse.response.user!;

    // Set session
    req.session.user = {
      id: user.id!,
      email: user.email!,
      name: `${user.firstName} ${user.lastName}`,
      roles: user.registrations?.find(r => r.applicationId === APP_ID)?.roles || [],
      avatar: user.imageUrl,
    };
    req.session.accessToken = access_token;
    req.session.refreshToken = refresh_token;

    // Clean up PKCE
    delete req.session.pkceVerifier;
    delete req.session.oauthState;

    res.redirect('/dashboard');
  } catch (error: any) {
    console.error('OAuth callback error:', error);
    res.redirect('/login?error=auth_failed');
  }
});

// POST /api/auth/refresh — Refresh access token
router.post('/refresh', async (req, res) => {
  try {
    const response = await fusionAuthClient.exchangeRefreshTokenForAccessToken(
      req.session.refreshToken!,
      APP_ID,
      process.env.FUSIONAUTH_CLIENT_SECRET!,
      'openid email profile offline_access',
      ''
    );
    req.session.accessToken = response.response.access_token;
    req.session.refreshToken = response.response.refresh_token;
    res.json({ success: true });
  } catch {
    res.status(401).json({ error: 'Token refresh failed' });
  }
});

// GET /api/auth/logout — Logout
router.get('/logout', (req, res) => {
  const idToken = req.session.idToken;
  req.session.destroy(() => {
    const params = new URLSearchParams({
      client_id: APP_ID,
      post_logout_redirect_uri: `${process.env.APP_URL}/`,
    });
    res.redirect(`${FA_URL}/oauth2/logout?${params}`);
  });
});

// GET /api/auth/me — Current user
router.get('/me', requireAuth, (req, res) => {
  res.json({ user: req.session.user });
});

export default router;
```

### JWT Verification Middleware

```typescript
// src/middleware/auth.middleware.ts
import jwt, { JwtPayload } from 'jsonwebtoken';
import jwksClient from 'jwks-rsa';

const client = jwksClient({
  jwksUri: `${process.env.FUSIONAUTH_URL}/.well-known/jwks.json`,
  cache: true,
  cacheMaxAge: 600000, // 10 minutes
  rateLimit: true,
});

async function getSigningKey(kid: string): Promise<string> {
  const key = await client.getSigningKey(kid);
  return key.getPublicKey();
}

export async function verifyFusionAuthToken(token: string): Promise<JwtPayload> {
  const decoded = jwt.decode(token, { complete: true });
  if (!decoded?.header.kid) throw new Error('No kid in token header');

  const publicKey = await getSigningKey(decoded.header.kid);
  return jwt.verify(token, publicKey, {
    algorithms: ['RS256'],
    issuer: process.env.FUSIONAUTH_ISSUER || process.env.FUSIONAUTH_URL,
    audience: process.env.FUSIONAUTH_APP_ID,
  }) as JwtPayload;
}

// Express middleware
export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const token = req.session?.accessToken || req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'Authentication required' });

  verifyFusionAuthToken(token)
    .then((payload) => {
      req.user = {
        id: payload.sub!,
        email: payload.email as string,
        roles: payload.roles as string[] || [],
      };
      next();
    })
    .catch(() => res.status(401).json({ error: 'Invalid or expired token' }));
}

// Role-based access control
export function requireRole(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user?.roles?.some(r => roles.includes(r))) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
  };
}

// Usage
app.get('/api/admin/users', requireAuth, requireRole('admin'), listUsersHandler);
app.put('/api/products/:id', requireAuth, requireRole('admin', 'editor'), updateProductHandler);
```

---

## 3. User Management API

```typescript
// src/services/user.service.ts
import { fusionAuthClient } from '../lib/fusionauth';
import type { UserRequest, RegistrationRequest } from '@fusionauth/typescript-client';

const APP_ID = process.env.FUSIONAUTH_APP_ID!;

// Register new user
export async function registerUser(data: {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  roles?: string[];
}) {
  const request: RegistrationRequest = {
    user: {
      email: data.email,
      password: data.password,
      firstName: data.firstName,
      lastName: data.lastName,
    },
    registration: {
      applicationId: APP_ID,
      roles: data.roles || ['user'],
    },
    sendSetPasswordEmail: false,
    skipVerification: false,
  };

  const response = await fusionAuthClient.register(undefined, request);
  return response.response.user;
}

// Update user profile
export async function updateUser(userId: string, data: Partial<UserRequest>) {
  const response = await fusionAuthClient.patchUser(userId, { user: data });
  return response.response.user;
}

// Search users with pagination
export async function searchUsers(params: {
  query?: string;
  page?: number;
  limit?: number;
  role?: string;
  sortBy?: string;
}) {
  const { query, page = 1, limit = 25, role, sortBy = 'insertInstant' } = params;

  let queryString = `registrations.applicationId:${APP_ID}`;
  if (query) queryString += ` AND (email:*${query}* OR firstName:*${query}* OR lastName:*${query}*)`;
  if (role) queryString += ` AND registrations.roles:${role}`;

  const response = await fusionAuthClient.searchUsersByQuery({
    search: {
      queryString,
      numberOfResults: limit,
      startRow: (page - 1) * limit,
      sortFields: [{ name: sortBy, order: 'desc' }],
    },
  });

  return {
    data: response.response.users || [],
    total: response.response.total || 0,
    page,
    totalPages: Math.ceil((response.response.total || 0) / limit),
  };
}

// Assign/remove roles
export async function updateUserRoles(userId: string, roles: string[]) {
  const response = await fusionAuthClient.patchRegistration(userId, {
    registration: {
      applicationId: APP_ID,
      roles,
    },
  });
  return response.response.registration;
}

// Deactivate user
export async function deactivateUser(userId: string) {
  await fusionAuthClient.deactivateUser(userId);
}

// Reactivate user
export async function reactivateUser(userId: string) {
  await fusionAuthClient.reactivateUser(userId);
}

// Delete user (hard delete)
export async function deleteUser(userId: string) {
  await fusionAuthClient.deleteUser(userId);
}

// Change password (admin)
export async function adminChangePassword(userId: string, newPassword: string) {
  await fusionAuthClient.patchUser(userId, {
    user: { password: newPassword },
  });
}

// Get user login history
export async function getUserLoginHistory(userId: string, limit = 10) {
  const response = await fusionAuthClient.searchLoginRecords({
    search: {
      userId,
      numberOfResults: limit,
      sortFields: [{ name: 'insertInstant', order: 'desc' }],
    },
  });
  return response.response.logins || [];
}

// Get user by email
export async function getUserByEmail(email: string) {
  const response = await fusionAuthClient.retrieveUserByEmail(email);
  return response.response.user;
}
```

---

## 4. React Frontend Integration

```tsx
// src/lib/fusionauth-config.ts
export const fusionAuthConfig = {
  baseUrl: process.env.REACT_APP_FUSIONAUTH_URL || 'http://localhost:9011',
  clientId: process.env.REACT_APP_FUSIONAUTH_CLIENT_ID!,
  redirectUri: `${window.location.origin}/oauth-callback`,
  postLogoutRedirectUri: `${window.location.origin}/`,
  scope: 'openid email profile offline_access',
};

// src/contexts/AuthContext.tsx
import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';

interface User {
  id: string;
  email: string;
  name: string;
  roles: string[];
  avatar?: string;
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: () => void;
  logout: () => void;
  hasRole: (role: string) => boolean;
}

const AuthContext = createContext<AuthContextType>(null!);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Check current session on mount
  useEffect(() => {
    fetch('/api/auth/me', { credentials: 'include' })
      .then(res => res.ok ? res.json() : null)
      .then(data => { if (data?.user) setUser(data.user); })
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, []);

  const login = useCallback(() => {
    window.location.href = '/api/auth/login';
  }, []);

  const logout = useCallback(() => {
    window.location.href = '/api/auth/logout';
  }, []);

  const hasRole = useCallback((role: string) => {
    return user?.roles?.includes(role) ?? false;
  }, [user]);

  return (
    <AuthContext.Provider value={{ user, isAuthenticated: !!user, isLoading, login, logout, hasRole }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);

// src/components/ProtectedRoute.tsx
export function ProtectedRoute({ children, roles }: { children: React.ReactNode; roles?: string[] }) {
  const { isAuthenticated, isLoading, user, login } = useAuth();

  if (isLoading) return <div className="loading-spinner">Loading...</div>;
  if (!isAuthenticated) { login(); return null; }
  if (roles && !roles.some(r => user?.roles.includes(r))) {
    return <div className="forbidden">You don't have permission to access this page.</div>;
  }
  return <>{children}</>;
}

// Usage in App.tsx
function App() {
  return (
    <AuthProvider>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/dashboard" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
        <Route path="/admin/*" element={<ProtectedRoute roles={['admin']}><AdminPanel /></ProtectedRoute>} />
      </Routes>
    </AuthProvider>
  );
}
```

---

## 5. Next.js App Router Integration

```typescript
// src/lib/fusionauth-server.ts (Server-side)
import { FusionAuthClient } from '@fusionauth/typescript-client';
import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';

const client = new FusionAuthClient(
  process.env.FUSIONAUTH_API_KEY!,
  process.env.FUSIONAUTH_URL!,
  process.env.FUSIONAUTH_TENANT_ID
);

export async function getServerSession() {
  const cookieStore = await cookies();
  const sessionToken = cookieStore.get('fa_session')?.value;
  if (!sessionToken) return null;

  try {
    // Verify the token
    const payload = await verifyFusionAuthToken(sessionToken);
    return {
      user: {
        id: payload.sub!,
        email: payload.email as string,
        roles: payload.roles as string[],
      },
      accessToken: sessionToken,
    };
  } catch {
    return null;
  }
}

export async function requireServerAuth() {
  const session = await getServerSession();
  if (!session) redirect('/api/auth/login');
  return session;
}

// app/dashboard/page.tsx
export default async function DashboardPage() {
  const session = await requireServerAuth();

  return (
    <div>
      <h1>Welcome, {session.user.email}</h1>
      <p>Roles: {session.user.roles.join(', ')}</p>
    </div>
  );
}
```

---

## 6. Social Login (Identity Providers)

```typescript
// Configure via API
export async function setupGoogleIdentityProvider() {
  await fusionAuthClient.createIdentityProvider(undefined, {
    identityProvider: {
      type: 'Google',
      enabled: true,
      applicationConfiguration: {
        [APP_ID]: {
          enabled: true,
          createRegistration: true,
        },
      },
      client_id: process.env.GOOGLE_CLIENT_ID!,
      client_secret: process.env.GOOGLE_CLIENT_SECRET!,
      scope: 'openid email profile',
      buttonText: 'Login with Google',
    },
  });
}

export async function setupGitHubIdentityProvider() {
  await fusionAuthClient.createIdentityProvider(undefined, {
    identityProvider: {
      type: 'GitHub' as any,
      enabled: true,
      applicationConfiguration: {
        [APP_ID]: { enabled: true, createRegistration: true },
      },
      client_id: process.env.GITHUB_CLIENT_ID!,
      client_secret: process.env.GITHUB_CLIENT_SECRET!,
      scope: 'user:email',
      buttonText: 'Login with GitHub',
    },
  });
}

export async function setupAppleIdentityProvider() {
  await fusionAuthClient.createIdentityProvider(undefined, {
    identityProvider: {
      type: 'Apple' as any,
      enabled: true,
      applicationConfiguration: {
        [APP_ID]: { enabled: true, createRegistration: true },
      },
      bundleId: process.env.APPLE_BUNDLE_ID!,
      servicesId: process.env.APPLE_SERVICES_ID!,
      teamId: process.env.APPLE_TEAM_ID!,
      keyId: process.env.APPLE_KEY_ID!,
      buttonText: 'Login with Apple',
    },
  });
}
```

---

## 7. Multi-Factor Authentication (MFA)

```typescript
// Enable MFA for application
export async function enableMFA() {
  await fusionAuthClient.patchApplication(APP_ID, {
    application: {
      multiFactorConfiguration: {
        email: { enabled: true, templateId: 'email-mfa-template-id' },
        sms: { enabled: true, templateId: 'sms-mfa-template-id' },
        authenticator: { enabled: true, algorithm: 'HmacSHA1' },
      },
      loginConfiguration: {
        requireAuthentication: true,
      },
    },
  });
}

// Enable MFA for a user (TOTP Authenticator)
export async function enableUserMFA(userId: string) {
  const response = await fusionAuthClient.generateTwoFactorSecret();
  const { secret, secretBase32Encoded } = response.response;

  // User scans QR code with authenticator app
  return {
    secret: secretBase32Encoded,
    qrCodeUrl: `otpauth://totp/MyApp:${userId}?secret=${secretBase32Encoded}&issuer=MyApp`,
  };
}

// Verify and activate MFA
export async function verifyAndActivateMFA(userId: string, code: string, secret: string) {
  await fusionAuthClient.enableTwoFactor(userId, {
    code,
    method: 'authenticator',
    secret,
  });
}

// Disable MFA
export async function disableMFA(userId: string, methodId: string, code: string) {
  await fusionAuthClient.disableTwoFactor(userId, methodId, code);
}
```

---

## 8. Webhook Event Handling

```typescript
// src/routes/webhook.routes.ts
import crypto from 'crypto';

const WEBHOOK_SECRET = process.env.FUSIONAUTH_WEBHOOK_SECRET!;

// Verify webhook signature
function verifyWebhookSignature(payload: string, signature: string): boolean {
  const expected = crypto.createHmac('sha256', WEBHOOK_SECRET).update(payload).digest('hex');
  return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected));
}

router.post('/fusionauth', express.raw({ type: 'application/json' }), async (req, res) => {
  const signature = req.headers['x-fusionauth-signature'] as string;
  if (signature && !verifyWebhookSignature(req.body.toString(), signature)) {
    return res.status(401).json({ error: 'Invalid signature' });
  }

  const event = JSON.parse(req.body.toString());

  switch (event.event.type) {
    case 'user.create':
      const newUser = event.event.user;
      console.log(`New user registered: ${newUser.email}`);
      await db.userProfile.create({
        data: { fusionAuthId: newUser.id, email: newUser.email, name: `${newUser.firstName} ${newUser.lastName}` },
      });
      await sendWelcomeEmail(newUser.email, newUser.firstName);
      break;

    case 'user.update':
      const updatedUser = event.event.user;
      await db.userProfile.update({
        where: { fusionAuthId: updatedUser.id },
        data: { email: updatedUser.email, name: `${updatedUser.firstName} ${updatedUser.lastName}` },
      });
      break;

    case 'user.delete':
      await db.userProfile.delete({ where: { fusionAuthId: event.event.user.id } });
      break;

    case 'user.login.success':
      await db.loginAudit.create({
        data: {
          userId: event.event.user.id,
          ipAddress: event.event.ipAddress,
          applicationId: event.event.applicationId,
          loginAt: new Date(event.event.createInstant),
        },
      });
      break;

    case 'user.login.failed':
      const failedUser = event.event.user;
      console.warn(`Failed login for: ${failedUser?.email || 'unknown'} from ${event.event.ipAddress}`);
      // Alert on brute force
      const recentFailures = await db.loginAudit.count({
        where: { ipAddress: event.event.ipAddress, success: false, loginAt: { gte: new Date(Date.now() - 15 * 60 * 1000) } },
      });
      if (recentFailures > 5) await alertSecurityTeam(event.event.ipAddress);
      break;

    case 'user.registration.create':
      console.log(`User ${event.event.user.email} registered for app ${event.event.registration.applicationId}`);
      break;

    case 'user.deactivate':
      await db.userProfile.update({
        where: { fusionAuthId: event.event.user.id },
        data: { status: 'inactive' },
      });
      break;

    case 'user.password.breach':
      // Compromised password detected
      await notifyUser(event.event.user.email, 'Your password was found in a data breach. Please change it.');
      break;

    default:
      console.log(`Unhandled event: ${event.event.type}`);
  }

  res.status(200).json({ status: 'ok' });
});
```

---

## 9. Multi-Tenancy

```typescript
// Create a new tenant
export async function createTenant(data: { name: string; issuer: string; domain: string }) {
  const response = await fusionAuthClient.createTenant(undefined, {
    tenant: {
      name: data.name,
      issuer: data.issuer,
      jwtConfiguration: {
        timeToLiveInSeconds: 3600,
        refreshTokenTimeToLiveInMinutes: 43200,
      },
      emailConfiguration: {
        host: process.env.SMTP_HOST!,
        port: 587,
        username: process.env.SMTP_USER!,
        password: process.env.SMTP_PASS!,
        defaultFromEmail: `noreply@${data.domain}`,
        defaultFromName: data.name,
      },
      passwordValidationRules: {
        minLength: 8,
        requireMixedCase: true,
        requireNumber: true,
        requireNonAlpha: true,
        maxLength: 256,
      },
      userDeletePolicy: {
        unverified: { enabled: true, numberOfDaysToRetain: 7 },
      },
    },
  });
  return response.response.tenant;
}

// Create application within tenant
export async function createAppForTenant(tenantId: string, appName: string) {
  const tenantClient = new FusionAuthClient(process.env.FUSIONAUTH_API_KEY!, process.env.FUSIONAUTH_URL!, tenantId);

  const response = await tenantClient.createApplication(undefined, {
    application: {
      name: appName,
      tenantId,
      oauthConfiguration: {
        enabledGrants: ['authorization_code', 'refresh_token'],
        generateRefreshTokens: true,
        requireClientAuthentication: true,
      },
      roles: [
        { name: 'admin' },
        { name: 'editor' },
        { name: 'user' },
      ],
    },
  });
  return response.response.application;
}
```

---

## 10. Passwordless Login

```typescript
// Start passwordless login (magic link via email)
export async function startPasswordlessLogin(email: string) {
  const response = await fusionAuthClient.startPasswordlessLogin({
    applicationId: APP_ID,
    loginId: email,
  });
  return response.response.code; // Code sent via email
}

// Complete passwordless login
export async function completePasswordlessLogin(code: string) {
  const response = await fusionAuthClient.passwordlessLogin({
    code,
    applicationId: APP_ID,
  });
  return {
    accessToken: response.response.token,
    refreshToken: response.response.refreshToken,
    user: response.response.user,
  };
}
```

---

## 11. Custom Theme (Login UI)

```html
<!-- FusionAuth supports custom Freemarker themes -->
<!-- templates/oauth2Authorize.ftl -->
<!DOCTYPE html>
<html>
<head>
  <title>Login - MyApp</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Inter', sans-serif; min-height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
    .login-card { background: white; border-radius: 24px; padding: 48px; box-shadow: 0 25px 60px rgba(0,0,0,0.15); width: 100%; max-width: 420px; }
    .login-card h1 { font-size: 28px; color: #1e293b; margin-bottom: 8px; }
    .login-card p { color: #64748b; margin-bottom: 32px; }
    .form-group { margin-bottom: 20px; }
    .form-group label { display: block; font-weight: 600; margin-bottom: 6px; color: #334155; font-size: 14px; }
    .form-group input { width: 100%; padding: 12px 16px; border: 2px solid #e2e8f0; border-radius: 12px; font-size: 16px; transition: border-color 0.2s; outline: none; }
    .form-group input:focus { border-color: #6366f1; }
    .btn-primary { width: 100%; padding: 14px; background: linear-gradient(135deg, #6366f1, #8b5cf6); color: white; border: none; border-radius: 12px; font-size: 16px; font-weight: 600; cursor: pointer; transition: transform 0.2s; }
    .btn-primary:hover { transform: translateY(-1px); }
    .social-login { margin-top: 24px; text-align: center; }
    .social-btn { display: inline-flex; align-items: center; gap: 8px; padding: 10px 20px; border: 2px solid #e2e8f0; border-radius: 12px; background: white; cursor: pointer; margin: 4px; }
    .divider { text-align: center; margin: 24px 0; color: #94a3b8; position: relative; }
    .divider::before, .divider::after { content: ''; position: absolute; top: 50%; width: 40%; height: 1px; background: #e2e8f0; }
    .divider::before { left: 0; } .divider::after { right: 0; }
    .error { background: #fef2f2; color: #dc2626; padding: 12px; border-radius: 8px; margin-bottom: 16px; font-size: 14px; }
  </style>
</head>
<body>
  <div class="login-card">
    <h1>Welcome back</h1>
    <p>Sign in to your MyApp account</p>

    [#if errorMessages?has_content]
      <div class="error">[#list errorMessages as m]${m}[/#list]</div>
    [/#if]

    <form action="${request.contextPath}/oauth2/authorize" method="POST">
      <input type="hidden" name="client_id" value="${client_id}"/>
      <input type="hidden" name="response_type" value="${response_type!'code'}"/>
      <input type="hidden" name="redirect_uri" value="${redirect_uri}"/>
      <input type="hidden" name="scope" value="${scope!'openid email profile'}"/>
      <input type="hidden" name="state" value="${state!''}"/>

      <div class="form-group">
        <label for="loginId">Email</label>
        <input type="email" id="loginId" name="loginId" placeholder="you@example.com" required autofocus/>
      </div>
      <div class="form-group">
        <label for="password">Password</label>
        <input type="password" id="password" name="password" placeholder="••••••••" required/>
      </div>
      <button type="submit" class="btn-primary">Sign In</button>
    </form>

    [#if identityProviders?has_content]
      <div class="divider">or</div>
      <div class="social-login">
        [#list identityProviders as ip]
          <a href="${request.contextPath}/oauth2/authorize?identityProviderId=${ip.id}&client_id=${client_id}&response_type=${response_type}&redirect_uri=${redirect_uri}" class="social-btn">
            ${ip.buttonText!'Continue with ${ip.name}'}
          </a>
        [/#list]
      </div>
    [/#if]

    <p style="text-align:center;margin-top:24px;font-size:14px;">
      <a href="${request.contextPath}/password/forgot?client_id=${client_id}" style="color:#6366f1;">Forgot password?</a>
    </p>
  </div>
</body>
</html>
```

---

## 12. Environment Variables

```bash
# .env
FUSIONAUTH_URL=http://localhost:9011
FUSIONAUTH_API_KEY=your-super-secret-api-key
FUSIONAUTH_APP_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
FUSIONAUTH_CLIENT_SECRET=your-client-secret
FUSIONAUTH_TENANT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
FUSIONAUTH_ISSUER=myapp.com
FUSIONAUTH_WEBHOOK_SECRET=your-webhook-secret

# Social Login
GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-xxx
GITHUB_CLIENT_ID=xxx
GITHUB_CLIENT_SECRET=xxx
APPLE_BUNDLE_ID=com.myapp.ios
APPLE_SERVICES_ID=com.myapp.login
APPLE_TEAM_ID=XXXXXXXXXX
APPLE_KEY_ID=XXXXXXXXXX
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **PKCE** | Always use PKCE for authorization code flow |
| **JWT verification** | Verify with JWKS endpoint, cache keys |
| **Kickstart** | Automate setup with kickstart.json |
| **Webhooks** | Verify signature, handle idempotently |
| **Roles** | Application-level roles (admin, editor, user) |
| **MFA** | Enable TOTP + email/SMS as backup |
| **Multi-tenant** | Separate tenant per customer/org |
| **Social login** | Google, Apple, GitHub, Facebook |
| **Passwordless** | Magic link for password-free login |
| **Password policy** | Enforce length, complexity, breach detection |
| **Token lifecycle** | Short access (1hr), long refresh (30d) |
| **Custom theme** | Brand the login page with Freemarker |
| **API key security** | Restrict API key permissions |
| **Rate limiting** | Built-in brute force protection |
| **Audit log** | Track login events via webhooks |

---

## SDK Support Matrix

| Platform | SDK / Quickstart | Package |
|----------|-----------------|---------|
| **Node.js** | TypeScript Client | `@fusionauth/typescript-client` |
| **React** | React SDK | `@fusionauth/react-sdk` |
| **Angular** | Angular SDK | `@fusionauth/angular-sdk` |
| **Vue** | Vue SDK | `@fusionauth/vue-sdk` |
| **Next.js** | NextAuth + FusionAuth | `next-auth` |
| **Python** | Python Client | `fusionauth-client` |
| **Java** | Java Client | `io.fusionauth:fusionauth-java-client` |
| **Go** | Go Client | `github.com/FusionAuth/go-client` |
| **PHP** | PHP Client | `fusionauth/fusionauth-client` |
| **.NET Core** | .NET Client | `FusionAuth.Client` |
| **Ruby** | Ruby Client | `fusionauth_client` |
| **Flutter** | Dart Client | `fusionauth_dart_client` |
| **iOS/Android** | AppAuth + FusionAuth | Native OIDC |

---

## Rules Integration
- **Setup**: Docker Compose with Kickstart automation
- **OAuth**: Authorization Code + PKCE flow
- **JWT**: JWKS-based verification middleware
- **RBAC**: Role-based middleware (requireRole)
- **Users**: Full CRUD via TypeScript client
- **MFA**: TOTP authenticator + email/SMS
- **Webhooks**: Signed event handlers (user, login, registration)
- **Social**: Google, GitHub, Apple identity providers
- **Multi-tenant**: Per-customer tenant isolation
- **Theme**: Custom Freemarker login UI
- **Passwordless**: Magic link email authentication
