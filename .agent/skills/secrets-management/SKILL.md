---
name: Secrets Management
description: Skill for managing secrets securely — covering secret detection, environment variable management, vault integration, key rotation, .env best practices, and preventing credential exposure in code and logs.
---

# Secrets Management Skill

## Overview
Secrets management protects sensitive credentials (API keys, database passwords, tokens) from exposure. This covers .env patterns, secret rotation, vault integration, Git secrets prevention, and secure environment variable handling across environments.

**References**:
- [12-Factor App Config](https://12factor.net/config)
- [dotenv](https://github.com/motdotla/dotenv)

---

## Environment Variables

```typescript
// src/config/env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production']).default('development'),
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),
  JWT_ACCESS_SECRET: z.string().min(32),
  JWT_REFRESH_SECRET: z.string().min(32),
  SMTP_HOST: z.string(),
  SMTP_PORT: z.coerce.number().default(587),
  SMTP_USER: z.string(),
  SMTP_PASS: z.string(),
  STRIPE_SECRET_KEY: z.string().startsWith('sk_'),
  STRIPE_WEBHOOK_SECRET: z.string().startsWith('whsec_'),
  AWS_ACCESS_KEY_ID: z.string().optional(),
  AWS_SECRET_ACCESS_KEY: z.string().optional(),
});

export const env = envSchema.parse(process.env);
```

---

## .env File Structure

```bash
# .env.example (committed to git)
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
REDIS_URL=redis://localhost:6379
JWT_ACCESS_SECRET=
JWT_REFRESH_SECRET=
SMTP_HOST=smtp.mailtrap.io
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=
STRIPE_SECRET_KEY=sk_test_
STRIPE_WEBHOOK_SECRET=whsec_
```

---

## .gitignore

```gitignore
.env
.env.local
.env.*.local
.env.production
*.pem
*.key
```

---

## Secret Generation

```bash
# Generate secure secrets
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
openssl rand -hex 64
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Validation** | Validate env vars with Zod at startup |
| **.env.example** | Commit example, never actual .env |
| **.gitignore** | Always exclude .env files |
| **Rotation** | Rotate secrets regularly |
| **Vault** | Use HashiCorp Vault / AWS SM for production |
| **Least privilege** | Minimal permissions per secret |
| **Audit** | Log secret access, not values |
| **Redaction** | Redact secrets from logs |
| **Pre-commit** | Use git-secrets to prevent leaks |
| **Environment-specific** | Separate secrets per environment |

---

## Rules Integration
- **Validation**: Zod schema at application startup
- **Structure**: .env.example committed, .env ignored
- **Generation**: Cryptographically secure random secrets
- **Production**: Vault or cloud secret managers
