---
name: Secure Code Patterns
description: Skill for implementing secure coding patterns — covering input validation, output encoding, parameterized queries, secure file handling, cryptography usage, JWT security, and framework-specific security patterns.
---

# Secure Code Patterns Skill

## Overview
Secure coding prevents vulnerabilities by applying patterns for input validation, output encoding, parameterized queries, CSRF protection, secure authentication, and cryptographic operations. Defense-in-depth applies multiple security layers.

**References**:
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [Node.js Security Best Practices](https://nodejs.org/en/learn/getting-started/security-best-practices)

---

## Input Validation (Zod)

```typescript
import { z } from 'zod';

const createUserSchema = z.object({
  name: z.string().min(2).max(100).trim(),
  email: z.string().email().toLowerCase(),
  password: z.string().min(8).regex(/[A-Z]/).regex(/[0-9]/).regex(/[!@#$%^&*]/),
  role: z.enum(['user', 'editor']).default('user'),
});

// Middleware
export function validate(schema: z.ZodSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) return res.status(400).json({ errors: result.error.flatten().fieldErrors });
    req.body = result.data;
    next();
  };
}

app.post('/api/users', validate(createUserSchema), createUserHandler);
```

---

## Password Hashing

```typescript
import bcrypt from 'bcrypt';

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 12);
}

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
```

---

## Parameterized Queries

```typescript
// SAFE: Parameterized query
const user = await prisma.user.findUnique({ where: { email } });
const result = await db.query('SELECT * FROM users WHERE email = $1', [email]);

// UNSAFE: String concatenation (NEVER DO THIS)
// const result = await db.query(`SELECT * FROM users WHERE email = '${email}'`);
```

---

## CSRF Protection

```typescript
import csrf from 'csurf';
app.use(csrf({ cookie: { httpOnly: true, sameSite: 'strict', secure: true } }));

// Send token to frontend
app.get('/api/csrf-token', (req, res) => res.json({ token: req.csrfToken() }));
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Input validation** | Zod schemas for all input |
| **Parameterized queries** | Never concatenate user input in SQL |
| **Password hashing** | bcrypt with cost factor 12+ |
| **CSRF** | Token-based CSRF protection |
| **Output encoding** | Escape HTML/JS output |
| **Rate limiting** | Limit auth/sensitive endpoints |
| **HttpOnly cookies** | Prevent XSS cookie theft |
| **CORS** | Restrict allowed origins |
| **Helmet** | Security headers middleware |
| **Dependencies** | Regular `npm audit` checks |

---

## Rules Integration
- **Validation**: Zod at API boundary
- **Auth**: bcrypt hashing, CSRF tokens
- **Queries**: Parameterized/ORM only
- **Headers**: Helmet + CORS + rate limiting
