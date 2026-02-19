# 🛡️ Developer Security Platform — Mandatory Security Rule

> **Severity:** CRITICAL  
> **Scope:** All code, dependencies, containers, and Infrastructure as Code (IaC) written or modified by the agent  
> **Objective:** Minimize breach risk by enforcing secure-by-default practices

---

## Overview

The agent **MUST** enforce security across **4 layers** whenever writing or modifying code:

1. **🔐 Secure Code** — Code free from common vulnerabilities
2. **📦 Secure Dependencies** — Verified and up-to-date dependencies
3. **🐳 Secure Containers** — Properly hardened container images
4. **🏗️ Secure IaC** — Infrastructure as Code that does not expose attack surfaces

---

## 1. 🔐 Secure Code

### 1.1 Input Validation & Sanitization

#### ✅ MUST do:
- **Validate ALL inputs** from users, APIs, files, environment variables, and external sources
- Use **allowlist** (whitelist) validation, not blocklist (blacklist)
- Apply **parameterized queries / prepared statements** for all database queries
- Sanitize output based on context (HTML encoding, URL encoding, JS escaping)
- Validate data type, length, range, and format before processing

#### ❌ MUST NOT do:
- Use string concatenation for SQL queries (`"SELECT * FROM users WHERE id = " + userId`)
- Accept and process input without validation
- Use `eval()`, `exec()`, `Function()`, or dynamic code execution with user input
- Use `innerHTML` with unsanitized data

### 💡 Example: Complete Input Validation Pipeline

```typescript
// ❌ FORBIDDEN: No validation, SQL injection, XSS vulnerable
app.post('/api/users/search', async (req, res) => {
  const { name, age, bio } = req.body;
  const query = `SELECT * FROM users WHERE name = '${name}' AND age = ${age}`;
  const users = await db.query(query);
  res.send(`<div>${bio}</div>`);  // XSS!
});

app.get('/api/files', (req, res) => {
  const filePath = req.query.path;
  const content = fs.readFileSync(filePath);  // Path traversal!
  res.send(content);
});
```

```typescript
// ✅ REQUIRED: Full validation, parameterized queries, sanitized output

import { z } from 'zod';
import { escape } from 'html-escaper';
import path from 'path';

// --- Step 1: Define schema with strict validation ---
const UserSearchSchema = z.object({
  name: z.string().min(1).max(100).regex(/^[a-zA-Z\s'-]+$/),
  age: z.number().int().min(0).max(150),
  bio: z.string().max(500).optional(),
});

// --- Step 2: Validate input, parameterize query, sanitize output ---
app.post('/api/users/search', async (req, res) => {
  // Validate input against schema
  const parsed = UserSearchSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: 'Invalid input', details: parsed.error.issues });
  }

  const { name, age, bio } = parsed.data;

  // Parameterized query — prevents SQL injection
  const users = await db.query(
    'SELECT id, name, age FROM users WHERE name = $1 AND age = $2',
    [name, age]
  );

  // Sanitize output — prevents XSS
  const safeBio = bio ? escape(bio) : '';

  res.json({ users: users.rows, bio: safeBio });
});

// --- Step 3: Prevent path traversal ---
const ALLOWED_BASE_DIR = '/app/public/uploads';

app.get('/api/files', (req, res) => {
  const requestedFile = req.query.path as string;
  if (!requestedFile) return res.status(400).json({ error: 'Path required' });

  // Normalize and validate path
  const resolvedPath = path.resolve(ALLOWED_BASE_DIR, requestedFile);
  if (!resolvedPath.startsWith(ALLOWED_BASE_DIR)) {
    return res.status(403).json({ error: 'Access denied' });  // Block path traversal
  }

  if (!fs.existsSync(resolvedPath)) {
    return res.status(404).json({ error: 'File not found' });
  }

  res.sendFile(resolvedPath);
});
```

```python
# ✅ REQUIRED: Python — Input validation with Pydantic

from pydantic import BaseModel, Field, validator
from uuid import UUID
import re

class CreateUserRequest(BaseModel):
    email: str = Field(..., max_length=255)
    username: str = Field(..., min_length=3, max_length=30)
    age: int = Field(..., ge=13, le=150)
    bio: str = Field(default="", max_length=1000)

    @validator('email')
    def validate_email(cls, v):
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(pattern, v):
            raise ValueError('Invalid email format')
        return v.lower()

    @validator('username')
    def validate_username(cls, v):
        if not re.match(r'^[a-zA-Z0-9_]+$', v):
            raise ValueError('Username must contain only alphanumeric characters and underscores')
        return v

# Usage in endpoint
@router.post("/users")
async def create_user(request: CreateUserRequest, db: AsyncSession = Depends(get_db)):
    # Input is already validated by Pydantic
    user = User(
        id=uuid7(),
        email=request.email,
        username=request.username,
        age=request.age,
        bio=bleach.clean(request.bio),  # Additional HTML sanitization
    )
    db.add(user)
    await db.commit()
    return UserResponse.from_orm(user)
```

### 1.2 Authentication & Authorization

#### ✅ MUST do:
- Use **bcrypt/scrypt/argon2** for password hashing (minimum cost factor 10)
- Implement **rate limiting** on login endpoints and sensitive operations
- Use **JWT** with reasonable expiration times (access: 15-30 min, refresh: 7-30 days)
- Validate authorization at **every endpoint/handler**, not just in middleware
- Implement the **principle of least privilege** — grant only the minimum required access

#### ❌ MUST NOT do:
- Store passwords in plain text or reversible encoding (Base64, MD5, SHA1)
- Hardcode credentials, API keys, or secrets in source code
- Rely solely on client-side validation for authorization
- Use predictable session IDs

### 💡 Example: Complete Auth System

```typescript
// ❌ FORBIDDEN: Insecure authentication
class AuthController {
  async login(req: Request, res: Response) {
    const { email, password } = req.body;
    const user = await db.query(`SELECT * FROM users WHERE email = '${email}'`);  // SQL injection!

    if (user.password === password) {  // ❌ Plain text comparison!
      const token = jwt.sign(
        { userId: user.id, role: user.role },
        'my-secret-key',              // ❌ Hardcoded secret!
        { expiresIn: '365d' }         // ❌ Token never expires!
      );
      res.json({ token });
    }
  }
}

// Middleware with no per-route authorization
app.use(authMiddleware);  // ❌ Same level of access for all authenticated users!
app.get('/admin/users', getUsers);
app.delete('/admin/users/:id', deleteUser);
```

```typescript
// ✅ REQUIRED: Secure authentication system

// --- services/auth.service.ts ---
import argon2 from 'argon2';
import { randomUUID } from 'crypto';

class AuthService {
  constructor(
    private readonly userRepo: UserRepository,
    private readonly tokenService: TokenService,
    private readonly rateLimiter: RateLimiter,
    private readonly logger: Logger,
  ) {}

  async login(email: string, password: string, ip: string): Promise<AuthTokens> {
    // Rate limiting per IP and email
    await this.rateLimiter.checkLimit(`login:ip:${ip}`, { maxAttempts: 10, windowMinutes: 15 });
    await this.rateLimiter.checkLimit(`login:email:${email}`, { maxAttempts: 5, windowMinutes: 15 });

    const user = await this.userRepo.findByEmail(email);
    if (!user) {
      // Use constant-time comparison to prevent timing attacks
      await argon2.hash('dummy-password');  // Burn same CPU time
      throw new UnauthorizedError('Invalid credentials');
    }

    // Argon2 password verification
    const isValid = await argon2.verify(user.passwordHash, password);
    if (!isValid) {
      this.logger.warn('Failed login attempt', { email, ip });
      throw new UnauthorizedError('Invalid credentials');
    }

    // Generate short-lived access token + long-lived refresh token
    const accessToken = this.tokenService.generateAccessToken({
      sub: user.id,
      role: user.role,
      permissions: user.permissions,
    });
    const refreshToken = this.tokenService.generateRefreshToken(user.id);

    this.logger.info('Successful login', { userId: user.id, ip });
    return { accessToken, refreshToken };
  }
}

// --- services/token.service.ts ---
class TokenService {
  constructor(private readonly config: TokenConfig) {}

  generateAccessToken(payload: AccessTokenPayload): string {
    return jwt.sign(payload, this.config.accessSecret, {
      expiresIn: '15m',          // Short-lived!
      issuer: 'my-app',
      audience: 'my-app-api',
    });
  }

  generateRefreshToken(userId: string): string {
    return jwt.sign(
      { sub: userId, jti: randomUUID() },  // Unique token ID for revocation
      this.config.refreshSecret,
      { expiresIn: '7d' },
    );
  }
}

// --- middleware/authorization.middleware.ts ---
// Role-based + permission-based authorization
function authorize(requiredPermissions: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = req.user;  // Set by authentication middleware
    if (!user) return res.status(401).json({ error: 'Authentication required' });

    const hasPermission = requiredPermissions.every(p => user.permissions.includes(p));
    if (!hasPermission) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    next();
  };
}

// --- routes — per-route authorization ---
app.get('/api/admin/users', authorize(['users:read']), adminController.listUsers);
app.delete('/api/admin/users/:id', authorize(['users:delete']), adminController.deleteUser);
app.get('/api/profile', authorize(['profile:read']), userController.getProfile);
```

```python
# ✅ REQUIRED: Python — Password hashing with argon2

import argon2

password_hasher = argon2.PasswordHasher(
    time_cost=3,        # Number of iterations
    memory_cost=65536,  # 64 MB memory usage
    parallelism=4,      # Number of parallel threads
)

# Hashing
hashed = password_hasher.hash("user_password_here")
# Result: $argon2id$v=19$m=65536,t=3,p=4$...

# Verification
try:
    password_hasher.verify(hashed, "user_password_here")
    # Check if rehash is needed (parameters changed)
    if password_hasher.check_needs_rehash(hashed):
        new_hash = password_hasher.hash("user_password_here")
        # Update stored hash in database
except argon2.exceptions.VerifyMismatchError:
    raise UnauthorizedException("Invalid credentials")
```

### 1.3 Sensitive Data Protection

#### ✅ MUST do:
- Store secrets in **environment variables** or a **secret manager** (Vault, AWS Secrets Manager, etc.)
- Use **`.env.example`** as a template — **NEVER** commit `.env` files containing secrets
- Ensure **`.gitignore`** covers all sensitive files (`.env`, `*.pem`, `*.key`, `credentials.json`)
- Encrypt sensitive data **at rest** and **in transit** (TLS 1.2+)
- Mask/redact sensitive data in logs (passwords, tokens, credit cards, SSN)

#### ❌ MUST NOT do:
- Hardcode API keys, passwords, tokens, or connection strings in source code
- Store secrets in comments, README, or documentation
- Log sensitive data in plain text
- Send sensitive data over HTTP (must use HTTPS)

### 💡 Example: Secrets & Environment Management

```typescript
// ❌ FORBIDDEN: Secrets everywhere!
const config = {
  db: {
    host: 'prod-db.company.com',
    password: 'SuperSecret123!',       // ❌ Hardcoded!
  },
  stripe: {
    secretKey: 'sk_live_abc123xyz',    // ❌ Hardcoded!
  },
  jwt: {
    secret: 'my-jwt-secret-key',      // ❌ Hardcoded!
  },
};

// Logging sensitive data
app.post('/api/payment', (req, res) => {
  console.log('Payment request:', JSON.stringify(req.body));  // ❌ Logs credit card data!
  console.log(`Processing with key: ${config.stripe.secretKey}`);  // ❌ Logs API key!
});
```

```typescript
// ✅ REQUIRED: Proper secret management

// --- config/env.validation.ts ---
import { z } from 'zod';

const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production']),
  PORT: z.coerce.number().default(3000),

  // Database
  DATABASE_URL: z.string().url(),

  // Auth
  JWT_ACCESS_SECRET: z.string().min(32),
  JWT_REFRESH_SECRET: z.string().min(32),

  // Payment
  STRIPE_SECRET_KEY: z.string().startsWith('sk_'),
  STRIPE_WEBHOOK_SECRET: z.string().startsWith('whsec_'),

  // External APIs
  SENDGRID_API_KEY: z.string().startsWith('SG.'),
});

// Validate at startup — fail fast if any secret is missing
export const env = EnvSchema.parse(process.env);

// --- .env.example (committed to repo — NO real values!) ---
// NODE_ENV=development
// PORT=3000
// DATABASE_URL=postgresql://user:password@localhost:5432/mydb
// JWT_ACCESS_SECRET=change-me-to-a-random-32-char-string
// JWT_REFRESH_SECRET=change-me-to-a-random-32-char-string
// STRIPE_SECRET_KEY=sk_test_xxxxx
// STRIPE_WEBHOOK_SECRET=whsec_xxxxx
// SENDGRID_API_KEY=SG.xxxxx

// --- .gitignore ---
// .env
// .env.local
// .env.production
// *.pem
// *.key

// --- utils/logger.ts — Automatic sensitive data redaction ---
const SENSITIVE_FIELDS = ['password', 'token', 'secret', 'apiKey', 'creditCard', 'ssn', 'cvv'];

function redactSensitiveData(obj: Record<string, unknown>): Record<string, unknown> {
  const redacted = { ...obj };
  for (const key of Object.keys(redacted)) {
    if (SENSITIVE_FIELDS.some(f => key.toLowerCase().includes(f.toLowerCase()))) {
      redacted[key] = '[REDACTED]';
    } else if (typeof redacted[key] === 'object' && redacted[key] !== null) {
      redacted[key] = redactSensitiveData(redacted[key] as Record<string, unknown>);
    }
  }
  return redacted;
}

// Usage
logger.info('Payment processed', redactSensitiveData({
  orderId: 'ord_123',
  amount: 99.99,
  creditCard: '4111111111111111',  // Logged as [REDACTED]
  cvv: '123',                     // Logged as [REDACTED]
}));
```

```python
# ✅ REQUIRED: Python — Pydantic Settings for secrets management

from pydantic_settings import BaseSettings
from pydantic import SecretStr, Field

class Settings(BaseSettings):
    # Database
    database_url: SecretStr  # SecretStr hides value in repr/logs
    
    # Auth
    jwt_secret: SecretStr = Field(..., min_length=32)
    
    # Payment
    stripe_secret_key: SecretStr

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()

# Accessing real value (only when needed)
real_db_url = settings.database_url.get_secret_value()

# In logs, SecretStr shows: database_url=SecretStr('**********')
print(settings)  # Safe — secrets are hidden!
```

### 1.4 Error Handling & Logging

#### ✅ MUST do:
- Use **generic error messages** for user-facing errors (do not expose stack traces)
- Log errors with sufficient detail for debugging **on the server-side only**
- Implement **structured logging** with appropriate levels (info, warn, error)
- Add **correlation IDs** for tracing requests across services

#### ❌ MUST NOT do:
- Expose stack traces, query errors, or internal paths to end users
- Log sensitive data (passwords, tokens, PII)
- Use `console.log` for production logging (use a proper logging library)

### 💡 Example: Secure Error Handling System

```typescript
// ❌ FORBIDDEN: Exposing internal details to the user
app.get('/api/users/:id', async (req, res) => {
  try {
    const user = await db.query(`SELECT * FROM users WHERE id = '${req.params.id}'`);
    res.json(user);
  } catch (error) {
    // ❌ Exposes database type, table structure, query, and stack trace!
    res.status(500).json({
      error: error.message,        // "relation 'users' does not exist"
      stack: error.stack,          // Full stack trace with file paths!
      query: error.query,          // The actual SQL query!
    });
  }
});
```

```typescript
// ✅ REQUIRED: Safe error handling with structured logging

import { randomUUID } from 'crypto';
import pino from 'pino';

const logger = pino({ level: 'info' });

// --- Custom error classes with error codes ---
class AppError extends Error {
  constructor(
    public readonly statusCode: number,
    public readonly code: string,
    public readonly userMessage: string,
    public readonly internalMessage?: string,
  ) {
    super(userMessage);
  }
}

class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(404, 'RESOURCE_NOT_FOUND', `${resource} not found`, `${resource} with id ${id} not found`);
  }
}

class ValidationError extends AppError {
  constructor(public readonly errors: string[]) {
    super(400, 'VALIDATION_ERROR', 'Invalid request data');
  }
}

// --- Correlation ID middleware ---
function correlationIdMiddleware(req: Request, res: Response, next: NextFunction) {
  req.correlationId = req.headers['x-correlation-id'] as string || randomUUID();
  res.setHeader('X-Correlation-ID', req.correlationId);
  next();
}

// --- Global error handler ---
function globalErrorHandler(err: Error, req: Request, res: Response, next: NextFunction) {
  const correlationId = req.correlationId;

  if (err instanceof AppError) {
    // Known application error — log at warn level
    logger.warn({
      correlationId,
      errorCode: err.code,
      message: err.internalMessage || err.userMessage,
      path: req.path,
      method: req.method,
    });

    return res.status(err.statusCode).json({
      error: { code: err.code, message: err.userMessage },
      correlationId,
    });
  }

  // Unknown error — log full details server-side, send generic message to user
  logger.error({
    correlationId,
    error: err.message,
    stack: err.stack,       // Stack trace logged server-side ONLY
    path: req.path,
    method: req.method,
    body: redactSensitiveData(req.body),
  });

  // User gets NO internal details
  res.status(500).json({
    error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' },
    correlationId,  // User can reference this for support
  });
}

app.use(correlationIdMiddleware);
app.use(globalErrorHandler);
```

### 1.5 Common Vulnerabilities Prevention (OWASP Top 10)

| Vulnerability | Mitigation |
|--------------|------------|
| **SQL Injection** | Parameterized queries, ORM with escaping |
| **XSS** | Output encoding, Content-Security-Policy header, sanitize HTML |
| **CSRF** | CSRF tokens, SameSite cookies, verify Origin header |
| **SSRF** | Allowlist for outbound URLs, block private IP ranges |
| **Path Traversal** | Normalize paths, validate against base directory |
| **Insecure Deserialization** | Validate & sanitize before deserializing, avoid `pickle`/`eval` |
| **Broken Access Control** | Authorization check at every endpoint, RBAC/ABAC |
| **Security Misconfiguration** | Disable debug mode, remove default credentials, set security headers |
| **Cryptographic Failures** | Use modern algorithms (AES-256, RSA-2048+), avoid MD5/SHA1 for security |
| **IDOR** | Validate ownership/authorization before resource access |

### 💡 Example: CSRF & CORS Protection

```typescript
// ✅ REQUIRED: CSRF protection with SameSite cookies + CSRF tokens

import csrf from 'csurf';
import cookieParser from 'cookie-parser';

app.use(cookieParser());

// Set secure cookie options
const cookieOptions: CookieOptions = {
  httpOnly: true,       // Not accessible via JavaScript
  secure: true,         // HTTPS only
  sameSite: 'strict',   // Block cross-site requests
  maxAge: 15 * 60 * 1000, // 15 minutes
  path: '/',
  domain: '.myapp.com',
};

// CORS — specific origins only
app.use(cors({
  origin: ['https://myapp.com', 'https://admin.myapp.com'],  // ✅ Explicit origins
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true,
  maxAge: 86400,
}));

// ❌ FORBIDDEN:
// app.use(cors({ origin: '*' }));  // Never use wildcard in production!
```

### 💡 Example: IDOR Prevention

```typescript
// ❌ FORBIDDEN: IDOR — any authenticated user can access any order
app.get('/api/orders/:id', authMiddleware, async (req, res) => {
  const order = await orderRepo.findById(req.params.id);  // ❌ No ownership check!
  res.json(order);
});

// ✅ REQUIRED: Verify resource ownership
app.get('/api/orders/:id', authMiddleware, async (req, res) => {
  const order = await orderRepo.findById(req.params.id);
  if (!order) throw new NotFoundError('Order', req.params.id);

  // Verify the requesting user owns this order (or is an admin)
  if (order.userId !== req.user.id && !req.user.permissions.includes('orders:read_all')) {
    throw new ForbiddenError('You do not have access to this order');
  }

  res.json(order);
});
```

---

## 2. 📦 Secure Dependencies

### 2.1 Dependency Selection

#### ✅ MUST do:
- Choose packages that are **actively maintained** (last commit < 6 months)
- Check **download count**, **stars**, and **community size** before adoption
- Check for **known vulnerabilities** before adding a new dependency
- Prefer packages with **minimal transitive dependencies**
- Use **exact versions** or **lock files** (`package-lock.json`, `poetry.lock`, `go.sum`)

#### ❌ MUST NOT do:
- Use **deprecated** or **unmaintained** packages
- Use wildcard versions (`*`, `latest`) in production dependencies
- Add a dependency for functionality that can be implemented in < 20 lines of code
- Use packages from untrusted sources

### 2.2 Dependency Monitoring & Updates

#### ✅ MUST do:
- Run **`npm audit`** / **`pip audit`** / **`go vuln check`** before finalizing
- Document all newly added dependencies with their justification
- Use **lock files** and commit them to the repository
- Check **license compatibility** (avoid GPL for proprietary projects if not suitable)

### 2.3 Supply Chain Security

#### ✅ MUST do:
- Carefully verify **package names** (avoid typosquatting: `lodash` vs `1odash`)
- Use **official registries** (npmjs.com, pypi.org, pkg.go.dev)
- Pin dependency versions in CI/CD pipelines
- Review dependency changes during updates (`npm diff`, `pip show`)

### 💡 Example: Secure Dependency Configuration

```json
// ❌ FORBIDDEN (package.json)
{
  "dependencies": {
    "express": "*",
    "lodash": "latest",
    "left-pad": "^1.0.0"
  }
}

// ✅ REQUIRED (package.json)
{
  "dependencies": {
    "express": "^4.18.2",
    "lodash": "^4.17.21"
  },
  "overrides": {
    "semver": ">=7.5.4"
  },
  "engines": {
    "node": ">=20.0.0",
    "npm": ">=10.0.0"
  }
}
```

```python
# ✅ REQUIRED: Python — pinned dependencies with hashes (requirements.txt)
# Generated with: pip-compile --generate-hashes requirements.in
fastapi==0.109.2 \
    --hash=sha256:2c1f7f5... \
    --hash=sha256:3a4f8e6...
uvicorn[standard]==0.27.0 \
    --hash=sha256:1b2c3d4...
pydantic==2.6.1 \
    --hash=sha256:5e6f7a8...

# ✅ REQUIRED: Python — pyproject.toml with version bounds
# [project]
# dependencies = [
#     "fastapi>=0.109.0,<0.110.0",
#     "uvicorn[standard]>=0.27.0,<0.28.0",
#     "pydantic>=2.6.0,<3.0.0",
# ]
```

---

## 3. 🐳 Secure Containers

### 3.1 Base Image Selection

#### ✅ MUST do:
- Use **official images** or **verified publisher** images
- Prefer **minimal base images** (`alpine`, `slim`, `distroless`)
- Specify an **exact version tag** — never use `latest`
- Scan images for vulnerabilities before deployment

### 3.2 Dockerfile Best Practices

#### ✅ MUST do:
- Use **multi-stage builds** to minimize image size and attack surface
- Run containers as a **non-root user**
- **Never copy secrets** into the image (use build args or secret mounts)
- Use specific **`COPY`** instructions (avoid `COPY . .` without a `.dockerignore`)
- Add a **`HEALTHCHECK`** instruction
- Set a **read-only filesystem** when possible

### 💡 Example: Complete Secure Dockerfile (Node.js)

```dockerfile
# ❌ FORBIDDEN: Insecure Dockerfile
FROM node:latest
WORKDIR /app
COPY . .
RUN npm install
ENV DB_PASSWORD=SuperSecret123
EXPOSE 3000
CMD ["node", "server.js"]
# Problems: latest tag, COPY without .dockerignore, npm install (not ci),
# secret in ENV, runs as root, no healthcheck, no multi-stage
```

```dockerfile
# ✅ REQUIRED: Production-grade secure Dockerfile

# ============================================================
# Stage 1: Dependencies (cached layer)
# ============================================================
FROM node:20.11-alpine3.19 AS deps
WORKDIR /app

# Copy only dependency files for efficient caching
COPY package.json package-lock.json ./

# Install production dependencies only, with clean install
RUN npm ci --only=production --ignore-scripts \
    && npm cache clean --force

# ============================================================
# Stage 2: Build (TypeScript compilation)
# ============================================================
FROM node:20.11-alpine3.19 AS builder
WORKDIR /app

COPY package.json package-lock.json tsconfig.json ./
RUN npm ci --ignore-scripts

COPY src/ ./src/
RUN npm run build

# ============================================================
# Stage 3: Production (minimal image)
# ============================================================
FROM gcr.io/distroless/nodejs20-debian12 AS production

# Labels for image metadata
LABEL maintainer="team@company.com"
LABEL version="1.0.0"
LABEL description="My secure application"

WORKDIR /app

# Copy only what's needed from previous stages
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json

# Run as non-root user (distroless default: nonroot)
USER nonroot:nonroot

# Expose only necessary port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD ["node", "-e", "fetch('http://localhost:3000/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"]

# Start application
CMD ["dist/server.js"]
```

### 💡 Example: Secure Python Dockerfile

```dockerfile
# ✅ REQUIRED: Production-grade Python Dockerfile

# Stage 1: Build
FROM python:3.12-slim-bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --target=/app/deps -r requirements.txt

COPY src/ ./src/

# Stage 2: Production
FROM python:3.12-slim-bookworm AS production

# Create non-root user
RUN groupadd --gid 1000 appuser \
    && useradd --uid 1000 --gid 1000 --shell /bin/false appuser

WORKDIR /app

# Copy only production dependencies
COPY --from=builder /app/deps /app/deps
COPY --from=builder /app/src /app/src

ENV PYTHONPATH=/app/deps
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Switch to non-root
USER appuser:appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"]

CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 3.3 Container Runtime Security

### 💡 Example: Secure docker-compose.yml

```yaml
# ✅ REQUIRED: Production docker-compose with full security

version: '3.9'

services:
  app:
    image: myapp:1.0.0
    build:
      context: .
      dockerfile: Dockerfile
      target: production
    user: "1000:1000"
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 128M
    tmpfs:
      - /tmp:size=64M
    environment:
      - NODE_ENV=production
      - PORT=3000
    env_file:
      - .env.production  # Secrets loaded from file, not hardcoded
    ports:
      - "3000:3000"
    networks:
      - frontend
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "node", "-e", "fetch('http://localhost:3000/health')"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 10s

  db:
    image: postgres:16.2-alpine
    user: "999:999"
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETUID
      - SETGID
      - FOWNER
      - DAC_OVERRIDE
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 1G
    volumes:
      - db_data:/var/lib/postgresql/data:rw  # Only DB data is writable
    tmpfs:
      - /tmp:size=256M
      - /run/postgresql:size=64M
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password  # Use Docker secrets
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access — only inter-service

volumes:
  db_data:
    driver: local
```

### 3.4 Image & Registry Security

#### ✅ MUST do:
- Use a **private registry** for production images
- Implement **image signing** and verification (Docker Content Trust / Cosign)
- Scan images regularly for **CVEs** (Trivy, Snyk, Grype)
- Create a **comprehensive `.dockerignore`**

```text
# ✅ .dockerignore
.git
.gitignore
.env
.env.*
*.md
README*
LICENSE
node_modules
tests/
__tests__/
docs/
.github/
.vscode/
*.pem
*.key
*.crt
docker-compose*.yml
Dockerfile*
.dockerignore
coverage/
.nyc_output/
*.log
.DS_Store
Thumbs.db
```

---

## 4. 🏗️ Secure Infrastructure as Code (IaC)

### 4.1 General IaC Security

#### ✅ MUST do:
- **Never hardcode secrets** in IaC files (Terraform, CloudFormation, Ansible, K8s manifests)
- Use **secret management** tools (Vault, AWS Secrets Manager, SOPS)
- Apply **least privilege** to all IAM roles and policies
- Enable **encryption at rest** and **in transit** by default
- Enable **logging and monitoring** for all resources

#### ❌ MUST NOT do:
- Hardcode credentials in Terraform variables, Ansible playbooks, or K8s manifests
- Use `0.0.0.0/0` as an ingress rule without justification
- Disable logging or monitoring
- Use default VPC/security groups without customization

### 💡 Example: Complete Secure Terraform Module

```hcl
# ❌ FORBIDDEN: Insecure Terraform
resource "aws_security_group" "web" {
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "main" {
  password            = "SuperSecret123!"
  publicly_accessible = true
  storage_encrypted   = false
}

resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
  acl    = "public-read"  # Publicly accessible!
}
```

```hcl
# ✅ REQUIRED: Secure Terraform configuration

# --- Variables (secrets from external sources) ---
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application"
  type        = list(string)
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be 'staging' or 'production'."
  }
}

# --- Security Group (least privilege) ---
resource "aws_security_group" "web" {
  name_prefix = "${var.environment}-web-"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from allowed CIDRs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow outbound to VPC only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = local.common_tags
}

# --- RDS (encrypted, private, protected) ---
resource "aws_db_instance" "main" {
  identifier     = "${var.environment}-main-db"
  engine         = "postgres"
  engine_version = "16.2"
  instance_class = "db.t3.medium"

  # Security
  password                = data.aws_secretsmanager_secret_version.db_password.secret_string
  publicly_accessible     = false
  storage_encrypted       = true
  kms_key_id             = aws_kms_key.db.arn
  iam_database_authentication_enabled = true
  deletion_protection     = true

  # Backup & Recovery
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  # Network
  db_subnet_group_name   = aws_db_subnet_group.private.name
  vpc_security_group_ids = [aws_security_group.db.id]

  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  tags = local.common_tags
}

# --- S3 (private, encrypted, versioned) ---
resource "aws_s3_bucket" "data" {
  bucket = "${var.environment}-data-${data.aws_caller_identity.current.account_id}"
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- IAM (least privilege) ---
resource "aws_iam_role" "app" {
  name = "${var.environment}-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Condition = {
        StringEquals = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id }
      }
    }]
  })
}

resource "aws_iam_role_policy" "app_s3" {
  name = "${var.environment}-app-s3-access"
  role = aws_iam_role.app.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:PutObject"]  # Only needed actions!
      Resource = "${aws_s3_bucket.data.arn}/*"
    }]
  })
}

# --- Common tags ---
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "my-project"
    Team        = "platform"
  }
}
```

### 💡 Example: Secure Kubernetes Deployment

```yaml
# ✅ REQUIRED: Production-grade Kubernetes deployment

apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: production
  labels:
    app: my-app
    version: v1.0.0
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
        version: v1.0.0
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9090"
    spec:
      automountServiceAccountToken: false
      serviceAccountName: my-app-sa

      # Pod-level security
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        seccompProfile:
          type: RuntimeDefault

      containers:
        - name: app
          image: registry.company.com/my-app:1.0.0@sha256:abc123def456...
          
          # Container-level security
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]

          # Resource limits
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi

          # Environment from Secrets (never ConfigMaps for sensitive data)
          env:
            - name: NODE_ENV
              value: "production"
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: database-url
            - name: JWT_SECRET
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: jwt-secret

          # Health checks
          livenessProbe:
            httpGet:
              path: /health/live
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 15
            failureThreshold: 3

          readinessProbe:
            httpGet:
              path: /health/ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 10

          # Writable temp directory (since filesystem is read-only)
          volumeMounts:
            - name: tmp
              mountPath: /tmp

      volumes:
        - name: tmp
          emptyDir:
            sizeLimit: 64Mi

---
# Network Policy — restrict traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-app-netpol
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: ingress-nginx
      ports:
        - port: 3000
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: postgres
      ports:
        - port: 5432
    - to:  # Allow DNS resolution
        - namespaceSelector: {}
      ports:
        - port: 53
          protocol: UDP
```

---

## 5. 🔒 Security Headers & API Security

### 5.1 HTTP Security Headers

### 💡 Example: Express.js Security Headers Middleware

```typescript
// ✅ REQUIRED: Complete security headers with Helmet

import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],  // Tighten in production
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "https://api.myapp.com"],
      fontSrc: ["'self'", "https://fonts.gstatic.com"],
      objectSrc: ["'none'"],
      mediaSrc: ["'none'"],
      frameSrc: ["'none'"],
      baseUri: ["'self'"],
      formAction: ["'self'"],
      frameAncestors: ["'none'"],
      upgradeInsecureRequests: [],
    },
  },
  crossOriginEmbedderPolicy: true,
  crossOriginOpenerPolicy: { policy: 'same-origin' },
  crossOriginResourcePolicy: { policy: 'same-origin' },
  dnsPrefetchControl: { allow: false },
  frameguard: { action: 'deny' },
  hsts: { maxAge: 31536000, includeSubDomains: true, preload: true },
  ieNoOpen: true,
  noSniff: true,
  originAgentCluster: true,
  permittedCrossDomainPolicies: { permittedPolicies: 'none' },
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  xssFilter: false,  // Deprecated — rely on CSP
}));

// Additional custom headers
app.use((req, res, next) => {
  res.setHeader('Permissions-Policy', 'camera=(), microphone=(), geolocation=(), payment=()');
  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
  res.setHeader('Pragma', 'no-cache');
  res.setHeader('Expires', '0');
  next();
});
```

### 5.2 API Security

### 💡 Example: Rate Limiting + Request Validation

```typescript
// ✅ REQUIRED: Rate limiting and request size limits

import rateLimit from 'express-rate-limit';

// Global rate limiter
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 100,                   // 100 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests, please try again later' },
});

// Strict limiter for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,                     // Only 5 login attempts per 15 minutes
  skipSuccessfulRequests: true,
  message: { error: 'Too many login attempts, please try again later' },
});

app.use(globalLimiter);
app.use('/api/auth', authLimiter);

// Request size limits
app.use(express.json({ limit: '10kb' }));       // JSON body max 10KB
app.use(express.urlencoded({ limit: '10kb', extended: true }));

// API versioning
app.use('/api/v1', v1Router);
app.use('/api/v2', v2Router);
```

---

## 📋 Security Checklist Before Completing a Task

The agent **MUST** verify the following checklist:

### Code Security
- [ ] No hardcoded secrets, credentials, or API keys
- [ ] All user inputs are validated and sanitized
- [ ] Database queries use parameterized queries
- [ ] Error messages do not expose internal information
- [ ] Authentication & authorization are implemented correctly

### Dependency Security
- [ ] All dependencies come from trusted sources
- [ ] No known vulnerabilities in dependencies (`npm audit` / `pip audit`)
- [ ] Lock file is committed and up to date
- [ ] No unnecessary dependencies

### Container Security
- [ ] Base image uses an exact version tag (not `latest`)
- [ ] Container runs as a non-root user
- [ ] Multi-stage build is used (if applicable)
- [ ] `.dockerignore` is comprehensive
- [ ] No secrets are copied into the image

### IaC Security
- [ ] No hardcoded secrets in IaC files
- [ ] Least privilege applied to all IAM/RBAC
- [ ] Encryption enabled at rest and in transit
- [ ] Security groups/firewall rules are not over-permissive
- [ ] Logging and monitoring are enabled

---

## ⚠️ Exceptions

These security rules **MUST NOT** be relaxed except:

1. **Local development only** — Some rules (HTTPS, security headers) may be relaxed for the development environment, but there must be a separate configuration for production
2. **User explicitly requests it** — The agent must **warn about the security risk** before violating this rule at the user's request

> ⚠️ **IMPORTANT:** If the user requests something that violates a security rule, the agent MUST explain the risks and suggest a more secure alternative before proceeding.

---

## 📚 Recommended Tools & Resources

| Category | Tools |
|----------|-------|
| **Code Scanning** | SonarQube, Semgrep, CodeQL, Bandit (Python), ESLint security plugin |
| **Dependency Scanning** | Snyk, npm audit, pip-audit, Dependabot, Renovate |
| **Container Scanning** | Trivy, Grype, Snyk Container, Docker Scout |
| **IaC Scanning** | Checkov, tfsec, KICS, Terrascan, OPA/Rego |
| **Secret Detection** | GitLeaks, TruffleHog, detect-secrets |
| **DAST** | OWASP ZAP, Burp Suite, Nuclei |
