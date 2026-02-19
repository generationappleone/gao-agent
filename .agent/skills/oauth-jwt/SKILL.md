---
name: OAuth 2.0 / JWT
description: Skill for implementing authentication with OAuth 2.0 and JWT — covering authorization flows, access/refresh tokens, JWT structure, token validation, PKCE, scopes, and secure implementation patterns.
---

# OAuth 2.0 / JWT Skill

## Overview
OAuth 2.0 is the industry standard for authorization. JWT (JSON Web Token) is commonly used as the token format. This skill covers secure implementation patterns.

**References**:
- [RFC 6749 - OAuth 2.0](https://datatracker.ietf.org/doc/html/rfc6749)
- [RFC 7519 - JWT](https://datatracker.ietf.org/doc/html/rfc7519)

## JWT Structure
```
Header.Payload.Signature

eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.    // Header (base64url)
eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6... // Payload (base64url)
SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV...    // Signature
```

```json
// Header
{ "alg": "RS256", "typ": "JWT", "kid": "key-id-1" }

// Payload (claims)
{
  "sub": "user-uuid-123",        // Subject (user ID)
  "iss": "https://auth.example.com", // Issuer
  "aud": "https://api.example.com",  // Audience
  "exp": 1708300800,             // Expiration (Unix timestamp)
  "iat": 1708297200,             // Issued at
  "jti": "unique-token-id",     // JWT ID (for revocation)
  "role": "admin",              // Custom claim
  "scope": "read write"         // Scopes
}
```

## Token Generation (Node.js)
```typescript
import jwt from "jsonwebtoken";

// ✅ Use RS256 (asymmetric) for production
const privateKey = fs.readFileSync("private.pem");
const publicKey = fs.readFileSync("public.pem");

function generateTokens(user: User) {
  const accessToken = jwt.sign(
    { sub: user.id, role: user.role, scope: "read write" },
    privateKey,
    { algorithm: "RS256", expiresIn: "15m", issuer: "https://auth.example.com", audience: "https://api.example.com" }
  );

  const refreshToken = jwt.sign(
    { sub: user.id, jti: crypto.randomUUID(), type: "refresh" },
    privateKey,
    { algorithm: "RS256", expiresIn: "7d" }
  );

  return { accessToken, refreshToken };
}

function verifyToken(token: string) {
  return jwt.verify(token, publicKey, {
    algorithms: ["RS256"],
    issuer: "https://auth.example.com",
    audience: "https://api.example.com",
  });
}
```

## OAuth 2.0 Flows

### Authorization Code + PKCE (Recommended for SPAs)
```typescript
// 1. Generate PKCE verifier & challenge
const codeVerifier = crypto.randomBytes(32).toString("base64url");
const codeChallenge = crypto.createHash("sha256").update(codeVerifier).digest("base64url");

// 2. Redirect to authorization server
const authUrl = `https://auth.example.com/authorize?response_type=code&client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&scope=openid profile email&state=${state}&code_challenge=${codeChallenge}&code_challenge_method=S256`;

// 3. Exchange code for tokens (backend)
const tokenResponse = await fetch("https://auth.example.com/token", {
  method: "POST",
  headers: { "Content-Type": "application/x-www-form-urlencoded" },
  body: new URLSearchParams({
    grant_type: "authorization_code",
    code: authorizationCode,
    redirect_uri: REDIRECT_URI,
    client_id: CLIENT_ID,
    code_verifier: codeVerifier,
  }),
});
```

### Refresh Token Flow
```typescript
async function refreshAccessToken(refreshToken: string) {
  const payload = verifyToken(refreshToken);

  // Check if token is revoked
  const isRevoked = await db.revokedTokens.findUnique({ where: { jti: payload.jti } });
  if (isRevoked) throw new Error("Token revoked");

  // Rotate refresh token (one-time use)
  await db.revokedTokens.create({ data: { jti: payload.jti } });

  return generateTokens(await db.user.findUnique({ where: { id: payload.sub } }));
}
```

## Middleware (Express)
```typescript
function authenticate(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) return res.status(401).json({ error: "Missing token" });

  try {
    const token = header.slice(7);
    req.user = verifyToken(token);
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) return res.status(401).json({ error: "Token expired" });
    return res.status(401).json({ error: "Invalid token" });
  }
}

function authorize(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!roles.includes(req.user.role)) return res.status(403).json({ error: "Forbidden" });
    next();
  };
}

// Usage
app.get("/admin", authenticate, authorize("admin"), adminHandler);
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **RS256** | Use asymmetric signing (RS256/ES256), not HS256 |
| **Short-lived access** | Access tokens: 15 minutes max |
| **Refresh rotation** | Single-use refresh tokens with rotation |
| **PKCE** | Always use for public clients (SPA, mobile) |
| **HttpOnly cookies** | Store refresh tokens in HttpOnly cookies |
| **Validate all claims** | Check `iss`, `aud`, `exp`, `sub` on every request |
| **Token revocation** | Maintain revocation list or use short expiry |
| **Scopes** | Use fine-grained scopes for authorization |
| **HTTPS only** | Never transmit tokens over HTTP |
| **No sensitive data** | Never put passwords/PII in JWT payload |
