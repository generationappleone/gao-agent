---
name: Secure Code Patterns
description: Skill for implementing secure coding patterns — covering input validation, output encoding, parameterized queries, secure file handling, cryptography usage, JWT security, and framework-specific security patterns.
---

# Secure Code Patterns Skill

## Purpose
This skill provides **concrete, copy-paste-ready secure code patterns** organized by vulnerability category. It translates OWASP guidelines into actionable code for TypeScript/JavaScript, PHP/Laravel, Python, Go, and Java/Spring.

---

## 1. Input Validation

### Principle
**Validate ALL input at the server boundary.** Frontend validation is UX, not security.

### TypeScript/Node.js (with Zod)
```typescript
import { z } from 'zod';

// Define schema
const createUserSchema = z.object({
  email: z.string().email().max(255),
  name: z.string().min(1).max(100).regex(/^[a-zA-Z\s\-']+$/),
  age: z.number().int().min(13).max(120),
  role: z.enum(['user', 'admin', 'moderator']),
  website: z.string().url().optional(),
});

// Validate in controller
async function createUser(req: Request, res: Response) {
  const result = createUserSchema.safeParse(req.body);
  if (!result.success) {
    return res.status(400).json({
      error: 'Validation failed',
      details: result.error.flatten(),
    });
  }
  const validatedData = result.data; // Type-safe & validated
  // ...proceed with validated data
}
```

### PHP/Laravel (FormRequest)
```php
class CreateUserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'email' => ['required', 'email:rfc,dns', 'max:255', 'unique:users'],
            'name' => ['required', 'string', 'min:1', 'max:100', 'regex:/^[a-zA-Z\s\-\']+$/'],
            'age' => ['required', 'integer', 'min:13', 'max:120'],
            'role' => ['required', 'in:user,admin,moderator'],
            'website' => ['nullable', 'url', 'max:500'],
        ];
    }
}
```

### Python/FastAPI (Pydantic)
```python
from pydantic import BaseModel, EmailStr, Field, field_validator
import re

class CreateUserRequest(BaseModel):
    email: EmailStr
    name: str = Field(min_length=1, max_length=100)
    age: int = Field(ge=13, le=120)
    role: str = Field(pattern=r'^(user|admin|moderator)$')

    @field_validator('name')
    @classmethod
    def validate_name(cls, v: str) -> str:
        if not re.match(r"^[a-zA-Z\s\-']+$", v):
            raise ValueError('Name contains invalid characters')
        return v.strip()
```

---

## 2. Output Encoding

### Principle
**Encode output based on context** (HTML, JavaScript, URL, CSS, SQL).

### HTML Context
```typescript
// ✅ Use framework auto-escaping (React, Vue auto-escape by default)
// React: <div>{userInput}</div> — auto-escaped

// ❌ NEVER use dangerouslySetInnerHTML with user input
// ❌ NEVER use v-html with user input

// If you MUST render HTML, sanitize first:
import DOMPurify from 'dompurify';
const sanitized = DOMPurify.sanitize(userHtml, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
  ALLOWED_ATTR: ['href', 'target'],
});
```

### URL Context
```typescript
// ✅ Encode user input in URLs
const searchUrl = `/search?q=${encodeURIComponent(userQuery)}`;

// ❌ Never interpolate directly
const searchUrl = `/search?q=${userQuery}`; // XSS risk
```

### JSON Context
```typescript
// ✅ Use JSON.stringify (auto-escapes)
res.json({ message: userInput }); // Safe

// ❌ Never build JSON manually with string concatenation
const json = `{"message": "${userInput}"}`; // Injection risk
```

---

## 3. Parameterized Queries

### Principle
**NEVER concatenate user input into SQL.** Always use parameterized queries or ORM.

### Node.js (Prisma — Recommended)
```typescript
// ✅ Prisma (always parameterized)
const user = await prisma.user.findUnique({
  where: { email: validatedEmail },
});

// ✅ Raw query with parameters (when needed)
const users = await prisma.$queryRaw`
  SELECT * FROM users WHERE email = ${email} AND status = ${status}
`;

// ❌ NEVER do this
const users = await prisma.$queryRawUnsafe(
  `SELECT * FROM users WHERE email = '${email}'`
);
```

### PHP/Laravel (Eloquent)
```php
// ✅ Eloquent (always parameterized)
$user = User::where('email', $request->email)->first();

// ✅ Query Builder with bindings
$users = DB::select('SELECT * FROM users WHERE email = ?', [$email]);

// ❌ NEVER do this
$users = DB::select("SELECT * FROM users WHERE email = '$email'");
```

### Python (SQLAlchemy)
```python
# ✅ ORM (always parameterized)
user = session.query(User).filter(User.email == email).first()

# ✅ Raw with parameters
result = session.execute(
    text("SELECT * FROM users WHERE email = :email"),
    {"email": email}
)

# ❌ NEVER do this
result = session.execute(f"SELECT * FROM users WHERE email = '{email}'")
```

---

## 4. Authentication & Session Security

### JWT Security
```typescript
import jwt from 'jsonwebtoken';

// ✅ Secure JWT configuration
const ACCESS_TOKEN_CONFIG = {
  algorithm: 'HS256' as const,      // Or RS256 for asymmetric
  expiresIn: '15m',                  // Short-lived access tokens
  issuer: 'myapp.com',
  audience: 'myapp.com',
};

const REFRESH_TOKEN_CONFIG = {
  algorithm: 'HS256' as const,
  expiresIn: '7d',                   // Longer-lived refresh tokens
  issuer: 'myapp.com',
};

// ✅ Verify with explicit algorithm (prevent algorithm confusion)
function verifyAccessToken(token: string): JwtPayload {
  return jwt.verify(token, process.env.JWT_SECRET!, {
    algorithms: ['HS256'],           // MUST specify allowed algorithms
    issuer: 'myapp.com',
    audience: 'myapp.com',
  }) as JwtPayload;
}
```

### Session Security
```typescript
// ✅ Secure session configuration
app.use(session({
  secret: process.env.SESSION_SECRET!, // Min 32 chars
  name: '__session',                    // Custom name (not 'connect.sid')
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,                     // No JavaScript access
    secure: process.env.NODE_ENV === 'production', // HTTPS only in prod
    sameSite: 'lax',                    // CSRF protection
    maxAge: 24 * 60 * 60 * 1000,       // 24 hours
    domain: '.myapp.com',              // Scope to domain
  },
}));
```

---

## 5. File Upload Security

```typescript
import multer from 'multer';
import path from 'path';
import crypto from 'crypto';

// ✅ Secure file upload configuration
const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

const upload = multer({
  storage: multer.diskStorage({
    destination: './uploads/temp',
    filename: (req, file, cb) => {
      // ✅ Generate random filename (prevent path traversal)
      const uniqueName = crypto.randomUUID() + path.extname(file.originalname);
      cb(null, uniqueName);
    },
  }),
  limits: {
    fileSize: MAX_FILE_SIZE,
    files: 5,
  },
  fileFilter: (req, file, cb) => {
    // ✅ Validate MIME type (not just extension)
    if (!ALLOWED_MIME_TYPES.includes(file.mimetype)) {
      cb(new Error('Invalid file type'));
      return;
    }
    // ✅ Validate extension matches MIME
    const ext = path.extname(file.originalname).toLowerCase();
    const validExtensions: Record<string, string[]> = {
      'image/jpeg': ['.jpg', '.jpeg'],
      'image/png': ['.png'],
      'image/webp': ['.webp'],
      'application/pdf': ['.pdf'],
    };
    if (!validExtensions[file.mimetype]?.includes(ext)) {
      cb(new Error('Extension does not match file type'));
      return;
    }
    cb(null, true);
  },
});
```

---

## 6. Security Headers

```typescript
import helmet from 'helmet';

// ✅ Comprehensive security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"], // Minimize unsafe-inline
      imgSrc: ["'self'", 'data:', 'https:'],
      connectSrc: ["'self'"],
      fontSrc: ["'self'", 'https://fonts.gstatic.com'],
      objectSrc: ["'none'"],
      frameAncestors: ["'none'"],
      baseUri: ["'self'"],
      formAction: ["'self'"],
    },
  },
  hsts: { maxAge: 31536000, includeSubDomains: true, preload: true },
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  frameguard: { action: 'deny' },
  noSniff: true,
  xssFilter: true,
}));

// ✅ CORS configuration
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400,
}));
```

---

## 7. Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

// ✅ General API rate limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,                   // 100 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests, please try again later' },
});

// ✅ Stricter rate limiting for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,                     // 5 attempts per 15 minutes
  skipSuccessfulRequests: true,
  message: { error: 'Too many login attempts, please try again later' },
});

app.use('/api/', apiLimiter);
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);
```

---

## Anti-Patterns — What NOT to Do

```typescript
// ❌ eval with user input
eval(req.body.expression);

// ❌ String concatenation in SQL
db.query(`SELECT * FROM users WHERE id = '${req.params.id}'`);

// ❌ innerHTML with user input
element.innerHTML = userInput;

// ❌ Hardcoded secrets
const API_KEY = 'sk_live_abc123def456';

// ❌ Wildcard CORS
app.use(cors({ origin: '*' }));

// ❌ Logging sensitive data
console.log('User logged in:', { email, password });

// ❌ Using MD5 for passwords
const hash = md5(password);

// ❌ No algorithm restriction in JWT verify
jwt.verify(token, secret); // Allows algorithm confusion attacks
```

---

## Integration with Rules
- `rules/developer-security.md` — All 4 security layers
- `rules/production-code-standards.md` — Type-safe, no `any`, validate at boundaries
- `rules/solid-principles.md` — SRP for security modules
