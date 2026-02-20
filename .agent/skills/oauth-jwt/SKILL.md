---
name: OAuth 2.0 / JWT
description: Skill for implementing authentication with OAuth 2.0 and JWT — covering authorization flows, access/refresh tokens, JWT structure, token validation, PKCE, scopes, and secure implementation patterns.
---

# OAuth 2.0 / JWT Skill

## Overview
OAuth 2.0 is the industry-standard authorization framework. JWT (JSON Web Tokens) is the token format used for stateless authentication. This skill covers access/refresh token pairs, JWT signing/verification, middleware, token rotation, and secure patterns.

**References**:
- [JWT.io](https://jwt.io/)
- [OAuth 2.0 RFC 6749](https://tools.ietf.org/html/rfc6749)
- [jose library](https://github.com/panva/jose)

---

## JWT Service

```typescript
// src/services/jwt.service.ts
import { SignJWT, jwtVerify } from 'jose';

const ACCESS_SECRET = new TextEncoder().encode(process.env.JWT_ACCESS_SECRET!);
const REFRESH_SECRET = new TextEncoder().encode(process.env.JWT_REFRESH_SECRET!);

export async function generateTokens(user: { id: string; email: string; role: string }) {
  const accessToken = await new SignJWT({ sub: user.id, email: user.email, role: user.role })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('1h')
    .setIssuer('myapp')
    .sign(ACCESS_SECRET);

  const refreshToken = await new SignJWT({ sub: user.id })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('30d')
    .setIssuer('myapp')
    .sign(REFRESH_SECRET);

  return { accessToken, refreshToken };
}

export async function verifyAccessToken(token: string) {
  const { payload } = await jwtVerify(token, ACCESS_SECRET, { issuer: 'myapp' });
  return payload as { sub: string; email: string; role: string };
}

export async function verifyRefreshToken(token: string) {
  const { payload } = await jwtVerify(token, REFRESH_SECRET, { issuer: 'myapp' });
  return payload as { sub: string };
}
```

---

## Auth Middleware

```typescript
// src/middleware/auth.middleware.ts
export async function authMiddleware(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) return res.status(401).json({ error: 'No token provided' });

  try {
    const payload = await verifyAccessToken(header.slice(7));
    req.user = { id: payload.sub, email: payload.email, role: payload.role };
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

export function requireRole(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!roles.includes(req.user.role)) return res.status(403).json({ error: 'Forbidden' });
    next();
  };
}
```

---

## Auth Routes

```typescript
// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const user = await db.user.findUnique({ where: { email } });
  if (!user || !(await bcrypt.compare(password, user.password))) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  const tokens = await generateTokens(user);
  res.json({ ...tokens, user: { id: user.id, email: user.email, role: user.role } });
});

// POST /api/auth/refresh
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;
    const payload = await verifyRefreshToken(refreshToken);
    const user = await db.user.findUnique({ where: { id: payload.sub } });
    if (!user) return res.status(401).json({ error: 'User not found' });
    const tokens = await generateTokens(user);
    res.json(tokens);
  } catch {
    return res.status(401).json({ error: 'Invalid refresh token' });
  }
});
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Access token** | Short-lived (15min–1hr), contains user claims |
| **Refresh token** | Long-lived (30d), stored securely |
| **jose library** | Modern, edge-compatible JWT library |
| **HS256** | Symmetric signing for single-service apps |
| **RS256** | Asymmetric signing for microservices |
| **Issuer** | Set and verify `iss` claim |
| **Rotation** | Issue new refresh token on each refresh |
| **Revocation** | Blacklist tokens in Redis on logout |
| **PKCE** | Use for public clients (SPA, mobile) |
| **Scopes** | Fine-grained permissions via token claims |

---

## Rules Integration
- **Tokens**: Access + refresh pair with jose library
- **Middleware**: Bearer token verification + RBAC
- **Routes**: Login/refresh with bcrypt password check
- **Security**: Short-lived access, rotatable refresh tokens
